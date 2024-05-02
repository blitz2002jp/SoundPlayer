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


class ViewModel: ObservableObject, PlayerDelegate {
  
  var emptyArtWork: Data?
  
  // 音声データ
  var soundInfos = [SoundInfo]()
  var fullSoundInfos = [FullSoundInfo]()
  var folderInfos = [FolderInfo]()
  var playListInfos = [PlayListInfo]()
  
  
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
  
  
  // Player
  var player = Player()
  
  
  init() {
    createSoundInfo()
    createFolderInfo()
    getPlayListInfo()
    
    // 音声の選択フラグを設定
    self.setSelectedSound(newGroupInfos: self.fullSoundInfos)
    self.setSelectedSound(newGroupInfos: self.folderInfos)
    
    // Playerデリゲート
    player.delegate = self
    
    // イヤホン
    self.player.addRemoteCommandEvent()
    
    // ArtWork無し用の画像
    if let path = Bundle.main.url(forResource: "EmptyArtWork.png", withExtension: "") {
      if let image = UIImage(named: path.path()) {
          if let imageData = image.pngData() {
            self.emptyArtWork = imageData
          }
      }

    }

  }
  
  /// 音声の選択フラグを設定
  func setSelectedSound(newGroupInfos: [GroupInfo]) {
    if newGroupInfos.count > 0 {
      var oldFullSoundInfos: [GroupInfo]? = nil
      
      if newGroupInfos[0] is FullSoundInfo {
        oldFullSoundInfos = utility.getFullSoundInfo()
      } else if newGroupInfos[0] is FolderInfo {
        oldFullSoundInfos = utility.getFolderInfo()
      } else if newGroupInfos[0] is PlayListInfo {
        oldFullSoundInfos = utility.getPlayListInfo()
      }
      
      if let _oldFullSoundInfos = oldFullSoundInfos {
        _oldFullSoundInfos.forEach { oldItem in
          // 一致するグループを取得
          if let newItem = newGroupInfos.first( where: { $0.text == oldItem.text }) {
            oldItem.soundInfos.forEach { oldSound in
              if let _targetSound = newItem.soundInfos.first(where: {$0.path?.absoluteString == oldSound.path?.absoluteString}) {
                _targetSound.isSelected = oldSound.isSelected
                _targetSound.currentTime = oldSound.currentTime
                
                print("\(oldSound.fileName) : \(oldSound.isSelected)")
              }
            }
          }
        }
      }
    }
  }
  
  func isPlayingSound(groupInfo: GroupInfo, soundInfo: SoundInfo) -> Bool {
    if self.player.isPlaying {
      if let _playingGroup = self.playingGroup {
        if let _playingSound = self.getPlayingSound() {
          if _playingGroup.text == groupInfo.text
              && _playingGroup.groupType == groupInfo.groupType {
            if _playingSound.fullPath?.absoluteString == soundInfo.fullPath?.absoluteString {
              print("isPlayingSound:\(soundInfo.fileNameNoExt) : TRUE")

              return true
            }
          }
        }
      }
    }
    return false
  }
  
  // 再生終了の通知 デリゲート
  func notifyTermination() {
    if let _playingSound = self.getPlayingSound() {
      _playingSound.currentTime = TimeInterval.zero
      self.playNextSound()
    }
  }

  /// デバイスに登録されているファイルからSoundInfoを作成する
  func createSoundInfo() {
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
    self.folderInfos = [FolderInfo]()
    
    // URLのパスコンポーネントを取得
    self.soundInfos.forEach{
      item in
      let copyItem = item.copy()
      if let folder = self.folderInfos.first(where: {$0.text == item.foldersName}){
        folder.soundInfos.append(copyItem)
      } else {
        self.folderInfos.append(FolderInfo(text: item.foldersName, soundInfos: [copyItem]))
      }
    }
  }

  /// PlayList情報Json入力
  func getPlayListInfo() {   // 移動済
    self.playListInfos = utility.getPlayListInfo().sorted { $0.sortKey < $1.sortKey }
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
    let newTime = self.player.getPlayTime() + seconds
    if newTime <= self.playingSoundDuration {
      self.player.setPlayPosition(position: newTime)
    }
  }
  
  /// グループ再生
  func playGroup(targetGroupInfo: GroupInfo?) throws {
    if let _targetGroupInfo = targetGroupInfo {
      if let _selectedSound = _targetGroupInfo.selectedSound {
        try self.playSound(targetGroup: _targetGroupInfo, targetSound: _targetGroupInfo.selectedSound)
      } else {
        if _targetGroupInfo.soundInfos.count > 0 {
          try self.playSound(targetGroup: _targetGroupInfo, targetSound: _targetGroupInfo.soundInfos[0])
        }
      }
    }
  }
  
