//
//  ListInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

// グループタイプ
enum ListType: String, Codable {
  case Group
  case Sound
}

class ListInfo: Codable, Identifiable{
  // リストタイプ
  var type: ListType = .Sound

  // 子情報
  var children = [ListInfo]()                   

  // 表示名
  private var _text = ""
  var text: String {
    get {
      if self.type == .Group {
        return _text
      }
      if let _fullPath = self.fullPath {
        return _fullPath.deletingPathExtension().lastPathComponent
      }
      return ""
    }
    set(val) {
      self._text = val
    }
  }
  
  // コメント
  var comment = ""

  // ソートキー
  var sortKey = 0

  // フルパス
  var fullPath: URL?

  // 現在再生時間
  var currentTime: TimeInterval = TimeInterval.zero
  var currentTimeStr: String {
    get {
      return utility.timeIntervalToString(timeInterval: self.currentTime)
    }
  }

  // 再生開始時間
  var startTimeStr: String = ""
  var startTime: TimeInterval {
    get {
      return utility.stringToTimeInterval(HHMMSS: self.startTimeStr)
    }
  }

  // アートワーク
  var artWork: Data? {
    get {
      if let _res = utility.getArtWorkData(url: self.fullPath) {
        return _res
      }
      return utility.emptyArtwork
    }
  }
  
  init(type: ListType, text: String = "", comment: String = "", sortKey: Int = 0, fullPath: URL? = nil) {
    self.type = type
    self.text = text
    self.comment = comment
    self.sortKey = sortKey
    self.fullPath = fullPath
  }

  /*
  init(groupType: GroupType, text: String, soundInfos: [SoundInfo] = [SoundInfo](), comment: String = "", sortKey: Int = 0) {
    self.groupType = groupType
    self.text = text
    self.soundInfos = soundInfos
    self.comment = comment
    self.sortKey = sortKey
  }
  
  init(){
  }

  func copy(copyTo: GroupInfo) -> GroupInfo {
    copyTo.groupType = self.groupType
    copyTo.text = self.text
    self.soundInfos.forEach { item in copyTo.soundInfos.append(item.copy())}
    copyTo.comment = self.comment
    copyTo.sortKey = self.sortKey

    return copyTo
  }
  // Json Decode用のinit(Json Decoderから呼ばれる)
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.groupType = try container.decode(GroupType.self, forKey: .groupType)
    self.text = try container.decode(String.self, forKey: .text)
    self.soundInfos = try container.decode([SoundInfo].self, forKey: .soundInfos)
    self.comment = try container.decode(String.self, forKey: .comment)
    self.sortKey = try container.decode(Int.self, forKey: .sortKey)
  }

 enum CodingKeys: String, CodingKey {
    case groupType
    case text
    case soundInfos
    case comment
    case sortKey
  }
  /// Sound Fileの削除
  func removeSoundFile(removeSound: SoundInfo) {
    if let _fileUrl = removeSound.fullPath {
      do {
        // ファイル削除
        try FileManager.default.removeItem(at: _fileUrl)
      }catch {
        print("Remove File failure.(\(error.localizedDescription)")
      }
    }
  }
  
  /// Sound Referenceの削除(SoundInfoの配列を削除)
  func removeSoundReference(removeSound: SoundInfo) {
    self.soundInfos.removeAll(where: {$0.fullPath == removeSound.fullPath})
  }
  
  // フォルダ名の変更を行う(ただし、FolderInfoの場合）
  func renameFolder(newFolderName: String) throws {
    self.text = newFolderName
  }
  
  // フォルダの削除を行う(ただし、FolderInfoの場合）
  func removeFolder() throws {
  }
   */

}

