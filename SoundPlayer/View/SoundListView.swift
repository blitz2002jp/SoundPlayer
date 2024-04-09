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
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if let _targetGroup = targetGroup {
          ForEach(_targetGroup.soundInfos, id: \.id) { item in
            VStack {
              HStack {
                if viewModel.player.isPlaying {
                  Image(systemName: "speaker.zzz")
                    .opacity(item.isSelected ? 1 : 0)
                    .frame(width: 10)
                } else {
                  Image(systemName: "speaker")
                    .opacity(item.isSelected ? 1 : 0)
                    .frame(width: 10)
                }
                Text(item.text == "" ? item.fileName : item.text)
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
  }
}
