//
//  GroupInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

// グループタイプ
enum GroupType: String, Codable {
  case FullSound
  case Folder
  case PlayList
}

class MyClass {
    var property: Int = 42
}

class GroupInfo: Codable, Identifiable{
  var groupType: GroupType                      // グループタイプ
  var text: String                              // 表示名
  var soundInfos: [SoundInfo]                   // 音声情報
  var repeatMode: RepeatMode                    // 繰り返し
  var comment: String                           // コメント
  var sortKey: Int                              // ソートキー
  
  var selectedSound: SoundInfo? {               // 選択音声
    get {
      return self.soundInfos.first(where: {$0.isSelected == true})
    }
    
    set(soundInfo) {
      if let _soundInfo = soundInfo {
        self.soundInfos.forEach { item in
          if _soundInfo.path == item.path {
            item.isSelected = true
          } else {
            item.isSelected = false
          }
        }
      }
    }
  }
  
  init(groupType: GroupType, text: String, soundInfos: [SoundInfo] = [SoundInfo](), repeatMode: RepeatMode = RepeatMode.repeateAll, comment: String = "", sortKey: Int = 0) {
    self.groupType = groupType
    self.text = text
    self.soundInfos = soundInfos
    self.repeatMode = repeatMode
    self.comment = comment
    self.sortKey = sortKey
  }
  
  // Json Decode用のinit(Json Decoderから呼ばれる)
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    groupType = try container.decode(GroupType.self, forKey: .groupType)
    text = try container.decode(String.self, forKey: .text)
    soundInfos = try container.decode([SoundInfo].self, forKey: .soundInfos)
    repeatMode = try container.decode(RepeatMode.self, forKey: .repeatMode)
    comment = try container.decode(String.self, forKey: .comment)
    sortKey = try container.decode(Int.self, forKey: .sortKey)
  }
  
  enum CodingKeys: String, CodingKey {
    case groupType
    case text
    case soundInfos
    case repeatMode
    case comment
    case sortKey
  }
  
}
