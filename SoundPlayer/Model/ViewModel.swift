//
//  ViewModel.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import SwiftUI

enum PlayMode: String, Codable {
  case play
  case pause
  case stop
}

enum RepeatMode: String, Codable {
  case noRepeate    // 繰り返しなし
  case repeateOne   // １曲繰り返し
  case repeateAll   // 全曲繰り返し
 }

enum TimeFormat: String, Codable {
  case HHMMSS
  case MMSS
}


class ViewModel: ObservableObject, PlayerDelegateTerminated, EarphoneControlDelegate, PlayerDelegateInterruption {
  var emptyArtWork: Data?
  
  // Player
  var player = Player()
  
  // 音声データ
  var soundInfos = [SoundInfo]()
  var fullSoundInfos = [FullSoundInfo]()
  var folderInfos = [FolderInfo]()
  var playListInfos = [PlayListInfo]()
  
  var interruptSounds = [SoundInfo]()
  var playSoundList = [CurrentPlayingSound]()
  var currentPlaySoundIndex: Int {
    get {
      return utility.getPlayingSoundsIndex()
    }
    set(val) {
      utility.savePlayingSoundsIndex(index: val)
    }
  }

  var currentPlayingSound: SoundInfo? {
    get {
      if self.playSoundList.count > self.currentPlaySoundIndex {
        return self.playSoundList[self.currentPlaySoundIndex].soundInfo
      }
      return nil
    }
  }

  // 設定データ
  var settingInfo = SettingModel()
  
  var volome: Float {
    get {
      return utility.getPlayingSoundVolume()
    }
    
    set(volume) {
      utility.savePlayingSoundVolume(volume: volume)
      self.player.setVolume(volume: volume)
    }
  }
  
  // 再生対象のグループ情報
  var playingGroup: GroupInfo? {
    get {
      // グループタイプにより使うデータを判断
      var groupInfos = [GroupInfo]()
      switch utility.getPlayingGroupType() {
      case .FullSound:
        groupInfos = self.fullSoundInfos
      case .Folder:
        groupInfos = self.folderInfos
      case .PlayList:
        groupInfos = self.playListInfos
      case .none:
        break
      }
      
      // 対象のGroupInfoを検索
      if let groupText = utility.getPlayingGroupText() {
        if let groupInfo = groupInfos.first(where: {$0.text == groupText}) {
          return groupInfo
        }
      }
      return nil
    }
    
    set(groupInfo) {
      // 現在のグループ情報を保存
      utility.savePlayingGroupType(groupInfo: groupInfo)
    }
  }
  
  var playingSoundDuration: TimeInterval {
    get {
      return utility.getPlayingSoundDuration()
    }
    set(duration) {
      utility.savePlayingSoundDuration(duration: duration)
    }
  }
  
  var selectedGroup: GroupInfo? {
    get {
      // グループタイプにより使うデータを判断
      var groupInfos = [GroupInfo]()
      switch utility.getSelectedGroupType() {
      case .FullSound:
        groupInfos = self.fullSoundInfos
      case .Folder:
        groupInfos = self.folderInfos
      case .PlayList:
        groupInfos = self.playListInfos
      case .none:
        break
      }
      
      // 対象のGroupInfoを検索
      if let groupText = utility.getSelectedGroupText() {
        if let groupInfo = groupInfos.first(where: {$0.text == groupText}) {
          return groupInfo
        }
      }
      return nil
    }
    set(val) {
      // 現在のグループ情報を保存
      utility.saveSelectedGroupType(groupInfo: val)
    }
  }
  
  var playMode: PlayMode {
    get {
      if self.player.isPlaying == true {
        return .play
      }
      return .pause
    }
  }
  
