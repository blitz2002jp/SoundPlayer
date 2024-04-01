//
//  SoundPlayerApp.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/01/13.
//

import SwiftUI
import AVFoundation
import os.log

@main
struct SoundPlayerApp: App {
  // AppDelegate を利用する
  @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
  
  // アプリ全体で使用可能な変数のインスタンスを作成
  @StateObject internal var viewModel = ViewModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(viewModel)
        .onAppear(){
          // フォルダ
          if let _docUrl = utility.getDocumentDirectory() {
            print("DocumentDirectory : \(String(describing: _docUrl.path))")
          } else {
            print("DocumentDirectory なし")
          }
        }
    }
  }
}

class CustomAppDelegate: UIResponder, UIApplicationDelegate {
  
  // YourAppのインスタンスを保持する
  var appInstance: SoundPlayerApp?

  static var orientationLock = UIInterfaceOrientationMask.all

  // アプリの起動完了(UIApplicationDelegateのメソッド)
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    // YourAppのインスタンスを設定
    self.appInstance = SoundPlayerApp()

    // バックグラウンド再生のために追加
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    } catch _ {
      print("audio session set category failure")
    }

    return true
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // YourAppからインスタンスを取得し、アプリ全体で使用可能な変数の値を取得してprint
    guard self.appInstance != nil else {
      print("Error: YourApp instance not found")
      return
    }
  }
}
