//
//  PlayListInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/03/21.
//

class PlayListInfo: GroupInfo {
  init(text: String, soundInfos: [SoundInfo] = [SoundInfo](), repeatMode: RepeatMode = RepeatMode.repeateAll, comment: String = "", sortKey: Int = 0) {
    super.init(groupType: GroupType.PlayList ,text: text, soundInfos: soundInfos, repeatMode: repeatMode, comment: comment, sortKey: sortKey)
  }
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}
