//
//  Utility.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import AVFAudio

struct utility {
  // UserDefaultのキー
  private static let FULL_SOUND_INFO = "FULL_SOUND_INFO"            // FullSoundのJsonデータ
  private static let FOLDER_INFO = "FOLDER_INFO"                    // FolderのJsonデータ
  private static let PLAY_LIST_INFO = "PLAY_LIST_INFO"              // PlayListのJsonデータ
  
  private static let CURRENT_GROUP_TYPE = "CurrentGroupType"        // 現在のグループType
  // (Full,Folde,Playlist)
  private static let CURRENT_GROUP_TEXT = "CurrentGroupText"          // 現在のグループ(フォルダ名、プレイリスト名)
  private static let CURRENT_SOUND_DURATION = "CURRENT_SOUND_DURATION"          // 現在の再生時間
  private static let CURRENT_PLAY_TIME = "CurrentPlayTime"          // 現在の再生時間
  
  private static let CURRENT_VOLUME = "CurrentVolume"               // 音量
  
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
  static func timeIntervalToString(timeFormat: TimeFormat = .MMSS, timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    
    if let formattedString = formatter.string(from: timeInterval) {
      if timeInterval >= 3600
          || timeFormat == .HHMMSS { // 1時間以上の場合かフォーマットがHHMMSS
        return formattedString
      } else { // 1時間未満の場合
        let components = formattedString.split(separator: ":")
        if components.count == 3 {
          return "\(components[1]):\(components[2])"
        }
      }
    }
    return "00:00"
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
  
  /// 保存されているFullSoundInfo取得
  static func getFullSoundInfo() -> [FullSoundInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: FULL_SOUND_INFO)
    return fetchedFolders.map { $0 as! FullSoundInfo }
  }
  /// 保存されているFolderInfo取得
  static func getFolderInfo() -> [FolderInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: FOLDER_INFO)
    return fetchedFolders.map { $0 as! FolderInfo }
  }
  /// 保存されているPlayListInfo取得
  static func getPlayListInfo() -> [PlayListInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: PLAY_LIST_INFO)
    return fetchedFolders.map { $0 as! PlayListInfo }
  }
  
  /// PlayList情報の取得
  private static func getGroupInfo(saveKey: String) -> [GroupInfo] {   // 移動済
    // UserDefaultsから保存データ取得
    if let jsonString = UserDefaults.standard.string(forKey: saveKey) {
#if DEBUG
      print("jsonString(\(saveKey):\(jsonString)")
#endif
      // String型データをData型に変換
      if let jsonData = jsonString.data(using: .utf8) {
        do {
          // JsonDataを配列に変換
          if saveKey == FULL_SOUND_INFO {
            return try JSONDecoder().decode([FullSoundInfo].self, from: jsonData)
          } else if saveKey == FOLDER_INFO {
            return try JSONDecoder().decode([FolderInfo].self, from: jsonData)
          } else if saveKey == PLAY_LIST_INFO {
            return try JSONDecoder().decode([PlayListInfo].self, from: jsonData)
          }
        } catch {
          print("Error decoding JSON data: \(error.localizedDescription)")
        }
      } else {
        print("Error converting JSON string to data")
      }
    } else {
      print("Error retrieving JSON string from UserDefaults")
    }
    return [GroupInfo]()
  }
  
  /// PlayList情報をJson形式で保存(UserDefaults)
  static func saveGroupInfo(outputInfos:[GroupInfo]) {
    do {
      if outputInfos.count > 0 {
        if let saveKey = getGroupInfoSaveKey(groupInfo: outputInfos[0]) {
          // PlayListInfoの配列をjsonDataにエンコード
          let jsonData = try JSONEncoder().encode(outputInfos)
          
          // JSONデータをStringに変換
          if let jsonString = String(data: jsonData, encoding: .utf8) {
            // UserDefaultsにPlayListデータを保存
            UserDefaults.standard.setValue(jsonString, forKey: saveKey)
          } else {
            print("Failed to convert JSON data to string.")
          }
        }
      }
    } catch {
      print(error.localizedDescription)
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
      UserDefaults.standard.set(_groupInfo.groupType.rawValue , forKey: CURRENT_GROUP_TYPE)
      UserDefaults.standard.set(_groupInfo.text , forKey: CURRENT_GROUP_TEXT)
    }
  }
  
  // 現在の音声の再生時間保存
  static func saveCurrentPlayTime(currentTime: String) {
    UserDefaults.standard.set(currentTime , forKey: CURRENT_PLAY_TIME)
  }
  
  // 現在の音声の再生時間長保存
  static func saveCurrentSoundDuration(currentSoundDuration: TimeInterval) {
    UserDefaults.standard.set(currentSoundDuration , forKey: CURRENT_SOUND_DURATION)
  }
  
  // 現在の音量の保存
  static func saveCurrentVolume(currentVolume: Float) {
    UserDefaults.standard.set(currentVolume , forKey: CURRENT_VOLUME)
  }
  
  // 現在の音量の取得
  static func getCurrentVolume() -> Float {
    return UserDefaults.standard.float(forKey: CURRENT_VOLUME)
  }
  
  /// グループ情報(Full、Folder、Playlist)保存キーの取得
  /// 引数のGroup情報からグループ(Full、Folder、PlayList)を決定し保存キーを取得
  private static func getGroupInfoSaveKey(groupInfo: GroupInfo) -> String? {
    if groupInfo is FullSoundInfo {
      return FULL_SOUND_INFO
    } else if groupInfo is FolderInfo {
      return FOLDER_INFO
    } else if groupInfo is PlayListInfo {
      return PLAY_LIST_INFO
    }
    
    return nil
  }
  
  // 現在の音声の再生時間取得
  static func getCurrentPlayTime() -> String {
    if let _currentTime = UserDefaults.standard.string(forKey: CURRENT_PLAY_TIME) {
      return _currentTime
    }
    return "00:00:00"
  }
  
  // 現在の音声の再生時間取得
  static func getCurrentSoundDuration() -> TimeInterval {
    return UserDefaults.standard.double(forKey: CURRENT_SOUND_DURATION)
  }
  
  // 現在のグループ名(text)取得
  static func getCurrentGroupText() -> String? {
    return UserDefaults.standard.string(forKey: CURRENT_GROUP_TEXT)
  }
  
  // 現在のグループタイプ(GroupType)取得
  static func getCurrentGroupType() -> GroupType? {
    if let _groupType = UserDefaults.standard.string(forKey: CURRENT_GROUP_TYPE) {
      return GroupType(rawValue: _groupType)
    }
    return nil
  }
  
  // 処理時間計測
  static func measureExecutionTimeInMilliseconds(block: () -> Void) -> Double {
    let startTime = DispatchTime.now()
    block()
    let endTime = DispatchTime.now()
    let nanoseconds = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let milliseconds = Double(nanoseconds) / 1_000_000 // ナノ秒をミリ秒に変換
    return milliseconds
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
  
#if DEBUG
  static func SaveDataDebugPrint(viewModel: ViewModel) {
    print("----------------------DEBUG PRINT START-------------------------------------------")
    // フォルダ
    if let _docUrl = self.getDocumentDirectory() {
      print("DocumentDirectory : \(String(describing: _docUrl.path))")
    } else {
      print("DocumentDirectory なし")
    }
    
    print("CURRENT_GROUP_TYPE:\(String(describing: self.getCurrentGroupType()))")
    print("CURRENT_GROUP_TEXT:\(String(describing: self.getCurrentGroupText() ?? ""))")
    print("CURRENT_PLAY_TIME:\(self.getCurrentPlayTime())")          // 現在の再生時間
    print("CURRENT_SOUND_DURATION:\(self.getCurrentSoundDuration())")
    print("CURRENT_VOLUME:\(self.getCurrentVolume())")               // 音量
    
    if let _selectedSound = viewModel.getCurrentSelectedSound() {
      print("SelectedSound FileName : \(_selectedSound.fileName)")
      print("SelectedSound currentTime : \(_selectedSound.currentTime)")
      print("SelectedSound currentTime : \(_selectedSound.currentTime)")
      print("SelectedSound currentTimeStr : \(_selectedSound.currentTimeStr)")
    }
    print("----------------------DEBUG PRINT END  -------------------------------------------")
  }
#endif
  
}
