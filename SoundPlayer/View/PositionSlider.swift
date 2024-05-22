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
  
  private var targetSound: SoundInfo {
    get {
      if let _playingSound = viewModel.getPlayingSound() {
        return _playingSound
      }
      return SoundInfo()
    }
  }
  
  // Playerからの再生時間通知デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    self.sliderViewModel.tim = currentTime
    
    // 音声情報に現在再生時間をセット
    self.targetSound.currentTime = currentTime
  }
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "goforward.10")
          .font(.title3)
          .onTapGesture {
            viewModel.adjustPlayTime(seconds: 10)
          }
        
        Slider(value: self.$sliderViewModel.tim, in: 0.0...Double(targetSound.duration()) + 1, step: 0.01)
        {}onEditingChanged: { isEditing in
          targetSound.currentTime = self.sliderViewModel.tim
          viewModel.setPlayTime(time: self.sliderViewModel.tim)
        }
        .onAppear() {
          self.sliderViewModel.tim = targetSound.currentTime
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
