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
//  @StateObject internal var viewModel = ViewModel()
  @StateObject internal var viewModel = ViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(viewModel)
      // 回転抑止の為追加
        .onAppear(){
          // 縦画面固定
          CustomAppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
          
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


/*
// 回転抑止、バックグラウンド再生、アプリの終了検知の為追加
  class AppDelegate: UIResponder, UIApplicationDelegate
  {
    @EnvironmentObject var globalData: SoundPlayerApp.GlobalData

    static var orientationLock = UIInterfaceOrientationMask.all
    // 設定の変更通知がされた時に呼ばれるデリゲート
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      
      // バックグラウンド再生のために追加
      do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      } catch _ {
        print("audio session set category failure")
      }
      
      return AppDelegate.orientationLock
    }
    
    //      SoundPlayerAppで定義したviewModelをapplicationWillTerminateメソッドで使用する方法が不明
    //      UIKitとSwiftUIでは共有方法が違うようだ
    //    https://software.small-desk.com/development/2021/08/02/swiftui-abletoaccess-appdelegate-asenvironmentobject/
    
    func applicationWillTerminate(_ application: UIApplication) {
        // アプリが終了する際の処理
        print("Application will terminate")

//      print("ViewModel:\(vm.playerLib.folderInfos[0].text)")
      print("ViewModel:\(globalData.someValue)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // アプリがバックグラウンドに移行した際の処理
        print("Application did enter background")
    }

  }
*/

