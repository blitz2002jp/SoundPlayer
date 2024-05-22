//
//  ViewCompornent.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/01/20.
//

import Foundation
import SwiftUI

/// Randomボタン
struct RandomButton: View {
  @State var randomMode: Bool = utility.getRandomMode()

  var body: some View {
    Image(systemName: "shuffle")
      .foregroundStyle(.primary)
      .opacity(randomMode ? 1.0 : 0.2)
      .font(.title3)
      .onTapGesture {
        self.randomMode = utility.getRandomMode()
        self.randomMode.toggle()
        utility.saveRandomMode(randomMode: self.randomMode)
      }
  }
}
/// Repeateボタン
struct RepeatButton: View {
  @State var repeateMode: RepeatMode = .noRepeate
  @State var buttonName = "cat"
  @State var buttonOpacity = 0.2
  
  var body: some View {
    
    Button(action: {
      self.repeateMode = utility.getNextRepeatMode()
      // アイコンをクリックした時のアクション
      utility.saveRepearMode(repeatMode: self.repeateMode)
      
      self.setProperty()
    })
    {
      Image(systemName: self.buttonName)
        .foregroundColor(.primary)
        .imageScale(.large)
        .opacity(self.buttonOpacity)
    }
    .onAppear() {
      self.setProperty()
    }
  }
  private func setProperty() {
    self.repeateMode = utility.getRepearMode()
    
    switch self.repeateMode {
    case .noRepeate:
      self.buttonName = "repeat"
      self.buttonOpacity = 0.2
    case .repeateOne:
      self.buttonName = "repeat.1"
      self.buttonOpacity = 1.0
    case .repeateAll:
      self.buttonName = "repeat"
      self.buttonOpacity = 1.0
    }
  }
}

/// 詳細入力ボタン
struct SoundDetailButton: View {
  @EnvironmentObject var viewModel: ViewModel
  var action: () -> Void

  var body: some View {
    Button("#"){
      self.action()
      // 再描画
      viewModel.redraw()
    }
  }
}

/// Playボタン
struct PlayButton: View {
  @EnvironmentObject var viewModel: ViewModel
  var action: () -> Void
  
  var body: some View {
    Button(action: {
      self.action()
      
      // 再描画
      viewModel.redraw()
    })
    {
      // 表示を切り替える
      if self.viewModel.playMode == .play {
        Image(systemName: "pause")
          .imageScale(.large)
      } else {
        Image(systemName: "play")
          .imageScale(.large)
      }
    }
    .padding()
  }
}

/// ボリュームSlider
struct VolumeSlider: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var sliderVal: Float

  var body: some View {
    HStack {
      Button(action: {
        sliderVal = sliderVal > 0.0 ? sliderVal - 0.05 : 0.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.wave.1") })
      .foregroundStyle(.primary)

      Slider(value: $viewModel.volome, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          viewModel.volome = Float(sliderVal)
        }
        .onAppear() {
          sliderVal = viewModel.volome
        }

      Button(action: {
        sliderVal = sliderVal < 1.0 ? sliderVal + 0.05 : 1.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.wave.3") })
      .foregroundStyle(.primary)
    }
  }
  func volumeAdjust() {
    sliderVal = sliderVal > 0.0 ? sliderVal - 0.05 : 0.0
    viewModel.volome = sliderVal
  }
}

struct Fotter: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var isShowSheet = false
  
  var body: some View {
    HStack {
      Button(action: { self.isShowSheet = true })
      {
        Text("\(viewModel.getPlayingSound()?.fileNameNoExt ?? "")")
        .font(.footnote)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .padding(.leading, 10)
      }
      .foregroundStyle(.primary)

      Spacer()
      Image(systemName: viewModel.playMode == .play ? "pause" : "play.fill")
        .imageScale(.large)
        .padding(.trailing, 10)
        .onTapGesture {
          if let _playingGroup = self.viewModel.playingGroup {
            if let _selectedSound = self.viewModel.getPlayingSound() {
              try? self.viewModel.playSound(targetGroup: _playingGroup, targetSound: _selectedSound)
            }
          }
        }

      Image(systemName: "forward.fill")
        .imageScale(.large)
        .padding(.trailing, 10)
    }
    .sheet(isPresented: $isShowSheet, onDismiss: {
    }) {
      if #available(iOS 16.0, *) {
        PlayView()
          .presentationDetents([.medium])
      } else {
        PlayView()
      }
    }
    .frame(height: 40)
    .background(
      // 背景に透明なViewを追加して、それをタップしたときにシートが表示されるようにする
      Color.gray
        .contentShape(Rectangle())
    )
  }
}

struct TitleView: View {

  enum TrailingItem {
    case none
    case menu
  }

  var title: String
  var subTitle : String
  
  // 対象Group Sound
  var targetGroup: GroupInfo?
  var targetSound: SoundInfo?

  var trailingItem:TrailingItem = .none
  var onOk: () -> Void = {}
  @State private var showMenu = false
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    VStack {
      HStack {
        // Close
        Image(systemName: "chevron.down")
          .onTapGesture {
            dismiss()
          }

        // Imageを右寄せにするためにSpacerを追加
        Spacer()
        Text(self.title)
          .font(.title3)
        // Textを水平方向に拡張して中央寄せにする
          .frame(maxWidth: .infinity)
        // 複数行の場合にも中央寄せにする
          .multilineTextAlignment(.center)
        
//        if self.trailingItem == .menu {
          // メニュー
          Image(systemName: "ellipsis.circle")
            .opacity(self.trailingItem == .menu ? 1.0 : 0.0)
            .onTapGesture {
              if self.trailingItem == .menu {
                self.showMenu = true
              }
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
//      }
      Text(self.subTitle == "" ? "Document" : self.subTitle)
        .font(.footnote)
        .foregroundStyle(Color.gray.opacity(0.5))
      Divider()
    }
    .padding([.top, .leading, .trailing], 10)
  }
}
