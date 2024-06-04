//
//  TitleTimeInput.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/12.
//

import SwiftUI

struct TitleTimeInput: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var model: TitleTimeModel
  @Environment(\.dismiss) var dismiss
  @State private var selectedValues = [0, 0, 0]
  @State private var selectedPlayList: String = ""
  @State private var pickerItems: [String]?
  @State private var showInputNewNameArert = false
  @State private var showInputNewNameArert15 = false
  @State private var okCancel: OkCancel = .cancel
  @State private var newPlaylistName = ""
  /// 操作対象Group Sound
  var targetGroup: GroupInfo?
  var targetSound: SoundInfo?
  
  var body: some View {
    if let _playingGroup = targetGroup {
      if let _playingSound = targetSound {
        VStack {
          TitleView(title: _playingSound.fileNameNoExt, subTitle: _playingGroup.text, targetGroup: targetGroup, targetSound: targetSound, trailingItem: .none) {
          }
          
          List {
            Picker("", selection: $selectedPlayList) {
              if let _pickerItems = pickerItems {
                ForEach(Array(_pickerItems.enumerated()), id: \.element) { index, item in
                  if index == 0 {
                    // 新規プレイリスト追加
                    HStack {
                      Image(systemName: "text.badge.plus")
                        .foregroundStyle(.blue)
                      Text(item)
                        .foregroundStyle(.blue)
                    }
                    .onTapGesture {
                      if #available(iOS 16.0, *) {
                        self.showInputNewNameArert.toggle()
                      } else {
                        self.showInputNewNameArert15.toggle()
                      }
                    }
                    .alert("プレイリスト名", isPresented: self.$showInputNewNameArert) {
                      TextField("", text: self.$newPlaylistName)
                      Button("Cancel"){}
                      Button("OK") {
                        // 追加
                        let copySound = _playingSound.copy()
                        copySound.isSelected = false
                        self.viewModel.playListInfos.append(PlayListInfo(text: self.newPlaylistName, soundInfos: [copySound]))
                        // 保存
//                        utility.saveGroupInfo(outputInfos: self.viewModel.playListInfos)
                        self.viewModel.saveGroupInfos()
                        
                        dismiss()
                      }
                      .disabled(!self.viewModel.validationGroupName(text: newPlaylistName))
                    }
                    .sheet(isPresented: self.$showInputNewNameArert15, onDismiss: {
                      if self.okCancel == .ok {
                        // 追加
                        self.viewModel.playListInfos.append(PlayListInfo(text: self.newPlaylistName, soundInfos: [_playingSound.copy()]))
                        // 保存
//                        utility.saveGroupInfo(outputInfos: self.viewModel.playListInfos)
                        self.viewModel.saveGroupInfos()

                        dismiss()
                      }

                      // 再表示
                      viewModel.redraw()
                    }) {
                      InputTextView(okCancel: self.$okCancel, title: "プレイリスト名", inputText: self.$newPlaylistName)
                    }
                  } else {
                    // 既存のプレイリスト
                    Text(item)
                  }
                }
              }
            }
          }
          .pickerStyle(.inline)
          .onAppear() {
            self.pickerItems = ["新規プレイリスト作成"]
            self.pickerItems?.append(contentsOf: viewModel.playListInfos.map { $0.text })
          }
          
          if utility.isPrivateMode() {
            // Duration取得
            let (hours, minutes, seconds) = utility.getHMS(time: _playingSound.duration())
            Section(header: Text("再生開始時間")) {
              HStack {
                Picker(selection: $selectedValues[0], label: Text("")) {
                  ForEach(0..<hours, id: \.self) { index in
                    Text("\(index)")
                  }
                }
                .disabled(hours < 1)
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
                Text(":")
                
                Picker(selection: $selectedValues[1], label: Text("")) {
                  ForEach(0..<60) { index in
                    Text("\(index)")
                  }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
                Text(":")
                
                Picker(selection: $selectedValues[2], label: Text("")) {
                  ForEach(0..<60) { index in
                    Text("\(index)")
                  }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
              }
            }
          }
          Spacer()
          Button(action: {
            // 既存のプレイリストに追加
            if let _targetPlayList = self.viewModel.playListInfos.first(where: {$0.text == self.selectedPlayList}) {
              if let _targetSound = self.targetSound {
                let copySound = _playingSound.copy()
                copySound.startTimeStr = String("\(selectedValues[0]):\(selectedValues[1]):\(selectedValues[2])")
                copySound.isSelected = false
                _targetPlayList.soundInfos.append(copySound)
                // 保存
                utility.saveGroupInfo(outputInfos: self.viewModel.playListInfos)
              }
            }
            dismiss()
          }, label: {Text("OK")})
            .disabled(!self.isSelected())
        }
      }
    }
  }
  
  private func isSelected() -> Bool {
    if self.selectedPlayList.count > 0 {
      return true
    }
    return false
  }
}


///
///
///  タイトル、時間の入力View
///
///
class TitleTimeModel {
  var title = ""
  var titles = [String]()
  var hours = 0
  var minutes = 0
  var seconds = 0
  var strHours: String {
    get{
      return String(format: "%02d", self.hours)
    }
    set(val){
      self.hours = Int(val) ?? 0
    }
  }
  var strMinutes: String {
    get{
      return String(format: "%02d", self.minutes)
    }
    set(val){
      self.minutes = Int(val) ?? 0
    }
  }
  var strSeconds: String {
    get{
      return String(format: "%02d", self.seconds)
    }
    set(val){
      self.seconds = Int(val) ?? 0
    }
  }

  init(title: String, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
    self.title = title
    self.hours = hours
    self.strHours = String(format: "%02d", hours)
    self.minutes = minutes
    self.strMinutes = String(format: "%02d", minutes)
    self.seconds = seconds
    self.strSeconds = String(format: "%02d", seconds)
  }
}
