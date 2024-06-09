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
      if let _playingGroup = viewModel.playingGroup {
        if let _playingSound = viewModel.getPlayingSound() {
          TitleView(title: _playingSound.fileNameNoExt, subTitle: _playingGroup.text, targetGroup: viewModel.playingGroup, targetSound: viewModel.getPlayingSound(), trailingItem: .menu)
          Spacer()

          if let _artWork = utility.getArtWorkImage(imageData: _playingSound.artWork, showArtWork: self.viewModel.settingInfo.showArtWork) {
            _artWork
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 200, height: 200)
          }
          
          Spacer()
          // 再生位置
          PositionSlider()
          Spacer()
          
          HStack {
            Spacer()
            RandomButton()
/*
            Image(systemName: "shuffle")
              .font(.title3)
              .background(self.randomBackColor)
              .onTapGesture {
                var randomMode = utility.getRandomMode()
                randomMode.toggle()
                utility.saveRandomMode(randomMode: randomMode)
                self.randomBackColor = self.getRandomBackColor(idRandom: randomMode)
              }
              .onAppear() {
                self.randomBackColor = self.getRandomBackColor(idRandom: utility.getRandomMode())
              }
 */
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
            RepeatButton()
            Spacer()
          }
          
          Spacer()
          // ボリューム
          VolumeSlider(sliderVal: $volume)
          Spacer()
        } else { //_playingSound
        }
      } else { //_playingGroup
      }
    }
    .padding([.leading, .trailing], 10)
  }
  
  func getRandomBackColor(idRandom: Bool) -> Color {
    return idRandom ? .yellow.opacity(0.5) : .clear
  }
  func getRepeateColor(repeatMode: RepeatMode) -> Color {
    return repeatMode == .repeateAll ? Color.yellow.opacity(0.5) : .clear
  }
}
