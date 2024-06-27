//
//  DebugLogView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/06/25.
//

import SwiftUI

struct DebugLogView: View {
  //  private var debugLogMng = DebugLogManager()
  @State private var debugLogItems = [DebugLogItemModel]()
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: {
          self.debugLogItems = utility.readDebugLog()
        }
               , label: {Image(systemName: "arrow.counterclockwise")})
        Spacer()
        Button(action: {
          utility.clearDebugLog()
          self.debugLogItems = [DebugLogItemModel]()
        }
               , label: {Image(systemName: "trash")
          .foregroundStyle(.red)})
        Spacer()
      }
      ScrollView {
        ForEach(self.debugLogItems, id: \.id) { item in
          HStack {
            Text(item.dateTimeStr)
            Text(item.debugLog)
            Spacer()
          }
        }
      }
      .onAppear() {
        self.debugLogItems = utility.readDebugLog()
      }
    }
  }
}

#Preview {
  DebugLogView()
}

/*
/// Debugログ管理
class DebugLogManager {
  private let FILE_NAME = ".DebugLog.log"
  private var debugLogItems = [DebugLogItemModel]()
  // 消去
  func clearDebugLog() {
    do {
      if let _DocUrl = utility.getDocumentDirectory() {
        let fullPath = _DocUrl.appendingPathComponent(self.FILE_NAME)
        try "".write(to: fullPath, atomically: true, encoding: .utf8)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  /// 保存
  func saveDebugLog() {
    do {
      // Group情報の配列をjsonDataにエンコード
      let jsonData = try JSONEncoder().encode(self.debugLogItems)
      
      // JSONデータをStringに変換
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        if let _DocUrl = utility.getDocumentDirectory() {
          let fullPath = _DocUrl.appendingPathComponent(self.FILE_NAME)
          try jsonString.write(to: fullPath, atomically: true, encoding: .utf8)
        }
      } else {
        print("Failed to convert JSON data to string.")
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  /// 読み込み
  func readDebugLog() -> [DebugLogItemModel] {
    do {
      if let _DocUrl = utility.getDocumentDirectory() {
        let fullPath = _DocUrl.appendingPathComponent(self.FILE_NAME)
        let jsonString = try String(contentsOf: fullPath)
        if let jsonData = jsonString.data(using: .utf8) {
          return try JSONDecoder().decode([DebugLogItemModel].self, from: jsonData)
        }
      }
    } catch {
      print(error.localizedDescription)
    }
      
    return [DebugLogItemModel]()
  }

  
  func addDebugLog(debugLogItem: DebugLogItemModel) {
    self.debugLogItems.append(debugLogItem)
  }
}
*/

/// デバッグログModel
class DebugLogItemModel: Codable, Identifiable {
  var dateTime: Date
  var dateTimeStr: String {
    get {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .medium
      // Japanese Locale (ja_JP)
      dateFormatter.locale = Locale(identifier: "ja_JP")
      
      return dateFormatter.string(from: self.dateTime)
    }
  }
  var debugLog: String
  init(dateTime: Date = Date(), debugLog: String) {
    self.dateTime = dateTime
    self.debugLog = debugLog
  }
}