  // データモデル作成
  func createDataModel() {
    // 設定情報取得
    self.settingInfo = utility.getSettingInfo()
    
    createSoundInfo()
    createFolderInfo()
    self.playListInfos = utility.getPlayListInfo().sorted { $0.sortKey < $1.sortKey }
    
    // 音声の選択フラグを設定
    self.setSelectedSound(newGroupInfos: self.fullSoundInfos)
    self.setSelectedSound(newGroupInfos: self.folderInfos)
    

    // 現在再生
    var currentPlayingSounds = [CurrentPlayingSound]()
    self.currentPlaySoundIndex = utility.getPlayingSoundsIndex()
    
    if let _playingSounds = utility.getPlayingSounds() {
      if let a = _playingSounds.first(where: {$0.isInterruptSound == false}) {
        var targetGroups: [GroupInfo]?
        switch a.groupType {
        case GroupType.FullSound:
          targetGroups = self.fullSoundInfos
          break
        case GroupType.Folder:
          targetGroups = self.folderInfos
          break
        case GroupType.PlayList:
          targetGroups = self.playListInfos
          break
        }
        // ベースになるグループからcurrentPlayingSoundsを作成
        if let _targetGroups = targetGroups {
          if let _targetGroup = _targetGroups.first(where: {$0.text == a.groupText}) {
            _targetGroup.soundInfos.forEach { itemSound in
              currentPlayingSounds.append(CurrentPlayingSound(soundInfo: itemSound, groupText: _targetGroup.text, groupType: a.groupType))
            }
          }
        }
        // 次に再生音声を追加
        _playingSounds.enumerated().forEach( { index, item in
          if item.isInterruptSound {
            currentPlayingSounds.insert(CurrentPlayingSound(soundInfo: item.soundInfo, groupText: item.groupText, groupType: item.groupType, isInterruptSound: true), at: index)
          }
        })
        self.playSoundList = currentPlayingSounds
        self.dump(_playSoundListEx: self.playSoundList)
        
      }
    }
/*
    if let _playSoundListEx = utility.getPlayingSounds() {
      self.dump(_playSoundListEx: _playSoundListEx)
      self.playSoundListEx = _playSoundListEx
      let groupTexts = Dictionary(grouping: _playSoundListEx) { [$0.groupType.rawValue, $0.groupText] }
      for (key, val) in groupTexts {
        let k = key
        let v = val
        var targetGroups: [GroupInfo]?
        if let grpType = GroupType(rawValue: key[0]) {
          switch grpType {
          case GroupType.FullSound:
            targetGroups = self.fullSoundInfos
            break
          case GroupType.Folder:
            targetGroups = self.folderInfos
            break
          case GroupType.PlayList:
            targetGroups = self.playListInfos
            break
          }
          if let _targetGroups = targetGroups {
            if let grp = _targetGroups.first(where: {$0.text == key[1]}) {
              val.forEach {sound in sound.soundInfo.parentId = grp.id}
            }
          }
        }
      }
    }
 */
  }
  
  init() {
    // データモデル作成
    self.createDataModel()
    
    // Playerデリゲート
    self.player.delegate = self
    self.player.delegateEarphoneControl = self
    self.player.delegateInterruption = self
    
    // イヤホン
    self.player.addRemoteCommandEvent()
    
    // ArtWork無し用の画像
    if let path = Bundle.main.url(forResource: "EmptyArtWork.png", withExtension: "") {
      if let image = UIImage(named: path.path) {
        if let imageData = image.pngData() {
          self.emptyArtWork = imageData
        }
      }
    }
  }
  
  /// 音声の選択フラグを設定
  func setSelectedSound(newGroupInfos: [GroupInfo]) {
    if newGroupInfos.count > 0 {
      var oldGroupInfos: [GroupInfo]? = nil
      
      if newGroupInfos[0].groupType == .FullSound {
        oldGroupInfos = utility.getSaveFullSoundInfo()
      } else if newGroupInfos[0].groupType == .Folder {
        oldGroupInfos = utility.getSaveFolderInfo()
      } else if newGroupInfos[0].groupType == .PlayList {
        oldGroupInfos = utility.getPlayListInfo()
      }
      
      if let _oldFullSoundInfos = oldGroupInfos {
        _oldFullSoundInfos.forEach { itemGrp in
          if let selectedSound = itemGrp.soundInfos.first(where: {$0.isSelected}) {
            if let findedGrp = newGroupInfos.first(where: {$0.text == itemGrp.text}) {
              if let findedSnd = findedGrp.soundInfos.first(where: {$0.fullPath?.absoluteString == selectedSound.fullPath?.absoluteString}) {
                findedSnd.isSelected = true
                findedSnd.currentTime = selectedSound.currentTime
              }
            }
          }
        }
      }
    }
  }
  
  func isPlayingSound(targetSound: SoundInfo) -> Bool {
    if self.player.isPlaying {
      if let _playingSound = self.currentPlayingSound {
        if _playingSound.id == targetSound.id {
          return true
        }
      }
    }
    return false
  }

