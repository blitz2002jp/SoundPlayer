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
        .onAppear() {
          utility.DebugPrintSaveData(viewModel: viewModel)
          
          // アプリの起動直後に現在再生対象の音声を一瞬再生し停止する（イヤホンのでの再生開始に対応するため）
          // ◆◆　イヤホンの再生ボタンイベントはアプリで一度再生を開始しないと発火しない
          // バックグラウンドで再生中だった場合は、この処理を行わない
          if let _playingGroup = viewModel.playingGroup {
            if let _playingSound = viewModel.getPlayingSound() {
              do {
                try viewModel.playSound(targetGroup: _playingGroup, targetSound: _playingSound, volume: Float.zero)
                viewModel.player.pauseSound()
                
              } catch {
                print(error.localizedDescription)
              }
            }
          }
        }

      // アクティブになった
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { notification in
/*
          // アプリの起動直後に現在再生対象の音声を一瞬再生し停止する（イヤホンのでの再生開始に対応するため）
          // ◆◆　イヤホンの再生ボタンイベントはアプリで一度再生を開始しないと発火しない
          // バックグラウンドで再生中だった場合は、この処理を行わない
          if viewModel.player.isPlaying == false {
            if let _playingGroup = viewModel.playingGroup {
              if let _playingSound = viewModel.getPlayingSound() {
                do {
                  // ボリュームを一旦ミュート
                  let saveVolume = _playingSound.volume
                  _playingSound.volume = 0.0
                  try viewModel.playSound(targetGroup: _playingGroup, targetSound: _playingSound)
                  viewModel.player.pauseSound()
                  // ボリュームをもとに戻す
                  _playingSound.volume = saveVolume

                } catch {
                  print(error.localizedDescription)
                }
              }
            }
          }
 */
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
          utility.debugPrint(msg: "")
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
    // Appのインスタンスを設定
    self.appInstance = SoundPlayerApp()
//    @EnvironmentObject var viewModel: ViewModel

    // バックグラウンド再生のために追加
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    } catch {
      print(error.localizedDescription)
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
