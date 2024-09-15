//
//  SoundListView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/19.
//

import SwiftUI

/// SoundInfo List
struct SoundListView: View {
  var viewTitle = "View Title"
  var targetGroup: GroupInfo?
  @EnvironmentObject var viewModel: ViewModel
  
  @State private var sliderValSpeed: Double = 1.0   // イメージEffect Speed
  @State private var speakerEffect = false
  
  @State private var selectedItem: SoundInfo?
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if let _targetGroup = targetGroup {
          ForEach(_targetGroup.soundInfos, id: \.id) { item in
#if DEBUG
              let _ = self.debug1(soundInfo: item)
#endif
            HStack {
              HStack(spacing: 2) {
                self.speakerImage(targetSound: item)
                self.viewModel.getArtWorkImage(soundInfo: item)
              }

              Text(item.text == "" ? item.fileNameNoExt : item.text)
                .lineLimit(1)
                .padding([.leading, .trailing, .top, .bottom], 10)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Button(action: {
                self.selectedItem = item
              }, label: {Image(systemName: "ellipsis")})
              .sheet(item: self.$selectedItem, onDismiss: {
              })
              { item in
                if #available(iOS 16.0, *) {
                  SoundActionMenu(targetGroup: _targetGroup, targetSound: item)
                    .presentationDetents([.medium])
                } else {
                  SoundActionMenu(targetGroup: _targetGroup, targetSound: item)
                }
              }
            }
            .padding([.leading, .trailing], 20)
            .onTapGesture {
                // 現在最中音声と同じ
                if let _currentPlayingSound = self.viewModel.currentPlayingSound {
                  if _currentPlayingSound == item {
                    if self.viewModel.player.isPlaying {
                      // 停止
                      self.viewModel.pauseSound()
                      return
                    }
                  }
                }

              do {
                // 再生リスト作成
                self.viewModel.changSoundList(targetGroup: _targetGroup)
                
                // 再生対象の選択
                self.viewModel.selectPlaySound(targetSound: item)
                
                // 再生
                try self.viewModel.playSound()
              } catch {
                utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
              }
            }
          }
        }
      }
    }
    .navigationBarTitle(self.viewTitle)
  }

  // スピーカーImage取得
  @ViewBuilder private func speakerImage(targetSound: SoundInfo) -> some View {
    @State var speakerImageName = "speaker"
    if targetSound.isSelected {
      Image(systemName: viewModel.isPlayingSound(targetSound: targetSound) ? "speaker.zzz" : "speaker")
        .frame(width: 20, height: 20)
        .foregroundStyle(.primary)
    } else {
      Color.clear
        .frame(width: 20, height: 20)
    }
  }

#if DEBUG
  private func debug1(soundInfo: SoundInfo) -> Int{
    utility.debug3(soundInfo: soundInfo, tag: "SoundListView 1234567")
    return 0
  }
private func getIndex(idx: Int) -> Int {
  return idx + 1
}
#endif
}

