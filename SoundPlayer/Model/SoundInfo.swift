//
//  SoundInfo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import AVFoundation
import SwiftUI

class SoundInfo: Codable, Identifiable {
  
  private var _artWork: Data?
  var artWork: Data? {
    get {
      if let res = _artWork {
        return res
      }
      return utility.emptyArtwork
    }
    set(val) {
      self._artWork = val
    }
  }
  
  var isSelected = false
  var foldersName: String = ""                      // フォルダ名(Documentフォルダより下位のフォルダ)
  var fileName: String = ""                         // ファイル名
  
  var fileNameNoExt: String {                       // ファイル名(拡張子なし)
    get {
      if let _path = self.path {
        return _path.deletingPathExtension().lastPathComponent
      }
      return ""
    }
  }
  var text: String = ""                             // 表示
  var comment: String = ""                          // コメント
  var currentTimeStr: String {                     // 現在再生時間("HH:MM:SS")
    get {
      return utility.timeIntervalToString(timeInterval: self.currentTime)
    }
  }
  var currentTime: TimeInterval = TimeInterval.zero                   // 現在再生時間
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
      let removeDirName = URL(fileURLWithPath: docDir.path)
      
      ///  フォルダ名の設定
      // 先頭からDocumentフォルダまでを除去してfoldersNameにセット
      self.foldersName = fileName.deletingLastPathComponent().absoluteString.replacingOccurrences(of: removeDirName.absoluteString, with: "")
      
      // Art Work
      self.artWork = utility.getArtWorkData(url: self.fullPath)
    }
  }
  
  // Cron
  func copy() -> SoundInfo{
    let res = SoundInfo()
    res.isSelected = self.isSelected
    res.foldersName = self.foldersName                     // フォルダ名(Documentフォルダより下位のフォルダ)
    res.fileName = self.fileName                          // ファイル名
    res.text = self.text                              // 表示
    res.comment = self.comment                           // コメント
//    res.currentTimeStr = self.currentTimeStr                  // 現在再生時間
    res.currentTime = self.currentTime                  // 現在再生時間
    res.startTimeStr = self.startTimeStr                    // 再生開始時間
    res.volume = self.volume                             // ボリューム
    res.repeatMode = self.repeatMode                    // 繰り返し
    res.sortKey = self.sortKey                              // ソートキー
    
    return res
  }
  
  /*
   ///  Equal
   static func ==(lhs: SoundInfo, rhs: SoundInfo) -> Bool {
   return lhs.id == rhs.id
   }
   */
  
  //  func getFolderName() -> String {
  //    return ""
  //    return self.foldersName.joined(separator: "/")
  //  }
  
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
