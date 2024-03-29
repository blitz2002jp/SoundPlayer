//
//  Utility.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation

struct utility {
  private static let PLAY_LIST_INFO_KEY = "PLAY_LIST_INFO"
  private static let CURRENT_GROUP_TYPE_KEY = "CurrentGroupType"
  private static let CURRENT_GROUP_TEXT_KEY = "CurrentGroupText"
  private static let CURRENT_SOUND_URL_KEY = "CurrentSound"
  private static let IS_SAND_BOX_KEY = "isSandBox"
  
  
  private static let SETTING_FILE_DIRECTORY = "Setteing"
  private static let SANDBOX_DIRECRORY = "private"
  private static let SOUND_FILE_EXTENSIONS = ["mp3"]
  
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
  
  /// TimeIntervalを時分秒に分解
  static func decomposeTimeInterval(_ timeInterval: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
    let hours = Int(timeInterval / 3600)
    let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
    return (hours, minutes, seconds)
  }
  
  /// TimeIntervalをStringに変換
  static func timeIntervalToString(timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.hour, .minute, .second]
    
    return formatter.string(from: timeInterval)!
  }
  
  /// StringをTimeIntervalに変換
  static func stringToTimeInterval(HHMMSS: String) -> TimeInterval {
    let hhmmssArray = HHMMSS.components(separatedBy: ":")
    
    if hhmmssArray.count != 3 {
      return TimeInterval.zero
    }
    return TimeInterval(Int(hhmmssArray[0])! * 3600 + Int(hhmmssArray[1])! * 60 + Int(hhmmssArray[2])!)
  }
  
  /// TimeIntervalから時分秒を取得
  static func getHMS(time: TimeInterval) -> (hour: Int, minits: Int, seconds: Int) {
    // 時間、分、秒に分解する
    let hours = Int(time / 3600)
    let minutes = Int((time.truncatingRemainder(dividingBy: 3600)) / 60)
    let seconds = Int(time.truncatingRemainder(dividingBy: 60))
    
    return (hours, minutes, seconds)
    
  }
  
  /// Documentフォルダ以下のMP3ファイルの一覧を取得する
  static func getSoundFiles() -> [URL]{
    if let documentsPath = utility.getDocumentDirectory() {
      // Documentディレクトリ以下のすべてのファイルを列挙する
      if let enumerator = FileManager.default.enumerator(at: documentsPath, includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
        //enumeratorを配列に変換
        if let files = enumerator.allObjects as? [URL] {
          // 拡張子(mp3)でファイルをフィルタ
          return files.filter { file in
            return utility.SOUND_FILE_EXTENSIONS.contains { condition in
              file.pathExtension.lowercased() == condition.lowercased()
            }
          }
        }
      }
    }
    return [URL]()
  }
  
  /// PlayList情報の取得
  static func getPlayListInfo() -> [PlayListInfo]{   // 移動済
    // UserDefaultsから保存データ取得
    if let jsonString = UserDefaults.standard.string(forKey: PLAY_LIST_INFO_KEY) {
      // String型データをData型に変換
      if let jsonData = jsonString.data(using: .utf8) {
        do {
          // JsonDataをPlayListInfo配列に変換
          return try JSONDecoder().decode([PlayListInfo].self, from: jsonData)
        } catch {
          print("Error decoding JSON data: \(error.localizedDescription)")
        }
      } else {
        print("Error converting JSON string to data")
      }
    } else {
      print("Error retrieving JSON string from UserDefaults")
    }
    return [PlayListInfo]()
  }
  
  /// PlayList情報をJson形式で保存(UserDefaults)
  static func savePlayListInfo(outputInfos:[PlayListInfo]) throws {
    // PlayListInfoの配列をjsonDataにエンコード
    let jsonData = try JSONEncoder().encode(outputInfos)
    
    // JSONデータをStringに変換
    if let jsonString = String(data: jsonData, encoding: .utf8) {
      // UserDefaultsにPlayListデータを保存
      UserDefaults.standard.setValue(jsonString, forKey: PLAY_LIST_INFO_KEY)
    } else {
        print("Failed to convert JSON data to string.")
    }
  }
  
  /// PlayListInfoをファイル出力する
  static func playListInfoToFile(groupinfo: [PlayListInfo] ,fileName: String, outputUrl: URL? = nil) throws {
    var outputFullUrl: URL
    if let _outputUrl = outputUrl {
      outputFullUrl = _outputUrl.appendingPathComponent(fileName)
    } else {
      outputFullUrl = utility.getDocumentDirectory()!.appendingPathComponent(fileName)
    }
    
    // エンコードと出力
    try JSONEncoder().encode(groupinfo).write(to:outputFullUrl)
  }
  
  // 現在のグループ情報の保存
  static func saveCurrentGroupInfo(groupInfo: GroupInfo?) {
    if let _groupInfo = groupInfo {
      UserDefaults.standard.set(_groupInfo.groupType.rawValue , forKey: CURRENT_GROUP_TYPE_KEY)
      UserDefaults.standard.set(_groupInfo.text , forKey: CURRENT_GROUP_TEXT_KEY)
    }
  }
  
  // 現在の音声情報の保存
  static func saveCurrentSoundInfo(soundInfo: SoundInfo?) {
    if let _soundIndo = soundInfo {
      UserDefaults.standard.set(_soundIndo.path , forKey: CURRENT_SOUND_URL_KEY)
    }
  }
  
  /// 現在再生中の音声(url)の取得
  static func GetCurrentSound() -> URL? {
    if let url = UserDefaults.standard.url(forKey: CURRENT_SOUND_URL_KEY) {
      return url
    }else{
      return nil
    }
  }

  /// 現在再生中のGroupTextの取得
  static func GetCurrentGroup() -> String {
    if let loadedText = UserDefaults.standard.string(forKey: CURRENT_GROUP_TEXT_KEY) {
      return loadedText
    }else{
      return ""
    }
  }

  // 現在のグループ名(text)取得
  static func getCurrentGroupText() -> String? {
    return UserDefaults.standard.string(forKey: CURRENT_GROUP_TEXT_KEY)
  }
  
  // 現在のグループタイプ(GroupType)取得
  static func getCurrentGroupType() -> GroupType? {
    if let _groupType = UserDefaults.standard.string(forKey: CURRENT_GROUP_TYPE_KEY) {
      return GroupType(rawValue: _groupType)
    }
    return nil
  }
  
  // 現在の音声情報(url)取得
  static func getCurrentSoundUrl() -> URL? {
    return UserDefaults.standard.url(forKey: CURRENT_SOUND_URL_KEY)
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
