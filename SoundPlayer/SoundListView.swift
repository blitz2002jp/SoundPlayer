//
//  SoundListView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/19.
//

import SwiftUI

/// SoundInfo List
struct SoundListView: View {
  var selectedItem: GroupInfo
//  @EnvironmentObject var viewModel: ViewModel
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

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(selectedItem.soundInfos, id: \.id) { item in
          VStack {
            HStack {
              Text(item.text == "" ? item.fileName : item.text)
                .lineLimit(1)
                .padding([.leading, .trailing, .top, .bottom], 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                  Rectangle()
                    .stroke(viewModel.getPlayModeColor(playMode: item), lineWidth: item.isSelectedx() ? 2 : 0)
                )
              Button("@"){
                let (hours, minutes, seconds) = utility.getHMS(time: viewModel.getCurrentTime())
                self.titleTime.hours = hours
                self.titleTime.minutes = minutes
                self.titleTime.seconds = seconds
                self.titleTime.titles = viewModel.playListInfos.map{ $0.text }
                isPresented.toggle()
              }
              .sheet(isPresented: $isPresented, onDismiss: {
                do {
                  // PlayListへの追加
                  print(self.titleTime.title)
                
                  switch self.saveViewResult {
                  case .cancel:
                    break
                  case .ok:
                    if let soundInfo = self.viewModel.getCurrentSound()?.copy() {
                      let groupInfo = GroupInfo(text: self.titleTime.title)
                      groupInfo.text = self.titleTime.title
                      groupInfo.soundInfos = [SoundInfo]()
                      soundInfo.startTimeStr = String("\(self.titleTime.hours):\(self.titleTime.minutes):\(self.titleTime.seconds)")
                      groupInfo.soundInfos.append(soundInfo)
                      self.viewModel.playListInfos.append(groupInfo)
                      print(utility.getSettingFilePathPlayList().absoluteString)
                      try utility.writeGroupInfo(url: utility.getSettingFilePathPlayList(), outputInfos: self.viewModel.playListInfos)
                    }
                  case .remove:
                    break
//                    self.viewModel.playListInfos = self.viewModel. { $0.id != self.viewModel.getCurrentSound()?.id }
                  }
/*
                  if self.saveVireResult == . {
                    if let soundInfo = self.viewModel.getCurrentSound()?.copy() {
                      let groupInfo = GroupInfo(text: self.titleTime.title)
                      groupInfo.text = self.titleTime.title
                      groupInfo.soundInfos = [SoundInfo]()
                      soundInfo.startTimeStr = String("\(self.titleTime.hours):\(self.titleTime.minutes):\(self.titleTime.seconds)")
                      groupInfo.soundInfos.append(soundInfo)
                      self.viewModel.playListInfos.append(groupInfo)
                      print(utility.getSettingFilePathPlayList().absoluteString)
                      try utility.writeGroupInfo(url: utility.getSettingFilePathPlayList(), outputInfos: self.viewModel.playListInfos)
                    }
 }
 */
                } catch {
                  self.isShowAlert = true
                }
                
              })
              {
                TitleTimeInput(model: self.titleTime, result: self.$saveViewResult)
              }
                
            }
            .padding([.leading, .trailing], 20)
          }
          .onTapGesture {
            do {
              try viewModel.playSound(targetSound: item)
              viewModel.redraw()
            } catch {
              self.isShowAlert = true
              self.errorMessage = error.localizedDescription
            }
          }
        }
      }
    }
    .onAppear {
      viewModel.changeGroup(targetGroup: selectedItem)
      viewModel.redraw()
    }
    .alert("Error", isPresented: $isShowAlert) {
      // ダイアログ内で行うアクション処理...
      
    } message: {
      // アラートのメッセージ...
      Text("エラーが発生しました\n\(self.errorMessage)")
    }
    
//    Spacer()
//    PositionSlider(sliderVal: $viewModel.currentTime)
    // フッター部分
//    HStack {
//      Spacer()
      
      // ボリューム
//      VolumeSlider(sliderVal: $volume)

      /*
      Text("Vol").font(.footnote)
      Slider(value:$sliderVal, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          print("onReceive:\(sliderVal)")
          viewModel.setVolume(volume: Float(sliderVal))
        }
        .font(.footnote)
       */
      
      
      /*
      // 再生ボタン
      PlayButton() {
        viewModel.playGroup()
      }
*/
      
      // 繰り返しボタン
//      RepeatButton()

//      Spacer()
//    }
//    .background(Color.white) // フッターの背景色を設定
  }
}
