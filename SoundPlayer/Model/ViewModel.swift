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
    /*
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
     _oldFullSoundInfos.forEach { oldItem in
     // 一致するグループを取得
     if let newItem = newGroupInfos.first( where: { $0.text == oldItem.text }) {
     oldItem.soundInfos.forEach { oldSound in
     if let _targetSound = newItem.soundInfos.first(where: {$0.path?.absoluteString == oldSound.path?.absoluteString}) {
     _targetSound.isSelected = oldSound.isSelected
     _targetSound.currentTime = oldSound.currentTime
     }
     }
     }
     }
     }
     }
     */
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
  
  func isPlayingSound(groupInfo: GroupInfo, soundInfo: SoundInfo) -> Bool {
    utility.debugPrint(msg: "getPlayingImage isPlayingSound \(soundInfo.fileNameNoExt)")
    if self.player.isPlaying {
      if let _playingGroup = self.playingGroup {
        if let _playingSound = self.getPlayingSound() {
          if _playingGroup.text == groupInfo.text
              && _playingGroup.groupType == groupInfo.groupType {
            if _playingSound.fullPath?.absoluteString == soundInfo.fullPath?.absoluteString {
              utility.debugPrint(msg: "getPlayingImage isPlayingSound \(soundInfo.fileNameNoExt) ++++++++++++++++++++++++")
              return true
            }
          }
        }
      }
    }
    utility.debugPrint(msg: "getPlayingImage isPlayingSound \(soundInfo.fileNameNoExt) -----------------------")
    return false
  }
  
  /// 再生終了の通知 デリゲート
  func notifyTermination() {
    utility.saveDebugLog(log: "notifyTermination")
    if let _playingSound = self.getPlayingSound() {
      utility.saveDebugLog(log: "notifyTermination(\(_playingSound.fileNameNoExt)")
      _playingSound.currentTime = TimeInterval.zero
      self.playNextSound()
    }
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
      
      self.player.pauseSound()
    } else {
      self.playCurrentSound()
    }
    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(プレイボタン)
  func notifyEarphonePlay() {
    self.playCurrentSound()
    // 再描画
    self.redraw()
  }
  
  /// イヤホン操作のデリゲート(ポーズボタン)
  func notifyEarphonePause() {
    // グループ情報保存
    self.saveGroupInfos()
    
    // 停止
    self.player.pauseSound()
    
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
    
    // 停止
    self.player.pauseSound()
    
    // 再描画
    self.redraw()
  }
  
  /// デバイスに登録されているファイルからSoundInfoを作成する
  func createSoundInfo() {
    self.soundInfos.removeAll()
    utility.getSoundFiles().forEach { item in
      self.soundInfos.append(SoundInfo(fileName: item))
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
  }
  
  /// フォルダ情報作成
  func createFolderInfo() {
    self.folderInfos.removeAll()
    
    // URLのパスコンポーネントを取得
    self.soundInfos.forEach { item in
      let copyItem = item.copy()
      if let folder = self.folderInfos.first(where: {$0.text == item.foldersName}){
        folder.soundInfos.append(copyItem)
      } else {
        self.folderInfos.append(FolderInfo(text: item.foldersName, soundInfos: [copyItem]))
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
      if _targetGroupInfo.selectedSound != nil {
        try self.playSound(targetGroup: _targetGroupInfo, targetSound: _targetGroupInfo.selectedSound)
      } else {
        if _targetGroupInfo.soundInfos.count > 0 {
          try self.playSound(targetGroup: _targetGroupInfo, targetSound: _targetGroupInfo.soundInfos[0])
        }
      }
    }
  }
  
  /// 停止
  func pauseSound() {
    self.player.pauseSound()
  }
  
  /// 指定された音声を再生
  func playSound(targetGroup: GroupInfo?, targetSound: SoundInfo?, volume: Float = utility.getPlayingSoundVolume()) throws {
    // 現在の音声のPath取得
    var oldPath = ""
    var currentPlayingSound = SoundInfo()
    if let _currentPlayingSound = self.getPlayingSound() {
      currentPlayingSound = _currentPlayingSound
      if let _oldPath = _currentPlayingSound.path {
        oldPath = _oldPath.absoluteString
      }
    }
    
    if let _targetGroup = targetGroup {
      if let _targetSound = targetSound {
        // 選択状態セット
        _targetGroup.selectedSound = _targetSound
        
        // 音声の長さを保存
        self.playingSoundDuration = _targetSound.duration()
        
        if self.player.isPlaying {
          
          // Pause
          self.player.pauseSound()
          
          // 再生時間保存
          currentPlayingSound.currentTime = self.player.getCurrentTime()
          
          utility.debugPrint(msg: "currentTime:\(currentPlayingSound.fileNameNoExt):\(utility.timeIntervalToString(timeInterval: currentPlayingSound.currentTime))")
          
          if let _newPath = _targetSound.path {
            if oldPath != _newPath.absoluteString {
              // Play
              try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: volume)
            }
          }
        } else {
          // Play
          try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: volume)
        }
        // Playing Gropu設定
        self.playingGroup = _targetGroup
        
        // グループ情報保存
        self.saveGroupInfos()
      }
    }
    
    // 再表示
    self.redraw()
  }
  
  func playNextSound() {
    var soundsIndex = 0
    let repeatMode = utility.getRepearMode()
    let randomMode = utility.getRandomMode()
    
    if let _playingGroup = self.playingGroup {
      // RepeateAllまたはランダム再生の場合のみ続行
      if repeatMode != .noRepeate {
        // 現在再生中の音声取得
        if let _selectedSound = _playingGroup.selectedSound {
          if _playingGroup.soundInfos.count > 0 {
            
            if randomMode {
              soundsIndex = Int.random(in: 0..<_playingGroup.soundInfos.count - 1)
            } else {
              // 現在再生中のSoundのインデックス取得
              if let _playingSoundIndex = _playingGroup.soundInfos.firstIndex(where: { $0.id == _selectedSound.id }) {
                if repeatMode == .repeateAll {
                  if(_playingSoundIndex + 1 < _playingGroup.soundInfos.count) {
                    soundsIndex = _playingSoundIndex + 1
                  }
                } else if repeatMode == .repeateOne {
                  soundsIndex = _playingSoundIndex
                }
              }
            }
            // 再生
            try! self.playSound(targetGroup: self.playingGroup, targetSound: _playingGroup.soundInfos[soundsIndex])
          }
        }
      }
    }
  }
  
  func playPrevSound() {
    if let _playingGroup = self.playingGroup {
      if let _selectedSound = _playingGroup.selectedSound {
        if _playingGroup.soundInfos.count > 0 {
          if let _selectedSoundIndex = _playingGroup.soundInfos.firstIndex(where: { $0.id == _selectedSound.id }) {
            if(_selectedSoundIndex - 1 >= 0) {
              // Pause
              self.player.pauseSound()
              
              try! self.playSound(targetGroup: self.playingGroup, targetSound: _playingGroup.soundInfos[_selectedSoundIndex - 1])
            }
          }
        }
      }
    }
  }
  
  // 音声の現在再生時間
  func getPlayingTime() -> TimeInterval {
    if let _selectedSound = self.getPlayingSound() {
      return _selectedSound.currentTime
    }
    return TimeInterval.zero
  }
  
  func getPlayingSound() -> SoundInfo? {
    if let _playingGroup = self.playingGroup {
      return _playingGroup.selectedSound
    }
    return nil
  }
  
  /// グループ情報保存
  func saveGroupInfos() {
    // 再生中の音声の時間セット
    if let _playingSound = self.getPlayingSound() {
      _playingSound.currentTime = self.player.getCurrentTime()
    }
    utility.saveGroupInfo(outputInfos: self.fullSoundInfos)
    utility.saveGroupInfo(outputInfos: self.folderInfos)
    utility.saveGroupInfo(outputInfos: self.playListInfos)
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
        if let _docPath = utility.getDocumentDirectory() {
          let oldFullPath = _docPath.appendingPathComponent(oldGroupName)
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
        if let _docPath = utility.getDocumentDirectory() {
          let removePath = _docPath.appendingPathComponent(_targetGroup.text)
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
  
  
  // 現在音声再生（保存されている音声再生）
  func playCurrentSound() {
    if let _playingGroup = self.playingGroup {
      if let _playingSound = self.getPlayingSound() {
        do {
          try self.playSound(targetGroup: _playingGroup, targetSound: _playingSound, volume: self.volome)
          
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
}
