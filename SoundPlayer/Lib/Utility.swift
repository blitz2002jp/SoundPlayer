//
//  Utility.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

struct utility {
  private static let SETTING_FILE_DIRECTORY = "Setteing"
  private static let PLAY_LIST_INFO_KEY = "PLAY_LIST_INFO"
  private static let CURRENT_SOUND_SAVE_KEY = "CurrentSound"
  private static let IS_SAND_BOX_KEY = "isSandBox"
  static let SOUND_FILE_EXTENSIONS = ["mp3"]
  static let SANDBOX_DIRECRORY = "private"
  
  /// Documentディレクトリ取得
  static func getDocumentDirectory() -> URL?{
    if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      // サンドボックスのフォルダを付加
      if utility.isSoundBox() {
        return URL(fileURLWithPath:String("\(utility.SANDBOX_DIRECRORY)\(docDir.path)"))
      } else {
        return docDir
      }
    }
    return nil
  }
  
  /// 時分秒に分解
  static func decomposeTimeInterval(_ timeInterval: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
    let hours = Int(timeInterval / 3600)
    let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
    return (hours, minutes, seconds)
  }
  
  static func timeIntervalToString(timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.hour, .minute, .second]
    
    return formatter.string(from: timeInterval)!
  }
  
  static func stringToTimeInterval(HHMMSS: String) -> TimeInterval {
    let hhmmssArray = HHMMSS.components(separatedBy: ":")
    
    if hhmmssArray.count != 3 {
      return TimeInterval.zero
    }
    return TimeInterval(Int(hhmmssArray[0])! * 3600 + Int(hhmmssArray[1])! * 60 + Int(hhmmssArray[2])!)
  }
  
  static func getHMS(time: TimeInterval) -> (hour: Int, minits: Int, seconds: Int) {
    // 時間、分、秒に分解する
    let hours = Int(time / 3600)
    let minutes = Int((time.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(time.truncatingRemainder(dividingBy: 60))
    
    return (hours, minutes, seconds)
    
  }
  
  static func getFiles(byExtensionConditions extensionConditions: [String]) -> [URL]{
    if let documentsPath = utility.getDocumentDirectory() {
      // Documentディレクトリ以下のすべてのファイルを列挙する
      if let enumerator = FileManager.default.enumerator(at: documentsPath, includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
        //enumeratorを配列に変換
        if let files = enumerator.allObjects as? [URL] {
          // 拡張子(mp3)でファイルをフィルタ
          return files.filter { file in
            return extensionConditions.contains { condition in
              file.pathExtension.lowercased() == condition.lowercased()
            }
          }
        }
      }
    }
    return [URL]()
  }
  
  /// PlayList情報Json入力
  static func getPlayListInfo() -> [GroupInfo]{   // 移動済
    // UserDefaultsから保存データ取得
    if let jsonString = UserDefaults.standard.string(forKey: PLAY_LIST_INFO_KEY) {
      // String型データをData型に変換
      if let jsonData = jsonString.data(using: .utf8) {
        do {
          // JsonDataをGroupInfo配列に変換
          return try JSONDecoder().decode([GroupInfo].self, from: jsonData)
        } catch {
          print("Error reading contents of directory: \(error)")
        }
      }
    }
    return [GroupInfo]()
  }
  
  /// PlayList情報Json出力
  static func writePlayListInfo(outputInfos:[GroupInfo]) throws {
    // GroupInfoの配列をjsonDataにエンコード
    let jsonData = try JSONEncoder().encode(outputInfos)
    
    // JSONデータをStringに変換
    if let jsonString = String(data: jsonData, encoding: .utf8) {
      // UserDefaultsにPlayListデータを保存
      UserDefaults.standard.setValue(jsonString, forKey: PLAY_LIST_INFO_KEY)
    } else {
        print("Failed to convert JSON data to string.")
    }
  }
  
  /// 現在再生中の音源保存
  static func SaveCurrentSound(url: URL?) {
    if let _url = url {
      UserDefaults.standard.set(_url, forKey: CURRENT_SOUND_SAVE_KEY)
    }
  }
  
  /// 現在再生中の音源取得
  static func GetCurrentSound() -> URL? {
    if let loadedText = UserDefaults.standard.url(forKey: CURRENT_SOUND_SAVE_KEY) {
      return loadedText
    }else{
      return nil
    }
  }
  
  /// 環境がサンドボックスか
  static func isSoundBox() -> Bool{
    // Get Temporary Directory
    let tmpDir = NSTemporaryDirectory().split(separator: "/")
    if tmpDir.count > 0 {
      if tmpDir[0] == self.SANDBOX_DIRECRORY {
        return true
      }
    }
    
    return false
  }
  
}
