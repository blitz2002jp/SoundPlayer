//
//  Utility.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import AVFAudio
import AVFoundation
import SwiftUI
import UIKit

enum OkCancel: String, Codable{
  case cancel
  case ok
}

struct utility {
  // Private Modeファイル名
  private static let PRIVATE_FILE_NAME = ".PrivateMode"             // PrivateModeにするためのファイル名
  // UserDefaultのキー
  private static let FULL_SOUND_INFO = "FULL_SOUND_INFO"            // FullSoundのJsonデータ
  private static let FOLDER_INFO = "FOLDER_INFO"                    // FolderのJsonデータ
  private static let PLAY_LIST_INFO = "PLAY_LIST_INFO"              // PlayListのJsonデータ
  private static let SELECTED_GROUP_TYPE = "SELECTED_GROUP_TYPE"
  private static let SELECTED_GROUP_TEXT = "SELECTED_GROUP_TEXT"
  private static let PLAYING_GROUP_TYPE = "PLAYING_GROUP_TYPE"        // 現在のグループType
  private static let PLAYING_GROUP_TEXT = "PLAYING_GROUP_TEXT"        // 現在のグループ(フォルダ名、プレイリスト名)
  private static let PLAYING_SOUND_DURATION = "PLAYING_SOUND_DURATION"  // 現在の音源の長さ
  private static let PLAYING_SOUND_VOLUME = "PLAYING_SOUND_VOLUME"      // 音量
  private static let SETTING_FILE_DIRECTORY = "SETTING_FILE_DIRECTORY"
  
  // 再生モード保存キー
  private static let REPEAT_MODE = "REPEAT_MODE"                      // リピートモード
  private static let RANDOM_MODE = "RANDOM_MODE"                      // ランダムモード
  
  // SoundBoxフォルダ
  private static let SANDBOX_DIRECRORY = "private"
  
  // 拡張子
  private static let SOUND_FILE_EXTENSIONS = ["mp3", "m4a", "aif", "caf", "wav"]
  
  // ID2タグキー
  private static let ID3TAG_KEY_TITLE = "title"
  
  private static let ID3TAG_KEY_COPYRIGHTS = "copyrights"
  
  private static let ID3TAG_KEY_ARTIST = "artist"
  
  private static let ID3TAG_KEY_AUTHOR = "author"
  
  private static let ID3TAG_KEY_ALBUM_NAME = "albumName"
  
  private static let ID3TAG_KEY_ARTWORK = "artwork"
  
