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
  
  @State private var isPresented = false
  
  // アラート表示SwitchとMessage
  @State private var isShowAlert: Bool = false
  @State private var errorMessage = ""
  
  @State private var sliderValSpeed: Double = 1.0   // イメージEffect Speed
  @State private var speakerEffect = false
  
  @State private var selectedItem: SoundInfo?
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if let _targetGroup = targetGroup {
          ForEach(_targetGroup.soundInfos, id: \.id) { item in
            HStack {
              if item.isSelected {
                if viewModel.isPlayingSound(groupInfo: _targetGroup, soundInfo: item) {
                  HStack(spacing: 2) {
                    utility.getPlayingImage(isPlaying: true, isSelected: true, item: item)
                    self.getArtWorkImage(soundInfo: item)
                  }
                } else {
                  HStack(spacing: 2) {
                    utility.getPlayingImage(isPlaying: false, isSelected: true, item: item)
                    self.getArtWorkImage(soundInfo: item)
                  }
                }
              } else {
                HStack(spacing: 2) {
                  utility.getPlayingImage(isPlaying: false, isSelected: false, item: item)
                  self.getArtWorkImage(soundInfo: item)
                }
              }
              Text(item.text == "" ? item.fileNameNoExt : item.text)
                .lineLimit(1)
                .padding([.leading, .trailing, .top, .bottom], 10)
                .frame(maxWidth: .infinity, alignment: .leading)
              
              Button(action: {
                self.selectedItem = item
              }, label: {Image(systemName: "contextualmenu.and.cursorarrow")})
              .sheet(item: self.$selectedItem, onDismiss: {
              })
              { item in
                if #available(iOS 16.0, *) {
                  SoundActionMenu(targetSound: item)
                    .presentationDetents([.medium])
                } else {
                  SoundActionMenu(targetSound: item)
                }
              }
            }
            
            .padding([.leading, .trailing], 20)
            .onTapGesture {
              do {
                try viewModel.playSound(targetGroup: _targetGroup,  targetSound: item)
              } catch {
                self.isShowAlert = true
                self.errorMessage = error.localizedDescription
              }
            }
          }
          .alert("Error", isPresented: $isShowAlert) {
            // ダイアログ内で行うアクション処理...
            
          } message: {
            // アラートのメッセージ...
            Text("エラーが発生しました\n\(self.errorMessage)")
          }
        }
      }
    }
  }
  
  func getArtWorkImage(soundInfo: SoundInfo) -> some View {
    var image: Image
    
    if let _image = utility.getArtWorkImage(imageData: soundInfo.artWork) {
      image = _image
    } else {
      image = Image(systemName: "clear")
    }
    
    return image
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 30, height: 30)
  }
}

