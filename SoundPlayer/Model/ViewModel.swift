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
  var fullSoundInfo = [GroupInfo]()
  var folderInfos = [GroupInfo]()
  var playListInfos = [GroupInfo]()
  
  var currentGroup: GroupInfo? = nil
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

    self.fullSoundInfo = [GroupInfo]()
    self.fullSoundInfo.append(GroupInfo(text: "Full Sound"))
    self.fullSoundInfo[0].soundInfos = self.soundInfos

    // Playerデリゲート
    player.delegate = self
    
    // イヤホン
    self.player.addRemoteCommandEvent()
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
  
  /// 対象のグループを変更する  PPPPP
  func changeGroup(targetGroup: GroupInfo){
    self.currentGroup = targetGroup
    
    // PlayModeの初期化
    self.currentGroup?.initPlayMode()
  }

  func createSoundInfo() {
    utility.getFiles(byExtensionConditions: utility.SOUND_FILE_EXTENSIONS).forEach { item in
      self.soundInfos.append(SoundInfo(fileName: item))
    }
    
    // ソート（フォルダ名＋ファイル名）
    self.soundInfos.sort{
      /*
       let d0 = $0.getFileFullPath()?.absoluteString ?? ""
       let d1 = $1.getFileFullPath()?.absoluteString ?? ""
       return d0 < d1
       */
      let d0 = $0.fullPath?.absoluteString ?? ""
      let d1 = $1.fullPath?.absoluteString ?? ""
      return d0 < d1
    }
  }
  
  /// フォルダ情報作成
  func createFolderInfo() {   // 移動済
    self.folderInfos = [GroupInfo]()
    
    // URLのパスコンポーネントを取得
    self.soundInfos.forEach{
      item in
      if let folder = self.folderInfos.first(where: {$0.text == item.foldersName}){
        folder.soundInfos.append(item.copy())
      } else {
        self.folderInfos.append(GroupInfo(text: item.foldersName, soundInfos: [item.copy()]))
      }
    }
  }

  /// PlayList情報Json入力
  func getPlayListInfo() {   // 移動済
    self.playListInfos = utility.getPlayListInfo().sorted { $0.sortKey < $1.sortKey }
  }

  /*
  /// グループ情報Json入力
  func getGroupInfo(url: URL) -> [GroupInfo] {
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      return try decoder.decode([GroupInfo].self, from: data)
    } catch {
      print("Error reading contents of directory: \(error)")
    }
    return [GroupInfo]()
  }
   */
  
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

          // 現在再生中の音源を保存
          utility.SaveCurrentSound(url: _targetSound.path)
          
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

    /*
    if let _currentGroup =  self.currentGroup {
      if let _targetSound = _currentGroup.getPlayTargetSound() {
        // 再生 or 停止
        self.playSound(targetSound: _targetSound)
        
      }
    } else {
      print("ViewModelのcurrentGroup未設定")
    }
    // 再描画
    redraw()
     */
    
    /*
     if(self.playMode == .play){
     self.playerLib.pauseSound()
     } else {
     if let _currentGroup = self.currentGroup {
     if let _selectedSound = _currentGroup.soundInfos.first(where: {$0.isSelected == true}){
     self.playSound(targetSound: _selectedSound)
     } else {
     // 選択されているものが無いので先頭の曲を再生
     self.playSound(targetSound: self.currentGroup?.soundInfos[0])
     }
     } else {
     print("ViewModelのcurrentGroup未設定")
     }
     }
     */
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
