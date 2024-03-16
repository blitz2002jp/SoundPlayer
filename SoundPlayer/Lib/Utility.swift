//
//  Utility.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

struct utility {
  private static let SETTING_FILE_DIRECTORY = "Setteing"
  private static let SOUND_INFO_FILE = "SoundInfo.json"
  private static let FULL_SOUND_INFO_FILE = "FullSoundInfo.json"
  private static let FOLDER_INFO_FILE = "FolderInfo.json"
  private static let PLAY_LIST_INFO_FILE = "PlayListInfo.json"
  private static let CURRENT_SOUND_SAVE_KEY = "CurrentSound"
  private static let IS_SAND_BOX_KEY = "isSandBox"
  static let SOUND_FILE_EXTENSIONS = ["mp3"]
  static let SANDBOX_DIRECRORY = "private"
  
  /// Documentディレクトリ取得
  static func getDocumentDirectory() -> URL?{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
  }
  
  /// 設定ファイルフルパス取得
  static func getSettingFileDirectory() -> URL{
    return self.getDocumentDirectory()!.appendingPathComponent(self.SETTING_FILE_DIRECTORY)
  }
  
  /// SoundInfoファイルフルパス
  static func getSettingFilePathSound() -> URL{
    return self.getSettingFileDirectory().appendingPathComponent(self.SOUND_INFO_FILE)
  }
  
  /// FullSoundInfoファイルフルパス
  static func getSettingFilePathFullSound() -> URL{
    return self.getSettingFileDirectory().appendingPathComponent(self.FULL_SOUND_INFO_FILE)
  }
  
  /// FolderSoundInfoファイルフルパス
  static func getSettingFilePathFoulder() -> URL{
    return self.getSettingFileDirectory().appendingPathComponent(self.FOLDER_INFO_FILE)
  }
  
  /// PlayListSoundInfoファイルフルパス
  static func getSettingFilePathPlayList() -> URL{
    return self.getSettingFileDirectory().appendingPathComponent(self.PLAY_LIST_INFO_FILE)
  }
  
  /// 設定ファイル・フォルダ作成
  static func createSettingFileFolder(){
    let fileManager = FileManager.default
    
    do {
      try fileManager.createDirectory(at: self.getSettingFileDirectory(), withIntermediateDirectories: true, attributes: nil)
    } catch {
      print("設定ファイル用フォルダの作成に失敗しました: \(error.localizedDescription)")
    }
  }
  
  /// ファイル削除
  static func deleteFile(url: URL) {
    let fileManager = FileManager.default
    
    do {
      try fileManager.removeItem(at: url)
    } catch {
      print("ファイルの削除に失敗しました: \(error.localizedDescription)")
    }
  }
  
  /// TimeInterval取得
  /*
   static func getTimeInterval(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> TimeInterval{
   let totalSeconds = TimeInterval(hours * 60 * 60 + minutes * 60 + seconds)
   return totalSeconds
   }
   */
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
  
  /// グループ情報Json入力
  static func readGroupInfo(url: URL) -> [GroupInfo]{   // 移動済
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      return try decoder.decode([GroupInfo].self, from: data)
    } catch {
      print("Error reading contents of directory: \(error)")
    }
    return [GroupInfo]()
  }
  
  /// グループ情報Json出力
  static func writeGroupInfo(url: URL, outputInfos:[GroupInfo]) throws {
    let encoder = JSONEncoder()
    let jsonData = try encoder.encode(outputInfos)
    try jsonData.write(to: url, options: .atomic)
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
