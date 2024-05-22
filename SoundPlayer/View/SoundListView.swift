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
              if item.isSelected {
                if viewModel.isPlayingSound(groupInfo: _targetGroup, soundInfo: item) {
                  HStack(spacing: 2) {
                    utility.getPlayingImage(isPlaying: true, item: item)
                    self.getArtWorkImage(soundInfo: item)
                  }
                } else {
                  HStack(spacing: 2) {
                    utility.getPlayingImage(isPlaying: false, item: item)
                    self.getArtWorkImage(soundInfo: item)
                  }
                }
              } else {
                HStack(spacing: 2) {
                  utility.getPlayingImage(isPlaying: false, item: item)
                  self.getArtWorkImage(soundInfo: item)
                }
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
              do {
                try viewModel.playSound(targetGroup: _targetGroup,  targetSound: item)
              } catch {
                print(error.localizedDescription)
              }
            }
          }
        }
      }
    }
    .navigationBarTitle(self.viewTitle)
    .onAppear() {
//      utility.debugPrint(msg: "******* createDataModel (SoundListView.onAppear)")
      // データモデル再作成
//      self.viewModel.createDataModel()
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

