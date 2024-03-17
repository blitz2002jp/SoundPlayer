//
//  SoundInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import AVFoundation

class SoundInfo: Codable, Identifiable {
//  var foldersName = [String]()                      // フォルダ名(Documentフォルダより下位のフォルダ)
  var foldersName: String = ""                      // フォルダ名(Documentフォルダより下位のフォルダ)
  var fileName: String = ""                         // ファイル名
  var text: String = ""                             // 表示
  var comment: String = ""                          // コメント
  var isSelected: Bool = false                      // 選択中
  var playMode = PlayMode.stop                      // 再生中
  var currentTimeStr: String = ""                   // 現在再生時間(文字列)
  var currentTime: TimeInterval {                   // 現在再生時間
    get {
      return utility.stringToTimeInterval(HHMMSS: self.currentTimeStr)
    }
  }
  var startTimeStr: String = ""                     // 再生開始時間(文字列)
  var startTime: TimeInterval {                     // 再生開始時間
    get {
      return utility.stringToTimeInterval(HHMMSS: self.startTimeStr)
    }
  }
  var volume: Float = Float.zero                    // ボリューム
  var repeatMode: RepeatMode = .noRepeate           // 繰り返し
  var sortKey: Int = Int.zero                       // ソートキー
  
  // フルパス（ドキュメントフォルダを含むパス)
  var fullPath: URL? {
    get {
      return utility.getDocumentDirectory()?.appendingPathComponent(self.foldersName).appendingPathComponent(self.fileName)
    }
  }
  // パス（ドキュメントフォルダを含まないパス)
  var path: URL? {
    get {
      if let _docUrl = utility.getDocumentDirectory() {
        if let _fullpath = self.fullPath {
          return URL(string: _fullpath.absoluteString.replacingOccurrences(of: _docUrl.absoluteString, with: ""))
        }
      }
      return nil
    }
  }

  init(){
  }
  
  init(fileName: URL){
    
    
    // fileNameからDocumentsディレクトリを除くディレクトリとファイル名を抽出
    if let docDir = utility.getDocumentDirectory() {
      // ファイル名
      self.fileName = fileName.lastPathComponent
      
      
      // Documentoフォルダより下のフォルダ名を取得する
      // 除去するフォルダ
      var removeDirName = URL(fileURLWithPath: docDir.path)

      ///  フォルダ名の設定
      // 先頭からDocumentフォルダまでを除去してfoldersNameにセット
      self.foldersName = fileName.deletingLastPathComponent().absoluteString.replacingOccurrences(of: removeDirName.absoluteString, with: "")
    }
  }
  
  // Cron
  func copy() -> SoundInfo{
    let res = SoundInfo()
//    res.id = self.id
    res.foldersName = self.foldersName                     // フォルダ名(Documentフォルダより下位のフォルダ)
    res.fileName = self.fileName                          // ファイル名
    res.text = self.text                              // 表示
    res.comment = self.comment                           // コメント
    res.isSelected = self.isSelected                  // 選択中
    res.playMode = self.playMode                  // 再生中
    res.currentTimeStr = self.currentTimeStr                  // 現在再生時間
    res.startTimeStr = self.startTimeStr                    // 再生開始時間
    res.volume = self.volume                             // ボリューム
    res.repeatMode = self.repeatMode                    // 繰り返し
    res.sortKey = self.sortKey                              // ソートキー
    
    
    return res
  }


  ///  Equal
  /*
  static func ==(lhs: SoundInfo, rhs: SoundInfo) -> Bool {
      return lhs.id == rhs.id
  }
   */
  
//  func getFolderName() -> String {
//    return ""
//    return self.foldersName.joined(separator: "/")
//  }
  
  func isSelectedx() -> Bool {
    if(self.playMode == .stop){
      return false
    }
    return true
  }
  
    /// 再生時間
  func duration() -> TimeInterval{
    if let _url = self.fullPath{
      do {
        let audioPlayer = try AVAudioPlayer(contentsOf: _url)
        return audioPlayer.duration
      } catch {
        print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
      }
    }
    return TimeInterval.zero
  }
}
