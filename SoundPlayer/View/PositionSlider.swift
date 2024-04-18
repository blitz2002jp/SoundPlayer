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
//  @Binding var sliderVal: TimeInterval
//  @State var duration: TimeInterval
//  @State private var slv: Double = Double.zero
  @StateObject private var sliderViewModel = SliderViewModel()
  
  // Playerからの再生時間通知デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
#if DEBUG
    print("** notifyCurrentTime")
#endif
    
    self.sliderViewModel.tim = currentTime
    
    // 音声情報に現在再生時間をセット
    if let _currentSound = self.viewModel.getCurrentSelectedSound() {
      _currentSound.currentTime = currentTime
    }
    
    // 現在再生時間の保存
    utility.saveCurrentPlayTime(currentTime: utility.timeIntervalToString(timeFormat: .HHMMSS, timeInterval: currentTime))
    
    // 再描画
    //viewModel.redraw()
  }
  
  var body: some View {
    VStack {
      HStack {
        if let _currentSound = self.viewModel.getCurrentSelectedSound() {
          Slider(value: self.$sliderViewModel.tim, in: 0.0...Double(_currentSound.duration()) + 1, step: 0.01)
          {}onEditingChanged: { isEditing in
            _currentSound.currentTime = self.sliderViewModel.tim
            viewModel.setPlayTime(time: self.sliderViewModel.tim)
          }
          .padding([.trailing, .leading], 0)
          .onAppear() {
//            sliderVal = viewModel.getCurrentTime()
            self.sliderViewModel.tim = _currentSound.currentTime
          }
        }
      }
      HStack {
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.getCurrentTime()))")
          .font(.footnote)
          .foregroundStyle(Color.gray.opacity(0.7))
        Spacer()
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.currentSoundDuration))")
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
