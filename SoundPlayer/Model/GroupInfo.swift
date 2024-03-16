//
//  GroupInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

class GroupInfo: Codable, Identifiable{
  var text: String                              // 表示名
  var soundInfos: [SoundInfo]                   // 音声情報
  var repeatMode: RepeatMode                    // 繰り返し
  var comment: String                           // コメント
  var sortKey: Int                              // ソートキー

  
  init(text: String, soundInfos: [SoundInfo] = [SoundInfo](), repeatMode: RepeatMode = RepeatMode.repeateAll, comment: String = "", sortKey: Int = 0) {
    self.text = text
    self.soundInfos = soundInfos
    self.repeatMode = repeatMode
    self.comment = comment
    self.sortKey = sortKey
  }
  
  /// PlayModeの初期化
  func initPlayMode(){
    let playingItem = self.soundInfos.first(where: {$0.playMode == .play || $0.playMode == .pause})
    soundInfos.forEach{ item in item.playMode = .stop }
    if(playingItem != nil){
      playingItem?.playMode = .pause
    }
  }
  
  /// 再生対象の取得
  func getPlayTargetSound() -> SoundInfo? {
    if let res = self.soundInfos.first(where: {$0.playMode == .play || $0.playMode == .pause}) {
      return res
    } else {
      return self.soundInfos[0]
    }
  }
  
  
}
