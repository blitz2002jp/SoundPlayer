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
  
  var currentFileName: String {
    get {
      if let _currentSound = self.getCurrentSelectedSound() {
        return _currentSound.fileName
      }
      return ""
    }
  }
  
  var currentSoundDuration: TimeInterval {
    get {
      return utility.getCurrentSoundDuration()
    }
    set(duration) {
      utility.saveCurrentSoundDuration(currentSoundDuration: duration)
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
  
  // 再生時間の通知 デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    var currentTimeStr: String = utility.timeIntervalToString(timeFormat: .HHMMSS, timeInterval: currentTime)
    self.currentTime = currentTime
    
    // 音声情報に現在再生時間をセット
    if let _currentSound = self.getCurrentSelectedSound() {
      _currentSound.currentTime = currentTime
    }
    
    // 現在再生時間の保存
    utility.saveCurrentPlayTime(currentTime: currentTimeStr)
    
    // 再描画
    self.redraw()
  }
  
  // 再生終了の通知 デリゲート
  func notifyTermination() {
    if let _currentSound = self.getCurrentSelectedSound() {
      _currentSound.currentTime = TimeInterval.zero
      self.playNextSound()
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
    if newTime <= self.currentSoundDuration {
      self.player.setPlayPosition(position: newTime)
    }
  }
  
  /// グループ再生
  func playGroup(groupInfo: GroupInfo?) throws {
    try self.playSound(targetGroup: groupInfo, targetSound: self.getCurrentSelectedSound())
  }
  
  /// 指定された音声を再生
  func playSound(targetGroup: GroupInfo?, targetSound: SoundInfo?) throws {
    
    if let _targetGroup = targetGroup {
      if let _targetSound = targetSound {
        
        // 選択状態セット
        _targetGroup.selectedSound = _targetSound
        
        // 音声の長さを保存
        self.currentSoundDuration = _targetSound.duration()
#if DEBUG
        print("duration : \(utility.timeIntervalToString(timeInterval: self.currentSoundDuration))")
#endif
        
        if self.player.isPlaying {
          // Pause
          self.player.pauseSound()
          
          if let _currentSound = self.getCurrentSelectedSound() {
            if let _oldPath = _currentSound.path {
              if let _newPath = _targetSound.path {
                if _oldPath.absoluteString != _newPath.absoluteString {
                  
                  // Play
                  try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: utility.getCurrentVolume())
                }
              }
            }
          }
        } else {
          // Play
          try self.player.Play(url: _targetSound.fullPath, startTime: _targetSound.currentTime, volume: utility.getCurrentVolume())
        }
        // Current Gropu設定
        self.currentGroup = _targetGroup
        
      }
    }
    
    // 再表示
    self.redraw()
  }
  
  func playNextSound() {
    if let _currentGroup = self.currentGroup {
      if let _currentSound = _currentGroup.selectedSound {
        if _currentGroup.soundInfos.count > 0 {
          if let _currentSoundIndex = _currentGroup.soundInfos.firstIndex(where: { $0.id == _currentSound.id }) {
            if(_currentSoundIndex + 1 < _currentGroup.soundInfos.count){
              // Pause
              self.player.pauseSound()

              try! self.playSound(targetGroup: self.currentGroup, targetSound: _currentGroup.soundInfos[_currentSoundIndex + 1])
            }
          }
        }
      }
    }
  }

  func playPrevSound() {
    if let _currentGroup = self.currentGroup {
      if let _currentSound = _currentGroup.selectedSound {
        if _currentGroup.soundInfos.count > 0 {
          if let _currentSoundIndex = _currentGroup.soundInfos.firstIndex(where: { $0.id == _currentSound.id }) {
            if(_currentSoundIndex - 1 >= 0) {
              // Pause
              self.player.pauseSound()

              try! self.playSound(targetGroup: self.currentGroup, targetSound: _currentGroup.soundInfos[_currentSoundIndex - 1])
            }
          }
        }
      }
    }
  }
  
  // 音声の現在再生時間
  func getCurrentTime() -> TimeInterval {
    if let _selectedSound = self.getCurrentSelectedSound() {
#if DEBUG
      print("getCurrentTime:\(_selectedSound.currentTimeStr)")

      print("\(_selectedSound.fileNameNoExt) : \(_selectedSound.currentTimeStr)")
#endif
      return _selectedSound.currentTime
    }
    return TimeInterval.zero
  }
  
  func getCurrentSelectedSound() -> SoundInfo? {
    if let _currentGroup = self.currentGroup {
      return _currentGroup.selectedSound
    }
    return nil
  }
  
  // 再描画
  func redraw(){
    objectWillChange.send()
  }
}
