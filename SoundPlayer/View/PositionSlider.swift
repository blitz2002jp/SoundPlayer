//
//  PositionSlider.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/04/16.
//

import SwiftUI

/// 再生位置Slider
struct PositionSlider: View, PlayerDelegateCurrentTime {
  @EnvironmentObject var viewModel: ViewModel
  @StateObject private var sliderViewModel = SliderViewModel()
  var playingSound: SoundInfo
  
  // Playerからの再生時間通知デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    self.sliderViewModel.tim = currentTime
    
    // 音声情報に現在再生時間をセット
    playingSound.currentTime = currentTime
    
    // 現在再生時間の保存
    utility.savePlayingSoundTime(currentTime: utility.timeIntervalToString(timeFormat: .HHMMSS, timeInterval: currentTime))
  }
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "goforward.10")
          .font(.title3)
          .onTapGesture {
            viewModel.adjustPlayTime(seconds: 10)
          }
        
        Slider(value: self.$sliderViewModel.tim, in: 0.0...Double(playingSound.duration()) + 1, step: 0.01)
        {}onEditingChanged: { isEditing in
          playingSound.currentTime = self.sliderViewModel.tim
          viewModel.setPlayTime(time: self.sliderViewModel.tim)
        }
        .onAppear() {
          self.sliderViewModel.tim = playingSound.currentTime
        }
        Image(systemName: "gobackward.10")
          .font(.title3)
          .onTapGesture {
            viewModel.adjustPlayTime(seconds: -10)
          }
      }
      HStack {
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.getPlayingTime()))")
          .font(.footnote)
          .foregroundStyle(Color.gray.opacity(0.7))
        Spacer()
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.playingSoundDuration))")
          .font(.footnote)
          .foregroundStyle(Color.gray.opacity(0.7))
      }
    }
    .onAppear() {
      // 再生時間通知デリゲート開始
      viewModel.player.delegateCurrentTime = self
    }
    .onDisappear() {
      // 再生時間通知デリゲート終了
      viewModel.player.delegateCurrentTime = nil
    }
  }
}


class SliderViewModel: ObservableObject {
  @Published var tim: Double = 0
}