  /// 再生終了の通知 デリゲート
  func notifyTermination() {
    if let _currentPlayingSound = self.currentPlayingSound {
      _currentPlayingSound.currentTime = TimeInterval.zero
      self.playNextSound()
    }
/*
    if let _playingSound = self.getPlayingSound() {
      _playingSound.currentTime = TimeInterval.zero
      self.playNextSound()
    }
*/
    // 再描画
    self.redraw()
  }
  
  /// 再生中断開始デリゲート
  func notifyBeginInterruption() {
    utility.debugPrint(msg: "delegate:notifyBeginInterruption")
    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(センターボタン)
  func notifyEarphoneTogglePlayPause() {
    if self.player.isPlaying {
      // グループ情報の保存
      self.saveGroupInfos()
      
      // Pause
      self.pauseSound()
    } else {
      do {
        try self.playSound()
      } catch {
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
      }
    }
    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(プレイボタン)
  func notifyEarphonePlay() {
    do {
      try self.playSound()
    } catch {
      utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
    }
//    self.playCurrentSound()
    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(ポーズボタン)
  func notifyEarphonePause() {
    // グループ情報保存
    self.saveGroupInfos()

    // Pause
    self.pauseSound()

    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(次へボタン)
  func notifyEarphoneNextTrack() {
    self.playNextSound()
  }
  
  /// イヤホン操作のデリゲート(前へボタン)
  func notifyEarphonePrevTrack() {
    self.playPrevSound()
  }
  
  /// イヤホンの切断
  func notifyEarphoneDisconnected() {
    // グループ情報の保存
    self.saveGroupInfos()
    
    // Pause
    self.pauseSound()

    // 再描画
    self.redraw()
  }
  
  /// デバイスに登録されているファイルからSoundInfoを作成する
  func createSoundInfo() {
    // Full Sound の ID
    let fullSoundId = UUID().uuidString
    
    self.soundInfos.removeAll()
    utility.getSoundFiles().forEach { item in
      self.soundInfos.append(SoundInfo(parentId: fullSoundId, fileName: item))
    }
    
    // ソート（フォルダ名＋ファイル名）
    self.soundInfos.sort{
      let d0 = $0.fullPath?.absoluteString ?? ""
      let d1 = $1.fullPath?.absoluteString ?? ""
      return d0 < d1
    }
    
    // Full Sound Group作成
    self.fullSoundInfos = [FullSoundInfo]()
    self.fullSoundInfos.append(FullSoundInfo(text: "Full Sound"))
    self.fullSoundInfos[0].soundInfos = self.soundInfos
    self.fullSoundInfos[0].id = fullSoundId
    
    // ParentIdセット
//    self.soundInfos.forEach { item in item.parectId = self.fullSoundInfos[0].id }
  }
  
  /// フォルダ情報作成
  func createFolderInfo() {
    self.folderInfos.removeAll()
    self.soundInfos.forEach { item in
      let copyItem = item.copy()
      if let folder = self.folderInfos.first(where: {$0.text == item.foldersName}){
        copyItem.parentId = folder.id
        folder.soundInfos.append(copyItem)
      } else {
        let newFolder = FolderInfo(text: item.foldersName, soundInfos: [copyItem])
        copyItem.parentId = newFolder.id
        self.folderInfos.append(newFolder)
      }
    }
  }
  
  /// PlayModeカラー
  func getPlayModeColor() -> Color {
    switch self.playMode {
    case .play:
      return Color.blue
    case .pause:
      return Color.red
    case .stop:
      return Color.black
    }
  }
  
  /// 再生時間設定
  func setPlayTime(time: Double) {
    self.player.setPlayPosition(position: time)
  }
  
  /// 再生時間調整
  func adjustPlayTime(seconds: Double) {
    let newTime = self.player.getCurrentTime() + seconds
    if newTime <= self.playingSoundDuration {
      self.player.setPlayPosition(position: newTime)
    }
  }
  
  /// グループ再生
  func playGroup(targetGroupInfo: GroupInfo?) throws {
    if let _targetGroupInfo = targetGroupInfo {
      self.changSoundList(targetGroup: _targetGroupInfo)
      try playSound()
    }
  }
  
  /// 停止
  func pauseSound() {
    self.player.pauseSound()
    
    // 再描画
    self.redraw()
  }
  
  /// 再生
  func playSound(volume: Float = utility.getPlayingSoundVolume()) throws {
    if let _currentPlayingSound = self.currentPlayingSound {
      // 選択フラグ設定
      if let _targetGroup = getGroup(targetSound: _currentPlayingSound) {
        _targetGroup.selectedSound = _currentPlayingSound
      }

      // 再生
      try self.player.Play(url: _currentPlayingSound.fullPath, startTime: _currentPlayingSound.currentTime, volume: volume)
    }
    
    // 再表示
    self.redraw()
  }
  
  /// 再生対象音声を選択
  func selectPlaySound(targetSound: SoundInfo) {
    if let index = self.playSoundList.firstIndex(where: {$0.soundInfo.parentId == targetSound.parentId && $0.soundInfo.fileNameNoExt == targetSound.fileNameNoExt}) {
      // 再生対象インデックス設定
      self.currentPlaySoundIndex = index
      if let _group = getGroup(targetSound: targetSound) {
        // 再生対象音声電卓
        _group.selectedSound = targetSound
      }
    }
    // 再表示
    self.redraw()
  }

  /// 次を再生
  func playNextSound() {
    // Pause
    self.pauseSound()

    // 次の音声を決める
    if utility.getRandomMode() {
      // ランダム再生
      self.currentPlaySoundIndex = Int.random(in: 0..<playSoundList.count - 1)
    } else {
      if self.playSoundList.count > self.currentPlaySoundIndex + 1 {
        self.currentPlaySoundIndex += 1
      } else {
        if utility.getRepearMode() == .repeateAll {
          self.currentPlaySoundIndex = 0
        }
      }
    }

    do {
      try self.playSound()
    } catch {
      utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
    }
  }
  
  /// 前を再生
  func playPrevSound() {
    if self.currentPlaySoundIndex >= 0 {
      self.currentPlaySoundIndex -= 1

      // Pause
      self.pauseSound()
      do {
        // Play
        try self.playSound()
      } catch {
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
      }
    }
  }
  
  // 音声の現在再生時間
  func getPlayingTime() -> TimeInterval {
    if let _selectedSound = self.currentPlayingSound {
      return _selectedSound.currentTime
    }
    return TimeInterval.zero
  }
  
  /// グループ情報保存
  func saveGroupInfos() {
    // 再生中の音声の時間セット
    if let _playingSound = self.currentPlayingSound {
      _playingSound.currentTime = self.player.getCurrentTime()
    }
    utility.saveGroupInfo(outputInfos: self.fullSoundInfos)
    utility.saveGroupInfo(outputInfos: self.folderInfos)
    utility.saveGroupInfo(outputInfos: self.playListInfos)
    utility.savePlayingSounds(outputInfos: self.playSoundList)
  }
  
  /// Soundの削除
  func removeSound(targetGroup: GroupInfo?, targetSound: SoundInfo?) {
    if let _targetSound = targetSound {
      if let _targetGroup = targetGroup {
        // PlayList以外はファイル削除
        if _targetGroup.groupType == .PlayList {
          // PlayListは参照のみ削除
          _targetGroup.removeSoundReference(removeSound: _targetSound)
        } else {
          // ファイルの削除
          _targetGroup.removeSoundFile(removeSound: _targetSound)
          
          // 参照の削除
          utility.removeReference(targetGroups: self.fullSoundInfos, targetSound: _targetSound)
          utility.removeReference(targetGroups: self.folderInfos, targetSound: _targetSound)
          utility.removeReference(targetGroups: self.playListInfos, targetSound: _targetSound)
          self.soundInfos.removeAll(where: {$0.fullPath == _targetSound.fullPath})
        }
      }
    }
  }
  
  /// GroupName変更
  func renameGroupName(targetGroup: GroupInfo?, newGroupName: String) throws {
    if let _targetGroup = targetGroup {
      // 旧Group名
      let oldGroupName = _targetGroup.text
      
      // フォルダ名変更
      try _targetGroup.renameFolder(newFolderName: newGroupName)
      
      // GroupがFolderの場合、PlayListのFolder名を変更する
      if _targetGroup.groupType == .Folder {
        // PlayListの参照を変更する
        if let oldFullPath = utility.getDocumentPath(fileName: oldGroupName){
          self.playListInfos.forEach { folderItem in
            folderItem.soundInfos.forEach { fileItem in
              if let _fullpath = fileItem.fullPath {
                if _fullpath.deletingLastPathComponent().absoluteString == oldFullPath.absoluteString + "/" {
                  fileItem.foldersName = newGroupName
                }
              }
            }
          }
        }
      }
    }
    
    // グループ情報保存
    self.saveGroupInfos()
  }
  
  /// Group削除
  func removeGroup(targetGroup: GroupInfo?) throws {
    if let _targetGroup = targetGroup {
      // フォルダ削除
      try _targetGroup.removeFolder()
      
      // PlayListから削除されたフォルダのSoundを参照してるものを削除
      if _targetGroup.groupType == .Folder {
        if let removePath = utility.getDocumentPath(fileName: _targetGroup.text) {
          self.playListInfos.forEach { folderItem in
            folderItem.soundInfos.removeAll(where: {$0.fullPath == removePath})
          }
        }
        // 配列から削除
        self.folderInfos.removeAll(where: {$0.text == _targetGroup.text})
      } else if targetGroup?.groupType == .PlayList {
        // 配列から削除
        self.playListInfos.removeAll(where: {$0.text == _targetGroup.text})
      }
      
      // グループ情報保存
      self.saveGroupInfos()
    }
    
    // 再描画
    self.redraw()
  }
  
  func getGroupInfos(groupType: GroupType) -> [GroupInfo]? {
    if groupType == .Folder {
      return self.folderInfos
    } else if groupType == .PlayList {
      return self.playListInfos
    }
    
    return nil
  }
  
  func validationGroupName(text: String) -> Bool {
    if text.count > 0 {
      if let _ = playListInfos.first(where: {$0.text == text}) {
        return false
      } else {
        return true
      }
    }
    return false
  }
  
  func SearchSound(searchText: String) {
    // FolderInfoの検索
    self.folderInfos.forEach { item in
      self.SearchSound(targetGroup: item, searchText: searchText)
    }
    
    // PlayListの検索
    self.playListInfos.forEach { item in
      self.SearchSound(targetGroup: item, searchText: searchText)
    }
  }
  
  func SearchSound(targetGroup: GroupInfo, searchText: String) {
    if targetGroup.text.contains(searchText) {
      targetGroup.soundInfos.forEach { item in item.isSearched = true }
    } else {
      targetGroup.soundInfos.forEach { item in
        item.isSearched = false
        if item.fileNameNoExt.contains(searchText) {
          item.isSearched = true
        }
      }
  }
}

  func getArtWorkImage(soundInfo: SoundInfo) -> some View {
    var image: Image
    
    if let _image = utility.getArtWorkImage(imageData: soundInfo.artWork, showArtWork:   self.settingInfo.showArtWork) {
      image = _image
    } else {
      image = Image(systemName: "clear")
    }
    
    return image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 30, height: 30)
  }

  
  // 再描画
  func redraw() {
    utility.debugPrint(msg: "redraw")
    objectWillChange.send()
  }

  /// グループ取得（指定されたSoundのグループを取得）
  func getGroup(targetSound: SoundInfo) -> GroupInfo? {
    if let _res = self.fullSoundInfos.first(where: { $0.id == targetSound.parentId }) {
      return _res
    }
    
    if let _res = self.folderInfos.first(where: { $0.id == targetSound.parentId }) {
      return _res
    }
    
    if let _res = self.playListInfos.first(where: { $0.id == targetSound.parentId }) {
      return _res
    }
    return nil
  }
  
  /// 追加「次に再生」
  func insertNextPlay(targetSound: SoundInfo?) {
    if let _targetSound = targetSound {
      if let _targetGroup = getGroup(targetSound: _targetSound) {
        self.playSoundList.insert(CurrentPlayingSound(soundInfo: _targetSound, groupText: _targetGroup.text, groupType: _targetGroup.groupType, isInterruptSound: true)
, at: self.currentPlaySoundIndex + 1)
      }
      utility.savePlayingSounds(outputInfos: self.playSoundList)
    }
  }
  
  /// 再生リスト作成
  func changSoundList(targetGroup: GroupInfo) {
    self.playSoundList = targetGroup.soundInfos.map { CurrentPlayingSound(soundInfo: $0, groupText: targetGroup.text, groupType: targetGroup.groupType)}

    self.currentPlaySoundIndex = 0
    if let idx = targetGroup.soundInfos.firstIndex(where: {$0.isSelected}) {
      self.currentPlaySoundIndex = idx
    }
    
    utility.savePlayingSounds(outputInfos: self.playSoundList)
  }

  #if DEBUG
  private func dump(_playSoundListEx: [CurrentPlayingSound]) {
    _playSoundListEx.forEach { item in
      print("\(item.groupType.rawValue):\(item.groupText):\(item.soundInfo.fileNameNoExt)")
    }
  }
  #endif
}
