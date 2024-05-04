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
  //@UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
  
  // アプリ全体で使用可能な変数のインスタンスを作成
  @StateObject internal var viewModel = ViewModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(viewModel)
        .onAppear(){
#if DEBUG
          utility.DebugPrintSaveData(viewModel: viewModel)
#endif
        }
      // アクティブになった
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { notification in
        }
      // 非活性になるよ。
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { notification in
          // 現在の情報保存
          viewModel.saveGroupInfos()
        }
      // バックグランドになった。
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { notification in
        }
      // フォアグラウンドになるよ。
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { notification in
        }
      // アプリ終了するよ。
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { notification in
        }
      // 画面が回転したよ
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
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

  func applicationDidEnterBackground(_ application: UIApplication) {
      // アプリケーションがバックグラウンドに移行する直前に呼ばれる
      // ここでバックグラウンドに移行する直前の処理を行う
  }
}
