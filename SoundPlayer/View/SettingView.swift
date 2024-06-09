//
//  SettingView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/06/05.
//

import SwiftUI

struct SettingView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var nextView: subViews
  @State var showArtwork = false
  var body: some View {
    VStack {
      NavigationView {
        List {
          HStack {
            Text("アートワーク表示")
            Toggle(isOn: self.$showArtwork) {
            }
          }
        }
        .onAppear() {
          self.showArtwork = self.viewModel.settingInfo.showArtWork
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
          self.viewModel.settingInfo.showArtWork = self.showArtwork
          
          self.viewModel.settingInfo.name = String("\(self.showArtwork)")

          // 設定情報の保存
          utility.saveSettingInfo(outputInfo: self.viewModel.settingInfo)

          
          
          nextView = .topView
        }, label: {
          HStack {
            Image(systemName: "chevron.left")
            Text("戻る")
          }
        }))
      }
    }
  }
}