  private static var _emptyArtwork: Data?
  static var emptyArtwork: Data? {
    get {
      if let res = self._emptyArtwork {
        return res
      }
      if let url = Bundle.main.url(forResource: "EmptyArtWork.png", withExtension: "") {
        do {
          self._emptyArtwork = try Data(contentsOf: url)
          // imageDataを使用して必要な処理を行う
        } catch {
          print(error.localizedDescription)
        }
      }
      return self._emptyArtwork
    }
  }
  
  
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
  static func getSaveFullSoundInfo() -> [FullSoundInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: FULL_SOUND_INFO)
    return fetchedFolders.map { $0 as! FullSoundInfo }
  }
  /// 保存されているFolderInfo取得
  static func getSaveFolderInfo() -> [FolderInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: FOLDER_INFO)
    return fetchedFolders.map { $0 as! FolderInfo }
  }
  /// 保存されているPlayListInfo取得
  static func getPlayListInfo() -> [PlayListInfo] {
    let fetchedFolders: [GroupInfo] = self.getGroupInfo(saveKey: PLAY_LIST_INFO)
    return fetchedFolders.map { $0 as! PlayListInfo }
  }
  
  /// Group情報の取得
  private static func getGroupInfo(saveKey: String) -> [GroupInfo] {   // 移動済
    // UserDefaultsから保存データ取得
    if let jsonString = UserDefaults.standard.string(forKey: saveKey) {

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
  
  /// Group情報をJson形式で保存(UserDefaults)
  static func saveGroupInfo(outputInfos:[GroupInfo]) {
#if DEBUG
    utility.debug1(groupInfos: outputInfos, tag: "saveGroupInfo")
#endif
    
    do {
      if outputInfos.count > 0 {
        if let saveKey = getGroupInfoSaveKey(groupInfo: outputInfos[0]) {
          // Group情報の配列をjsonDataにエンコード
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
  
  // 再生対象のグループ情報の保存
  static func savePlayingGroupType(groupInfo: GroupInfo?) {
    if let _groupInfo = groupInfo {
      UserDefaults.standard.set(_groupInfo.groupType.rawValue , forKey: PLAYING_GROUP_TYPE)
      UserDefaults.standard.set(_groupInfo.text , forKey: PLAYING_GROUP_TEXT)
    }
  }
  
  // 現在選択されているグループ情報の保存
  static func saveSelectedGroupType(groupInfo: GroupInfo?) {
    if let _groupInfo = groupInfo {
      UserDefaults.standard.set(_groupInfo.groupType.rawValue , forKey: SELECTED_GROUP_TYPE)
      UserDefaults.standard.set(_groupInfo.text , forKey: SELECTED_GROUP_TEXT)
    }
  }
  
  // リピートモードの保存
  static func saveRepearMode(repeatMode: RepeatMode) {
    utility.debugPrint(msg: "RepeatMode(Save):\(repeatMode.rawValue)")
    UserDefaults.standard.set(repeatMode.rawValue, forKey: REPEAT_MODE)
  }
  // ランダムモードの保存
  static func saveRandomMode(randomMode: Bool) {
    utility.debugPrint(msg: "RandomMode(Save):\(randomMode)")
    UserDefaults.standard.set(randomMode , forKey: RANDOM_MODE)
  }
  // リピートモードの取得
  static func getRepearMode() -> RepeatMode {
    if let _repeatMode = UserDefaults.standard.string(forKey: REPEAT_MODE) {
      return RepeatMode.init(rawValue: _repeatMode) ?? RepeatMode.noRepeate
    }
    return RepeatMode.noRepeate
  }
  // ランダムモードの保存
  static func getRandomMode() -> Bool {
    utility.debugPrint(msg: "RandomMode(Get):\(UserDefaults.standard.bool(forKey: RANDOM_MODE))")
    return UserDefaults.standard.bool(forKey: RANDOM_MODE)
  }
  
  // 現在の音声の再生時間長保存
  static func savePlayingSoundDuration(duration: TimeInterval) {
    UserDefaults.standard.set(duration , forKey: PLAYING_SOUND_DURATION)
  }
  
  // 現在の音量の保存
  static func savePlayingSoundVolume(volume: Float) {
    UserDefaults.standard.set(volume , forKey: PLAYING_SOUND_VOLUME)
  }
  
  // 現在の音量の取得
  static func getPlayingSoundVolume() -> Float {
    return UserDefaults.standard.float(forKey: PLAYING_SOUND_VOLUME)
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
  static func getPlayingSoundDuration() -> TimeInterval {
    return UserDefaults.standard.double(forKey: PLAYING_SOUND_DURATION)
  }
  
  // 現在のグループ名(text)取得
  static func getPlayingGroupText() -> String? {
    return UserDefaults.standard.string(forKey: PLAYING_GROUP_TEXT)
  }
  
  // 現在選択されているグループ名(text)取得
  static func getSelectedGroupText() -> String? {
    return UserDefaults.standard.string(forKey: SELECTED_GROUP_TEXT)
  }
  
  // 現在のグループタイプ(GroupType)取得
  static func getPlayingGroupType() -> GroupType? {
    if let _groupType = UserDefaults.standard.string(forKey: PLAYING_GROUP_TYPE) {
      return GroupType(rawValue: _groupType)
    }
    return nil
  }
  
  // 現在選択されているグループタイプ(GroupType)取得
  static func getSelectedGroupType() -> GroupType? {
    if let _groupType = UserDefaults.standard.string(forKey: SELECTED_GROUP_TYPE) {
      return GroupType(rawValue: _groupType)
    }
    return nil
  }
  
  // MP3のID3タグを取得
  static func getID3Tags(mp3Url: URL) -> [String: Any]? {
    // AVAssetを使用してMP3ファイルを読み込む
    let asset = AVAsset(url: mp3Url)
    
    // AVAssetからID3メタデータを取得
    let metadata = asset.metadata
    
    // ID3メタデータから必要な情報を抽出する
    var id3Tags: [String: Any] = [:]
    for item in metadata {
      if let key = item.commonKey?.rawValue, let value = item.value {
        id3Tags[key] = value
      }
    }
    return id3Tags
  }
  
  // ID3タグのテキスト情報を取得
  static func getID3TagText(id3Tags: [String : Any], key: String) -> String {
    if let tag = id3Tags.first(where: {$0.key == key}) {
      if let txt = tag.value as? String {
        return txt
      }
    }
    return ""
  }
  
  // ArtWork Data取得
  static func getArtWorkData(url: URL?) -> Data? {
    if let _url = url {
      if let _id3Tags = utility.getID3Tags(mp3Url: _url) {
        if let _artworkTag = _id3Tags.first(where: {$0.key == ID3TAG_KEY_ARTWORK}) {
          return _artworkTag.value as? Data
        }
      }
    }
    return nil
  }
  
  // ArtWork Image取得
  static func getArtWorkImage(imageData: Data?) -> Image? {
    if let _imageData = imageData {
      if let _uiImage = UIImage(data: _imageData) {
        return Image(uiImage: _uiImage)
      }
    }
    return Image(systemName: "cat")
  }
  
  static func getPlayingImage(isPlaying: Bool, item: SoundInfo) -> some View {
    if isPlaying {
      return Image(systemName: "speaker.zzz")
        .opacity(item.isSelected ? 1.0 : 0)
        .frame(width: 20, height: 20)
        .foregroundStyle(.primary)
    } else {
      return Image(systemName: "speaker")
        .opacity(item.isSelected ? 1.0 : 0)
        .frame(width: 20, height: 20)
        .foregroundStyle(.primary)
    }
  }
  
  // PNGファイルにSave
  static func saveArtWork(imageData: Data?, fileName: String = UUID().uuidString) {
    if let _imageData = imageData {
      if let _uiImage = UIImage(data: _imageData) {
        if let _docUrl = utility.getDocumentDirectory() {
          // PNG形式で画像を保存
          do {
            let _saveUrl = _docUrl.appendingPathComponent(fileName)
            try _uiImage.pngData()?.write(to: _saveUrl)
            utility.debugPrint(msg: "Image saved to: \(_saveUrl.absoluteString)")
          } catch {
            print("Error saving image:", error.localizedDescription)
          }
        }
      }
    }
  }
  
  // 参照の削除
  static func removeReference(targetGroups: [GroupInfo] ,targetSound: SoundInfo) {
    targetGroups.forEach { item in
      item.soundInfos.removeAll(where: {$0.fullPath == targetSound.fullPath})
    }
  }
  
  // 処理時間計測
  static func measureExecutionTimeInMilliseconds(block: () -> Void) -> String {
    let startTime = DispatchTime.now()
    block()
    let endTime = DispatchTime.now()
    let nanoseconds = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let milliseconds = Double(nanoseconds) / 1_000_000 // ナノ秒をミリ秒に変換
    
    
    let millisecondsInt = Int(milliseconds)
    let millisecondsPart = millisecondsInt % 1000
    let secondsPart = (millisecondsInt / 1000) % 60
    let minutesPart = (millisecondsInt / (1000 * 60)) % 60
    let hoursPart = (millisecondsInt / (1000 * 60 * 60)) % 24
    return String(format: "%02d:%02d:%02d.%03d", hoursPart, minutesPart, secondsPart, millisecondsPart)
  }
  
  /// プライベートモード判定
  static func isPrivateMode() -> Bool {
    if let _documentDirectory = self.getDocumentDirectory() {
      
      return FileManager.default.fileExists(atPath: _documentDirectory.appendingPathComponent(PRIVATE_FILE_NAME).path)
    }
    return false
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
  
  // 次のリピートモード取得
  static func getNextRepeatMode() -> RepeatMode {
    var repeatMode = utility.getRepearMode()
    
    utility.debugPrint(msg: "RepeatMode(Get):\(repeatMode)")
    
    if repeatMode == .noRepeate {
      repeatMode = .repeateAll
    } else if repeatMode == .repeateAll {
      repeatMode = .repeateOne
    } else if repeatMode == .repeateOne {
      repeatMode = .noRepeate
    }
    
    utility.debugPrint(msg: "RepeatMode(Get(Next)):\(repeatMode)")
    
    return repeatMode
  }
  
  /// Priveteモード用ファイル作成
  static func CreatePrivateModeFile() {
    let fm = FileManager()
    if var path = self.getDocumentDirectory() {
      fm.createFile(atPath: path.appendingPathComponent(self.PRIVATE_FILE_NAME).path, contents: nil)
    }
  }
  
#if DEBUG
  static func selectedSoundCheck(viewModel: ViewModel) {
    if let _grpText = self.getPlayingGroupText() {
      utility.debugPrint(msg: "Save Group:\(_grpText)")
    } else {
      utility.debugPrint(msg: "Save Group:")
    }
    
    viewModel.folderInfos.forEach { item1 in
      utility.debugPrint(msg: "Group:\(item1.text)")
      if let a = item1.soundInfos.first(where: {$0.isSelected == true}) {
        utility.debugPrint(msg: "Sound:\(a.fileNameNoExt)")
      } else {
        utility.debugPrint(msg: "Sound:")
      }
    }
  }
  
  static func clearData() {
/*
    UserDefaults.standard.removeObject(forKey: SELECTED_GROUP_TYPE)
    UserDefaults.standard.removeObject(forKey: PLAYING_GROUP_TEXT)
    UserDefaults.standard.removeObject(forKey: PLAYING_GROUP_TYPE)
    UserDefaults.standard.removeObject(forKey: PLAYING_GROUP_TEXT)
    UserDefaults.standard.removeObject(forKey: PLAYING_SOUND_DURATION)
    UserDefaults.standard.removeObject(forKey: PLAYING_SOUND_VOLUME)
*/
    if let docUrl = self.getDocumentDirectory() {
      do {
        let fileManager = FileManager.default
        
        // フォルダ内のファイルとサブフォルダを取得
        let contents = try fileManager.contentsOfDirectory(atPath: docUrl.path)
        
        // フォルダ内のすべてのファイルとサブフォルダを削除
        for item in contents {
          let itemPath = "\(docUrl.path)/\(item)"
          try fileManager.removeItem(atPath: itemPath)
        }
      } catch {
        print("フォルダの内容を削除できませんでした: \(error.localizedDescription)")
      }
    }

     UserDefaults.standard.removeObject(forKey: FULL_SOUND_INFO)            // FullSoundのJsonデータ
     UserDefaults.standard.removeObject(forKey: FOLDER_INFO)                    // FolderのJsonデータ
     UserDefaults.standard.removeObject(forKey: PLAY_LIST_INFO)              // PlayListのJsonデータ
     UserDefaults.standard.removeObject(forKey: SELECTED_GROUP_TYPE)
     UserDefaults.standard.removeObject(forKey: SELECTED_GROUP_TEXT)
     UserDefaults.standard.removeObject(forKey: PLAYING_GROUP_TYPE)        // 現在のグループType
     UserDefaults.standard.removeObject(forKey: PLAYING_GROUP_TEXT)        // 現在のグループ(フォルダ名、プレイリスト名)
     UserDefaults.standard.removeObject(forKey: PLAYING_SOUND_DURATION)  // 現在の音源の長さ
     UserDefaults.standard.removeObject(forKey: PLAYING_SOUND_VOLUME)      // 音量
     UserDefaults.standard.removeObject(forKey: SETTING_FILE_DIRECTORY)
     
     // 再生モード保存キー
     UserDefaults.standard.removeObject(forKey: REPEAT_MODE)                      // リピートモード
     UserDefaults.standard.removeObject(forKey: RANDOM_MODE)                      // ランダムモード
  }
  
  
  
  static func DebugPrintSaveData(viewModel: ViewModel) {
    self.debugPrint(msg: "----------------------DEBUG PRINT START-------------------------------------------")
    // フォルダ
    if let _docUrl = self.getDocumentDirectory() {
      self.debugPrint(msg: "DocumentDirectory : \(String(describing: _docUrl.path))")
    } else {
      self.debugPrint(msg: "DocumentDirectory なし")
    }
    
    
    self.debugPrint(msg: "SELECTED_GROUP_TYPE:\(String(describing: self.getSelectedGroupType()))")
    self.debugPrint(msg: "SELECTED_GROUP_TEXT:\(String(describing: self.getPlayingGroupText() ?? ""))")
    
    self.debugPrint(msg: "PLAYING_GROUP_TYPE:\(String(describing: self.getPlayingGroupType()))")
    self.debugPrint(msg: "PLAYING_GROUP_TEXT:\(String(describing: self.getPlayingGroupText() ?? ""))")
    self.debugPrint(msg: "PLAYING_SOUND_DURATION:\(self.getPlayingSoundDuration())")
    self.debugPrint(msg: "PLAYING_SOUND_VOLUME:\(self.getPlayingSoundVolume())")               // 音量
    
    if let _selectedSound = viewModel.getPlayingSound() {
      self.debugPrint(msg: "SelectedSound FileName : \(_selectedSound.fileName)")
      self.debugPrint(msg: "SelectedSound currentTime : \(_selectedSound.currentTime)")
      self.debugPrint(msg: "SelectedSound currentTime : \(_selectedSound.currentTime)")
      self.debugPrint(msg: "SelectedSound currentTimeStr : \(_selectedSound.currentTimeStr)")
    }
    
    self.debugPrint(msg: "----------------------DEBUG PRINT END  -------------------------------------------")
  }
  
  static func debug1(groupInfos: [GroupInfo], tag: String) {
    groupInfos.forEach { item in
      self.debug2(groupInfo: item, tag: tag)
    }
  }
  static func debug2(groupInfo: GroupInfo, tag: String) {
    var _groupInfo = groupInfo
    
    self.debugPrint(msg: "\(tag)  \(groupInfo.text) \(self.getPointer(of: groupInfo))")
    groupInfo.soundInfos.forEach { item in
      self.debug3(soundInfo: item, tag: tag)
    }
  }
  static func debug3(soundInfo: SoundInfo, tag: String) {
    if soundInfo.isSelected {
      self.debugPrint(msg: "\(tag)  \(soundInfo.fileNameNoExt) ")
    }
  }
  
  static func getPointer<T>(of value: T) -> String {
    var _val = value
//    var res: Any
    withUnsafePointer(to: &_val) { pointer in
      self.debugPrint(msg: "\(pointer)")
    }
    return ""
  }
  
  static func debugPrint(msg: String) {
    print(msg)
  }
#endif
  
}
