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
  @State private var saveViewResult: OkCancel = .cancel
  @State private var showAddPlaylistDialod = false
  @State private var showDeleteAlert = false
  /// 操作対象group Sound
  var targetGroup: GroupInfo?
  var targetSound: SoundInfo?
  /// 削除メッセージ
  var removeMessage: String = "削除しますか？"
  
  var body: some View {
    VStack {
      if let _targetGroup = targetGroup {
        if let _targetSound = targetSound {
          TitleView(title: _targetSound.fileNameNoExt, subTitle: _targetGroup.text, targetGroup: targetGroup, targetSound: targetSound, trailingItem: .none)
        }
      }
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
              .sheet(isPresented: $showAddPlaylistDialod)
            {
              if #available(iOS 16.0, *) {
                TitleTimeInput(model: self.titleTime, targetGroup: targetGroup, targetSound: targetSound)
                  .presentationDetents([.medium])
              } else {
                TitleTimeInput(model: self.titleTime, targetGroup: targetGroup, targetSound: targetSound)
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
                  self.viewModel.removeSound(targetGroup: targetGroup, targetSound: targetSound)
                  // 再描画
                  self.viewModel.redraw()
                  // ダイアログClose
                  dismiss()
                }
              }
          }
        }
        .padding([.leading, .trailing], 10)
      }
    }
  }
}
