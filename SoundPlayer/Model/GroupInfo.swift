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

class GroupInfo: Codable, Identifiable {
  var id: String
  var groupType: GroupType = .FullSound                     // グループタイプ
  var text = ""                             // 表示名
  var displayText: String {                             // 表示名
    get {
      if self.text == "" {
        return "Document"
      }
      return self.text
    }
  }
  var soundInfos = [SoundInfo]()                   // 音声情報
  var comment = ""                           // コメント
  var sortKey = 0                              // ソートキー
  
  var folder: URL? {
    get {
      return utility.getDocumentPath(fileName: self.text)
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
  
  init(id: String = UUID().uuidString, groupType: GroupType, text: String, soundInfos: [SoundInfo] = [SoundInfo](), comment: String = "", sortKey: Int = 0) {
    self.id = id
    self.groupType = groupType
    self.text = text
    self.soundInfos = soundInfos
    self.comment = comment
    self.sortKey = sortKey
  }
  
  init(id: String = UUID().uuidString) {
    self.id = id
  }
  
  func copy(copyTo: GroupInfo) -> GroupInfo {
    copyTo.groupType = self.groupType
    copyTo.text = self.text
    self.soundInfos.forEach { item in copyTo.soundInfos.append(item.copy())}
    copyTo.comment = self.comment
    copyTo.sortKey = self.sortKey

    return copyTo
  }

  /// Sound Fileの削除
  func removeSoundFile(removeSound: SoundInfo) {
    if let _fileUrl = removeSound.fullPath {
      do {
        // ファイル削除
        try FileManager.default.removeItem(at: _fileUrl)
      }catch {
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
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
  
  /*
   //PlayList
   /// Sound Infoの削除
   override func removeSoundFile(removeSound: SoundInfo) {
     // 参照の削除
     self.soundInfos.removeAll(where: {$0.fullPath == removeSound.fullPath})
   }

   // Full Sound
   override func renameFolder(newFolderName: String) throws {
     
   }
   
   override func removeFolder() throws {
     
   }

   
   
   // Folder
   
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

   
   */
}

