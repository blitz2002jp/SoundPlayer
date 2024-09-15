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
  
  @State private var showPlayLists = false
  
  var body: some View {
    VStack {
      if let _playingSound = self.viewModel.currentPlayingSound {
        if let _playingGroup = self.viewModel.getGroup(targetSound: _playingSound) {
          TitleView(title: _playingSound.fileNameNoExt, subTitle: _playingGroup.displayText, menuContent: AnyView(PlayViewMenu(targetGroup: _playingGroup, targetSound: _playingSound)))
/*
 TitleView(title: _playingSound.fileNameNoExt, subTitle: _playingGroup.text, content: PlayViewMenu(targetGroup: _playingGroup, targetSound: _playingSound))

 
          TitleView(title: _playingSound.fileNameNoExt, subTitle: _playingGroup.text, targetGroup: _playingGroup, targetSound: _playingSound, trailingItem: .menu)
 */
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
                  if self.viewModel.player.isPlaying {
                    self.viewModel.pauseSound()
                  } else {
                    try self.viewModel.playSound()
                  }
/*
                  try viewModel.playSound(targetGroup: viewModel.playingGroup, targetSound: viewModel.getPlayingSound())
 */
                } catch {
                  utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
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
          HStack {
            Spacer()
            Button("A") {
              self.showPlayLists = true
            }
            .sheet(isPresented: self.$showPlayLists) {
              if #available(iOS 16.0, *) {
                SoundListView()
                  .presentationDetents([.medium])
              } else {
                SoundListView()
              }
            }
            Spacer()
          }
        } else { //_playingSound
        }
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

struct PlayViewMenu: View {
  var targetGroup: GroupInfo?
  var targetSound: SoundInfo?
  @State private var showMenu = false

  var body: some View {
    // メニュー
    Image(systemName: "ellipsis.circle")
      .frame(width: 20)
      .onTapGesture {
          self.showMenu = true
      }
      .sheet(isPresented: self.$showMenu)
    {
      if #available(iOS 16.0, *) {
        SoundActionMenu(targetGroup: targetGroup, targetSound: targetSound)
          .presentationDetents([.medium])
      } else {
        SoundActionMenu(targetGroup: targetGroup, targetSound: targetSound)
      }
    }
  }
}
