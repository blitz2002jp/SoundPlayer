//
//  SoundListView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/19.
//

import SwiftUI

/// SoundInfo List
struct SoundListView: View {
  var targetGroup: GroupInfo?
  @EnvironmentObject var viewModel: ViewModel
  @State private var repeateMode = RepeatMode.noRepeate
  @State private var isPresented = false
  @State private var volume : Float = 0
  @State private var currentTime: TimeInterval = TimeInterval.zero
  
  // アラート表示SwitchとMessage
  @State private var isShowAlert: Bool = false
  @State private var errorMessage = ""

  @State private var titleTime: TitleTimeModel = TitleTimeModel(title: "")
  @State private var saveViewResult: ResultSaveView = .cancel

  @State private var shouldHideImage = true // 初
  
  @State private var effectBounce = false   // イメージEffect
  @State private var sliderValSpeed: Double = 1.0   // イメージEffect Speed
  @State private var speakerEffect = false
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if let _targetGroup = targetGroup {
          ForEach(_targetGroup.soundInfos, id: \.id) { item in
            VStack {
              HStack {
                if let _artWorkImageData = item.artWork {
                  if let _artWorkUIImage = UIImage(data: _artWorkImageData) {
                    Image(uiImage: _artWorkUIImage)
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .overlay(utility.getPlayingImage(isPlaying: viewModel.isPlayingSound(groupInfo: _targetGroup, soundInfo: item), isSelected: item.isSelected, item: item)
                        .scaleEffect(self.speakerEffect ? 1 : 0.8)
                        .onAppear() {
                          withAnimation(.default.repeatForever().speed(viewModel.isPlayingSound(groupInfo: _targetGroup, soundInfo: item) ? 2.0 : 0.0)) {
                            self.speakerEffect.toggle()
                          }
                        }
                      )
                      .frame(width: 30, height: 30)
                  }
                }

                Text(item.text == "" ? item.fileNameNoExt : item.text)
                  .lineLimit(1)
                  .padding([.leading, .trailing, .top, .bottom], 20)
                  .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                  isPresented.toggle()
                }, label: {Image(systemName: "square.and.pencil")})
                .sheet(isPresented: $isPresented, onDismiss: {
                })
                {
                  if #available(iOS 16.0, *) {
                    SoundFileMenu()
                      .presentationDetents([.medium])
                  } else {
                    SoundFileMenu()
                  }
                }
              }
              .padding([.leading, .trailing], 20)
            }
            .onTapGesture {
              do {
                try viewModel.playSound(targetGroup: _targetGroup,  targetSound: item)
                viewModel.redraw()
              } catch {
                self.isShowAlert = true
                self.errorMessage = error.localizedDescription
              }
            }
          }
        }
      }
    }
    .onAppear {
    }
    .alert("Error", isPresented: $isShowAlert) {
      // ダイアログ内で行うアクション処理...
      
    } message: {
      // アラートのメッセージ...
      Text("エラーが発生しました\n\(self.errorMessage)")
    }
    
    Button("test") {
      withAnimation(.default.repeatForever().speed(2.0)) {
        self.speakerEffect.toggle()
      }
    }
  }
}
