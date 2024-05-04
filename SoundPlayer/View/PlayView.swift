//
//  PlayView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/04/29.
//

import SwiftUI

struct PlayView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State var volume: Float = 0
  @State var randomBackColor: Color = .clear
  @State var repeateBackColor: Color = .clear
  
  var body: some View {
    VStack {
      TitleView(titleName: viewModel.getPlayingSound()?.fileNameNoExt ?? "", groupName: viewModel.playingGroup?.text ?? "", targetSound: viewModel.getPlayingSound())
      Spacer()
      if let _playingGroup = viewModel.playingGroup {
        if let _playingSound = viewModel.getPlayingSound() {
          if let _artWork = utility.getArtWorkImage(imageData: _playingSound.artWork) {
            _artWork
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          }
          
          Spacer()
          // 再生位置
          PositionSlider(playingSound: _playingSound)
          Spacer()
          
          HStack {
            Spacer()
            Image(systemName: "shuffle")
              .font(.title3)
              .background(self.randomBackColor)
              .onTapGesture {
                _playingGroup.isRandom = _playingGroup.isRandom ? false : true
                self.randomBackColor = self.getRandomBackColor(idRandom: _playingGroup.isRandom)
              }
              .onAppear() {
                self.randomBackColor = self.getRandomBackColor(idRandom: _playingGroup.isRandom)
              }
            Spacer()
            Image(systemName: "backward.fill")
              .font(.title3)
              .onTapGesture {
                viewModel.playPrevSound()
              }
            Spacer()
            Image(systemName: viewModel.player.isPlaying ? "pause.fill" :  "play.fill")
              .font(.title3)
              .onTapGesture {
                do {
                  try viewModel.playSound(targetGroup: viewModel.playingGroup, targetSound: viewModel.getPlayingSound())
                } catch {
                  print(error.localizedDescription)
                }
              }
            Spacer()
            Image(systemName: "forward.fill")
              .font(.title3)
              .onTapGesture {
                viewModel.playNextSound()
              }
            Spacer()
            Image(systemName: "infinity")
              .font(.title3)
              .background(self.repeateBackColor)
              .onTapGesture {
                _playingGroup.repeatMode = _playingGroup.repeatMode == .repeateAll ? .noRepeate : .repeateAll
                self.repeateBackColor = getRepeateColor(repeatMode: _playingGroup.repeatMode)
              }
              .onAppear() {
                self.repeateBackColor = getRepeateColor(repeatMode: _playingGroup.repeatMode)
              }
            Spacer()
          }
          
          Spacer()
          // ボリューム
          VolumeSlider(sliderVal: $volume)
        } else { //_playingSound
        }
      } else { //_playingGroup
      }
    }
    .padding([.leading, .trailing], 10)
  }
  
  func getRandomBackColor(idRandom: Bool) -> Color {
    return idRandom ? .primary.opacity(0.2) : .clear
  }
  func getRepeateColor(repeatMode: RepeatMode) -> Color {
    if repeatMode != .repeateAll {
      return .primary.opacity(0.2)
    }
    return .clear
  }
}
