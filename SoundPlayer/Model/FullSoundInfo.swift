//
//  FullSoundInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/03/21.
//

class FullSoundInfo: GroupInfo {
  init(text: String, soundInfos: [SoundInfo] = [SoundInfo](), repeatMode: RepeatMode = RepeatMode.repeateAll, comment: String = "", sortKey: Int = 0) {
    super.init(groupType: GroupType.FullSound ,text: text, soundInfos: soundInfos, repeatMode: repeatMode, comment: comment, sortKey: sortKey)
  }
  
  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
}
