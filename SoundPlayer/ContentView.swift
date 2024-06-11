//
//  ContentView.swift
//  MP3Player1
//
//  Created by masazumi oeda on 2023/12/26.
//

import SwiftUI
import AVFoundation

enum subViews: String{
  case topView
//  case AllSoundView
  case folderView
  case playListView
  case settingView
}

struct ContentView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var nextView: subViews = .topView
  @State private var showTestSheet = false
  
  @State private var textFieldValue = ""
  @State private var shouldShowAlertTextField = false
  
  var body: some View {
    switch nextView {
    case .topView:
      List {
        HStack {
          Image(systemName: "folder")
          Button(action: {
            // データモデル再作成
            self.viewModel.createDataModel()

            nextView = .folderView
          })
          { Text("全曲") }
            .foregroundStyle(.primary)
        }
        HStack {
          Image(systemName: "music.note.list")
          Button(action: {
            nextView = .playListView
          })
          { Text("プレイリスト") }
            .foregroundStyle(.primary)
        }
        HStack {
          Image(systemName: "wrench.and.screwdriver")
          Button(action: {
            nextView = .settingView
          })
          { Text("設定") }
            .foregroundStyle(.primary)
        }

        if utility.isPrivateMode() {
          HStack {
            Image(systemName: "wand.and.stars.inverse")
            Button(action: { self.showTestSheet.toggle() })
            { Text("テスト") }
              .foregroundStyle(.primary)
              .sheet(isPresented: self.$showTestSheet) {
                CreateTestDataView()
              }
          }
        }
      }
      .onAppear() {
//        utility.debugPrint(msg: "******* createDataModel (ContentView.onAppear)")
        // データモデル再作成
//        self.viewModel.createDataModel()
      }

    case .folderView:
      GroupListView(viewTitle: "全曲", nextView: $nextView, targetGroupType: .Folder)
    case .playListView:
      GroupListView(viewTitle: "プレイリスト", nextView: $nextView, targetGroupType: .PlayList)
    case .settingView:
      SettingView(nextView: $nextView)
    }
    
    if self.viewModel.getPlayingSound() != nil {
      // フッター
      Footer()
    }
  }
}

struct otherView: View {
  @Binding var nextView: subViews
  
  var body: some View {
    Text("Other View")
    Button("戻る"){
      nextView = .topView
    }
  }
}

//#Preview {
//  ContentView()
//}
