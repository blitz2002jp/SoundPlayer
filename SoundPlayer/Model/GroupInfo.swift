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
  var comment: String                           // コメント
  var sortKey: Int                              // ソートキー
  
  var folder: URL? {
    get {
      if let _documentPath = utility.getDocumentDirectory() {
        return _documentPath.appendingPathComponent(self.text)
      }
      return nil
    }
  }
  var selectedSound: SoundInfo? {               // 選択音声
    get {
      return self.soundInfos.first(where: {$0.isSelected == true})
    }
    
    set(soundInfo) {
      if let _soundInfo = soundInfo {
        self.soundInfos.forEach { item in
          if _soundInfo.path == item.path {
            item.isSelected = true
            utility.debugPrint(msg: "*******(TRUE)\(item.path?.absoluteString ?? "")")
          } else {
            item.isSelected = false
            utility.debugPrint(msg: "*******(FALES)\(item.path?.absoluteString ?? "")")
          }
        }
      }
    }
  }
  
  init(groupType: GroupType, text: String, soundInfos: [SoundInfo] = [SoundInfo](), comment: String = "", sortKey: Int = 0) {
    self.groupType = groupType
    self.text = text
    self.soundInfos = soundInfos
    self.comment = comment
    self.sortKey = sortKey
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
}

