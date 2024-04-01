//
//  ViewModel.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import SwiftUI

enum PlayMode: String, Codable{
  case play
  case pause
  case stop
}

enum RepeatMode: String, Codable{
  case noRepeate    // 繰り返しなし
  case repeateOne   // １曲繰り返し
  case repeateAll   // 全曲繰り返し
 }


class ViewModel: ObservableObject, PlayerDelegate {
  // 現在再生時間
  @Published var currentTime: TimeInterval = TimeInterval.zero
  
  // 音声データ
  var soundInfos = [SoundInfo]()
  var fullSoundInfos = [FullSoundInfo]()
  var folderInfos = [FolderInfo]()
  var playListInfos = [PlayListInfo]()
  
  
  var volome: Float {
    get {
      return utility.getCurrentVolume()
    }
    
    set(volume) {
      utility.saveCurrentVolume(currentVolume: volume)
      self.player.setVolume(volume: volume)
    }
  }
  
  // 現在のグループ情報
  var currentGroup: GroupInfo? {
    get {
      // グループタイプにより使うデータを判断
      var groupInfos = [GroupInfo]()
      switch utility.getCurrentGroupType() {
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
      if let groupText = utility.getCurrentGroupText() {
        if let groupInfo = groupInfos.first(where: {$0.text == groupText}) {
          return groupInfo
        }
      }
      return nil
    }

    set(groupInfo) {
        // 現在のグループ情報を保存
        utility.saveCurrentGroupInfo(groupInfo: groupInfo)
    }
  }
  
  // 現在の音声情報
  var currentSound: SoundInfo? {
    get {
      if let _currentGroup = self.currentGroup {
        if let _selectedSoundPath = utility.getSelectedSoundPath(groupInfo: _currentGroup) {
          return _currentGroup.soundInfos.first(where: {$0.path?.absoluteString == _selectedSoundPath.absoluteString})
        }
      }
      return nil
    }
    
    set(soundInfo) {
      //      utility.saveCurrentSoundInfo(soundInfo: soundInfo)
      if let _soundInfo = soundInfo {
        if let _currentGroup = self.currentGroup {
          utility.saveSelectedSoundUrl(soundInfo: _soundInfo, groupInfo: _currentGroup)
        }
      }
    }
  }
  var currentTimeStr: String = ""
  var currentFileName: String {
    get {
      if let _currentGroup = self.currentGroup {
        if let _selectedSoundPath = utility.getSelectedSoundPath(groupInfo: _currentGroup) {
          return _selectedSoundPath.lastPathComponent
        }
      }
      return ""
    }
  }
  
//  var playMode = PlayMode.play
  var playMode: PlayMode {
    get {
      if self.player.isPlaying() == true {
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
    
    self.fullSoundInfos = [FullSoundInfo]()
    self.fullSoundInfos.append(FullSoundInfo(text: "Full Sound"))
    self.fullSoundInfos[0].soundInfos = self.soundInfos
    
    // Playerデリゲート
    player.delegate = self
    
    // イヤホン
    self.player.addRemoteCommandEvent()
  }

  // 再生時間の通知 デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    self.currentTime = currentTime
    self.currentTimeStr = utility.timeIntervalToString(timeInterval: currentTime)
    
    // 音声情報に現在再生時間をセット
    if let _currentSound = self.currentSound {
      _currentSound.currentTimeStr = currentTimeStr
    }
    
    // 現在再生時間の保存
    utility.saveCurrentPlayTime(currentTime: currentTimeStr)
    
    // 再描画
    self.redraw()
  }
  
  // 再生終了の通知 デリゲート
  func notifyTermination() {
    var nextIndex = 0
    if let _currentGroup = self.currentGroup {
      if let _currentSound = _currentGroup.getSelectedSound() {
        if _currentGroup.soundInfos.count > 0 {
          if let _currentSoundIndex = _currentGroup.soundInfos.firstIndex(where: { $0.id == _currentSound.id }) {
            if(_currentSoundIndex + 1 < _currentGroup.soundInfos.count){
              nextIndex = _currentSoundIndex + 1
            } else {
              nextIndex = 0
            }
#if DEBUG
            // 次曲の選択と再生
            print(nextIndex)
#endif
            // ここから(デリゲートでThrowする方法を調べる、現在はtry!で無理やり通している
            //↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
            try! self.playSound(targetGroup: _currentGroup, targetSound: _currentGroup.soundInfos[nextIndex])
          }
        }
      }
    }
  }
  
  /// デバイスに登録されているMP3ファイルからSoundInfoを作成する
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
  func setPlayPosition(time: Double) {
    self.player.setPlayPosition(position: time)
  }
  
  /// 再生位置調整
  func adjustPlayPosition(seconds: Double) {
    let newTime = self.getCurrentTime() + seconds
    if newTime <= self.getPlayTime() {
      self.player.setPlayPosition(position: newTime)
    }
  }

  /// グループ再生
  func playGroup(groupInfo: GroupInfo) throws {
    if let _targetSound = groupInfo.getSelectedSound() {
      try self.playSound(targetGroup: groupInfo, targetSound: _targetSound)
    }
  }
  
  /// 指定された音声を再生
  func playSound(targetGroup: GroupInfo, targetSound: SoundInfo) throws {
    
    if self.player.isPlaying() {
      // Pause
      self.player.pauseSound()
      
      if let _currentSound = self.currentSound {
        if let _oldPath = _currentSound.path {
          if let _newPath = targetSound.path {
            if _oldPath.absoluteString != _newPath.absoluteString {
              
              // Play
              try self.player.Play(url: targetSound.fullPath, volume: utility.getCurrentVolume())
            }
          }
        }
      }
    } else {
      // Play
      try self.player.Play(url: targetSound.fullPath,  startTime: utility.stringToTimeInterval(HHMMSS: utility.getCurrentPlayTime()), volume: utility.getCurrentVolume())
    }
    // Current Gropu設定
    self.currentGroup = targetGroup
    
    // Current Sound設定
    self.currentSound = targetSound
  }

  func getCurrentTime() -> TimeInterval {
    self.player.getCurrentTime()
  }

  func getPlayTime() -> TimeInterval {
    self.player.getPlayTime()
  }

  // 再描画
  func redraw(){
//    objectWillChange.send()
  }
}
