//
//  FullSoundInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/03/21.
//

class FullSoundInfo: GroupInfo {
  init(text: String, soundInfos: [SoundInfo] = [SoundInfo](), comment: String = "", sortKey: Int = 0, isRandom: Bool = false) {
    super.init(groupType: GroupType.FullSound ,text: text, soundInfos: soundInfos, comment: comment, sortKey: sortKey)
  }
  
  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  override func renameFolder(newFolderName: String) throws {
    
  }
  
  override func removeFolder() throws {
    
  }
}
