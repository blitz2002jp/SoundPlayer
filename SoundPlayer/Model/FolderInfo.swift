//
//  FolderInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/03/21.
//
import Foundation

class FolderInfo: GroupInfo {
  init(text: String, soundInfos: [SoundInfo] = [SoundInfo](), comment: String = "", sortKey: Int = 0, isRandom: Bool = false) {
    super.init(groupType: GroupType.Folder ,text: text, soundInfos: soundInfos, comment: comment, sortKey: sortKey)
  }
  
  required init(from decoder: any Decoder) throws {
    try super.init(from: decoder)
  }
  
  /// Folder名変更
  override func renameFolder(newFolderName: String) throws {
    if let _folder = self.folder {
      let oldFolder = _folder.path
      let newFolder = _folder.deletingLastPathComponent().appendingPathComponent(newFolderName).path
      try FileManager.default.moveItem(atPath: oldFolder, toPath: newFolder)

      try super.renameFolder(newFolderName: newFolderName)
    }
  }
  
  ///  Folder削除
  override func removeFolder() throws {
    if let _folder = self.folder {
      try super.removeFolder()
      try FileManager.default.removeItem(at: _folder)
    }
  }
}
