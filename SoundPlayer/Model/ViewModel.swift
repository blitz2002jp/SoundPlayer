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
      if let _currentSoundUrl = utility.getCurrentSoundUrl() {
        if let _currentGroup = self.currentGroup {
          _currentGroup.soundInfos.forEach{ item in
          }
          return _currentGroup.soundInfos.first(where: {$0.path == _currentSoundUrl})
        }
      }
      return nil
    }
    
    set(soundInfo) {
      utility.saveCurrentSoundInfo(soundInfo: soundInfo)
    }
  }
//  var currentGroup: GroupInfo? = nil
  var currentTimeStr: String = ""
  var currentFileName: String {
    get {
      if let currentSoundUrl = utility.GetCurrentSound() {
        if let found = soundInfos.first(where: {$0.path?.absoluteString == currentSoundUrl.absoluteString}) {
          return found.fileName
        }
      }
      return ""
    }
  }
  
  // Player
  var player = Player()

  var playMode = PlayMode.play
  
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
    
    // 現在情報の設定
    /*
    if let _currentGroup = self.currentGroup {
      if let _currentSound = self.currentSound {
        print("PlayMode:\(_currentSound.playMode.rawValue) url:\(_currentSound.fullPath?.absoluteString)")
        _currentGroup.soundInfos.forEach{ item in
          if item.fullPath == _currentSound.fullPath {
            item.playMode = .pause
          } else {
            item.playMode = .stop
          }
        }
      }
    }
     */
    if let _currentSound = self.currentSound {
      _currentSound.playMode = .pause
    }
    
    if let _currentGroup = self.currentGroup {
      _currentGroup.soundInfos.forEach{ item in
        print("PlayMode:\(item.playMode.rawValue) url:\(item.path?.absoluteString)")
      }
    }
  }

  // 再生時間の通知 デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    self.currentTime = currentTime
    self.currentTimeStr = utility.timeIntervalToString(timeInterval: currentTime)
    
    // 再描画
    self.redraw()
  }
  
  // 再生終了の通知 デリゲート
  func notifyTermination() {
    var nextIndex = 0
    if let _currentGroup = self.currentGroup {
      if(_currentGroup.repeatMode == .repeateAll) {
        if let _currentSound = _currentGroup.getPlayTargetSound() {
          // 再生時間クリア
//          self.soundPlayer.currentTime = 0.0
  
          if let _currentSoundIndex = _currentGroup.soundInfos.firstIndex(where: { $0.id == _currentSound.id }) {
            if(_currentSoundIndex + 1 < _currentGroup.soundInfos.count){
              nextIndex = _currentSoundIndex + 1
            }
            // 次曲の選択と再生
            print(nextIndex)
// ここから(デリゲートでThrowする方法を調べる、現在はtry!で無理やり通している
//↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
            try! self.playSound(targetSound: _currentGroup.soundInfos[nextIndex])
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
      if let folder = self.folderInfos.first(where: {$0.text == item.foldersName}){
        folder.soundInfos.append(item.copy())
      } else {
        self.folderInfos.append(FolderInfo(text: item.foldersName, soundInfos: [item.copy()]))
      }
    }
  }

  /// PlayList情報Json入力
  func getPlayListInfo() {   // 移動済
    self.playListInfos = utility.getPlayListInfo().sorted { $0.sortKey < $1.sortKey }
  }

  /// PlayModeカラー
  func getPlayModeColor(playMode: SoundInfo) -> Color {
    switch playMode.playMode {
    case .play:
      return Color.blue
    case .pause:
      return Color.red
    case .stop:
      return Color.black
    }
  }
  
  /// 指定された音声を再生
  func playSound(targetSound: SoundInfo?) throws {
    if let _targetSound = targetSound {
      let playMode = _targetSound.playMode
      
      if let _currentGroup = self.currentGroup {
        // グループ内のSoundをすべてSTOPして指定された曲をPLAYにする
        _currentGroup.soundInfos.forEach{ item in item.playMode = .stop }
        
        switch playMode {
        case .pause, .stop:
          _targetSound.playMode = .play
          
          // 再生
          let startTime =  _targetSound.currentTime == TimeInterval.zero ? _targetSound.startTime : _targetSound.currentTime
          let isLoop = _targetSound.repeatMode == .repeateOne ? true : false
          try self.player.Play(url: _targetSound.fullPath, startTime: startTime, isLoop: isLoop)

          // 現在再生中の音源とグループを保存
          self.currentGroup = _currentGroup
          self.currentSound = _targetSound
          
        case .play:
          _targetSound.playMode = .pause
          
          // Pause
          self.player.pauseSound()
        }
      }
    }
    // 再描画
    redraw()
  }
  
  // Pause
  func pauseSound(){
    self.player.pauseSound()
  }

  /// ボリューム設定
  func setVolume(volume: Float) {
    self.player.setVolume(volume: volume)
  }

  /// 再生時間設定
  func setPlayPosition(time: Double) {
    self.player.setPlayPosition(position: time)
  }
  
  /// 再生位置調整
  func adjustPlayPosition(seconds: Double) {
    let newTime = self.getCurrentTime() + seconds
    print("NewTime:\(utility.timeIntervalToString(timeInterval: newTime))")
    print("PlayTime:\(utility.timeIntervalToString(timeInterval: self.getPlayTime()))")
    if newTime <= self.getPlayTime() {
      self.player.setPlayPosition(position: newTime)
    }
  }

  /// グループ再生
  func playGroup(targetGroup: GroupInfo? = nil) throws {
    if let _targetGroup = targetGroup {
      self.currentGroup = targetGroup
      if let _targetSound = _targetGroup.getPlayTargetSound() {
        // 再生 or 停止
        try self.playSound(targetSound: _targetSound)
      }
    }
  }

  /// 選択中のSoundInfo取得
  func getCurrentSound() -> SoundInfo?{
    return self.currentGroup?.soundInfos.first(where: { $0.playMode == .play || $0.playMode == .pause })
  }
  
  func getCurrentTime() -> TimeInterval {
    self.player.getCurrentTime()
  }

  func getPlayTime() -> TimeInterval {
    self.player.getPlayTime()
  }

  // 再描画
  func redraw(){
    objectWillChange.send()
  }
}