  /// 指定された音声を再生
  func playSound(targetGroup: GroupInfo?, targetSound: SoundInfo?) throws {

    // 現在の音声のPath取得
    var oldPath = ""
    if let _playingSound = self.getPlayingSound() {
      if let _oldPath = _playingSound.path {
        oldPath = _oldPath.absoluteString
        print("oldPath: \(oldPath)")
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
          
          if let _newPath = _targetSound.path {
            if oldPath != _newPath.absoluteString {
              // Play
              try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: utility.getPlayingSoundVolume())
            }
          }
        } else {
          // Play
          try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: utility.getPlayingSoundVolume())
        }
        // Playing Gropu設定
        self.playingGroup = _targetGroup

        // 現在の情報保存
        self.saveGroupInfos()

      }
    }
    
    // 再表示
    self.redraw()
  }
  
  func playNextSound() {
    var soundsIndex = 0
    if let _playingGroup = self.playingGroup {
      // RepeateAllまたはランダム再生の場合のみ続行
      if _playingGroup.repeatMode == .repeateAll
          || _playingGroup.isRandom == true {
        // 現在再生中の音声取得
        if let _selectedSound = _playingGroup.selectedSound {
          if _playingGroup.soundInfos.count > 0 {
            if _playingGroup.isRandom {
              soundsIndex = Int.random(in: 0..<_playingGroup.soundInfos.count - 1)
            } else {
              // 現在再生中のSoundのインデックス取得
              if let _playingSoundIndex = _playingGroup.soundInfos.firstIndex(where: { $0.id == _selectedSound.id }) {
                if(_playingSoundIndex + 1 < _playingGroup.soundInfos.count) {
                  soundsIndex = _playingSoundIndex + 1
                } else {
                }
              } //
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
#if DEBUG
      print("getCurrentTime:\(_selectedSound.currentTimeStr)")

      print("\(_selectedSound.fileNameNoExt) : \(_selectedSound.currentTimeStr)")
#endif
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
  
  //
  func saveGroupInfos() {
    utility.saveGroupInfo(outputInfos: self.fullSoundInfos)
    utility.saveGroupInfo(outputInfos: self.folderInfos)
    utility.saveGroupInfo(outputInfos: self.playListInfos)
  }
  
  /// Soundの削除
  func removeSound(targetSound: SoundInfo) {
    if let _selectedGroup = self.selectedGroup {
      // PlayList以外はファイル削除
      if _selectedGroup is PlayListInfo {
        // PlayListは参照のみ削除
        _selectedGroup.removeSoundReference(removeSound: targetSound)
      } else {
        // ファイルの削除
        _selectedGroup.removeSoundFile(removeSound: targetSound)

        // 参照の削除
        utility.removeReference(targetGroups: self.fullSoundInfos, targetSound: targetSound)
        utility.removeReference(targetGroups: self.folderInfos, targetSound: targetSound)
        utility.removeReference(targetGroups: self.playListInfos, targetSound: targetSound)
        self.soundInfos.removeAll(where: {$0.fullPath == targetSound.fullPath})
      }
    }
  }
  
  func renameGroupName(targetGroup: GroupInfo, newGroupName: String) throws {
    // フォルダ名変更
    try targetGroup.renameFolder(newFolderName: newGroupName)
    targetGroup.text = newGroupName
    
    if targetGroup is FolderInfo {
      // 保存
      utility.saveGroupInfo(outputInfos: self.folderInfos)

    } else if targetGroup is PlayListInfo {
      // 保存
      utility.saveGroupInfo(outputInfos: self.playListInfos)
    }
  }
  
  func removeGroup(targetGroup: GroupInfo) throws {
    if targetGroup is FolderInfo {
      // フォルダ削除
      try targetGroup.removeFolder()
      
      // 配列から削除
      self.folderInfos.removeAll(where: {$0.text == targetGroup.text})
      
      // 保存
      utility.saveGroupInfo(outputInfos: self.folderInfos)

    } else if targetGroup is PlayListInfo {
      // 配列から削除
      self.playListInfos.removeAll(where: {$0.text == targetGroup.text})

      // 保存
      utility.saveGroupInfo(outputInfos: self.playListInfos)
    }

    // 再描画
    self.redraw()
  }
  
  // 再描画
  func redraw(){
    print("redraw")
    objectWillChange.send()
  }
}
