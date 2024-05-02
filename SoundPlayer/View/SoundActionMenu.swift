//
//  SoundActionMenu.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/04/30.
//

import SwiftUI

struct SoundActionMenu: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State private var titleTime: TitleTimeModel = TitleTimeModel(title: "")
  @State private var saveViewResult: ResultSaveView = .cancel
  @State private var showAddPlaylistDialod = false
  @State private var showDeleteAlert = false
  /// 操作対象Sound
  var targetSound: SoundInfo
  /// 削除メッセージ
  var removeMessage: String = "削除しますか？"
  
  
  var body: some View {
    VStack {
      TitleView(titleName: self.targetSound.fileNameNoExt, groupName: viewModel.playingGroup?.text ?? "", targetSound: viewModel.getPlayingSound(), showMenuIcon: false)
      
      List {
        Section {
          HStack {
            Image(systemName: "note.text.badge.plus")
            Text("プレイリストへ追加")
              .onTapGesture {
                let (hours, minutes, seconds) = utility.getHMS(time: viewModel.getPlayingTime())
                self.titleTime.hours = hours
                self.titleTime.minutes = minutes
                self.titleTime.seconds = seconds
                self.titleTime.titles = viewModel.playListInfos.map{ $0.text }
                self.showAddPlaylistDialod.toggle()
              }
              .sheet(isPresented: $showAddPlaylistDialod, onDismiss: {
                if self.saveViewResult == .ok {
                  // 追加するSoundInfoの作成
                  let addSoundInfo = self.targetSound.copy()
                  addSoundInfo.currentTime = utility.stringToTimeInterval(HHMMSS: "\(self.titleTime.strHours):\(self.titleTime.strMinutes):\(self.titleTime.strSeconds)")
                  
                  // PlayList作成
                  var playList = viewModel.playListInfos.first(where: {$0.text == self.titleTime.title})
                  if playList == nil {
                    playList = PlayListInfo(text: self.titleTime.title)
                    viewModel.playListInfos.append(playList!)
                  }
                  playList?.soundInfos.append(addSoundInfo)
                  
                  utility.saveGroupInfo(outputInfos: viewModel.playListInfos)
                }
              })
            {
              if #available(iOS 16.0, *) {
                TitleTimeInput(model: self.titleTime, result: self.$saveViewResult)
                  .presentationDetents([.medium])
              } else {
                TitleTimeInput(model: self.titleTime, result: self.$saveViewResult)
              }
            }
          }
          HStack {
            Image(systemName: "trash")
            Text("削除")
              .onTapGesture {
                self.showDeleteAlert = true
              }
              .alert(self.removeMessage, isPresented: self.$showDeleteAlert) {
                Button("Cancel"){
                }
                Button("OK"){
                  // Sound削除
                  self.viewModel.removeSound(targetSound: targetSound)
                  // 再描画
                  self.viewModel.redraw()
                  // ダイアログClose
                  dismiss()
                }
              }
          }
        }
      }
    }
  }
}
