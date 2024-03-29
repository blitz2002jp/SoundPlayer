//
//  Player.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/22.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol PlayerDelegate {
  // 再生時間の通知
  func notifyCurrentTime(currentTime: TimeInterval)
  
  // 再生終了の通知
  func notifyTermination()
}

class Player: NSObject, AVAudioPlayerDelegate {
  // Player
  private var soundPlayer:AVAudioPlayer!
  
  /// 再生時間表示タイマー
  private var timer: Timer?
  
  // 通知用デリゲート
  var delegate: PlayerDelegate?
  
  func addRemoteCommandEvent() {
      let commandCenter = MPRemoteCommandCenter.shared()
    commandCenter.togglePlayPauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
      self.remoteTogglePlayPause(commandEvent)
      return MPRemoteCommandHandlerStatus.success
    })
    commandCenter.playCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
      self.remotePlay(commandEvent)
      return MPRemoteCommandHandlerStatus.success
    })
    commandCenter.pauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
      self.remotePause(commandEvent)
      return MPRemoteCommandHandlerStatus.success
    })
    commandCenter.nextTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
      self.remoteNextTrack(commandEvent)
      return MPRemoteCommandHandlerStatus.success
    })
    commandCenter.previousTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
      self.remotePrevTrack(commandEvent)
      return MPRemoteCommandHandlerStatus.success
    })
}

    func remoteTogglePlayPause(_ event: MPRemoteCommandEvent) {
      // イヤホンのセンターボタンを押した時の処理
      print("イヤホンのセンターボタンを押した時の処理")
      // （今回は再生中なら停止、停止中なら再生をおこなっています）
    }
    
    func remotePlay(_ event: MPRemoteCommandEvent) {
        // プレイボタンが押された時の処理
        print("プレイボタンが押された時の処理")
        // （今回は再生をおこなっています）
    }
    
    func remotePause(_ event: MPRemoteCommandEvent) {
        // ポーズボタンが押された時の処理
        print("ポーズが押された時の処理")
        // （今回は停止をおこなっています）
    }
    
    func remoteNextTrack(_ event: MPRemoteCommandEvent) {
        // 「次へ」ボタンが押された時の処理
        // （略）
    }
    
    func remotePrevTrack(_ event: MPRemoteCommandEvent) {
        // 「前へ」ボタンが押された時の処理
        // （略）
    }
  
  // Play
  func Play(url: URL?, startTime: TimeInterval = TimeInterval.zero, isLoop: Bool = false) throws {

    // バックグラウンド再生のために追加
    try AVAudioSession.sharedInstance().setActive(true)

    if let _url = url {
      self.soundPlayer = try AVAudioPlayer(contentsOf: _url)
      self.soundPlayer.currentTime = startTime
      self.soundPlayer.numberOfLoops = isLoop ? -1 : 0
      self.soundPlayer.delegate = self
      self.soundPlayer.play()
      
      // 再生時間表示タイマー
      if self.timer != nil {
        self.timer?.invalidate()
      }
      self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
    }
  }
  
  // Pause
  func pauseSound(){
    if let _soundPlayer = self.soundPlayer {
      _soundPlayer.pause()
    }
  }
  
  /// ボリューム設定
  func setVolume(volume: Float) {
    if let _soundPlayer = self.soundPlayer{
      _soundPlayer.volume = volume
    }
  }
  
  /// 再生位置設定
  func setPlayPosition(position: TimeInterval) {
    if let _soundPlayer = self.soundPlayer{
      _soundPlayer.currentTime = position
    }
  }

  // タイマーイベント
  @objc func timerEvent(){
    // 終了通知
    if let dg = self.delegate {
      dg.notifyCurrentTime(currentTime: self.soundPlayer.currentTime)
    }
  }
  
  /// 現在再生時間
  func getCurrentTime() -> TimeInterval {
    if let _soundPlayer = self.soundPlayer {
      return _soundPlayer.currentTime
    }
    return TimeInterval.zero
  }
  
  /// 再生時間
  func getPlayTime() -> TimeInterval {
    if let _soundPlayer = self.soundPlayer {
      return _soundPlayer.duration
    }
    return TimeInterval.zero
  }

  // 再生終了デリゲート
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    // 終了通知
    if let dg = self.delegate {
      dg.notifyTermination()
    }
  }

  //
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    // あとで実装
  }
}

