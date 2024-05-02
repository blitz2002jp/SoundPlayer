//
//  ContentView.swift
//  MP3Player1
//
//  Created by masazumi oeda on 2023/12/26.
//

import SwiftUI
import AVFoundation

enum subViews1: String{
  case topView
  case AllSoundView
  case folderView
  case playListView
}

struct ContentView: View {
  @Environment(\.colorScheme) var xxcolorScheme
  @EnvironmentObject var viewModel: ViewModel
  @State private var nextView: subViews1 = .topView
  @State private var showTestSheet = false

  var body: some View {
    let textColor: Color = xxcolorScheme == .dark ? .white : .black

    switch nextView {
    case .topView:
      List {
        HStack {
          Image(systemName: "internaldrive")
          Button(action: { nextView = .AllSoundView })
          { Text("全曲")}
            .foregroundStyle(.primary)
          
        }
        HStack {
          Image(systemName: "folder")
          Button(action: { nextView = .folderView })
          { Text("フォルダ") }
            .foregroundStyle(.primary)
        }
        HStack {
          Image(systemName: "music.note.list")
          Button(action: { nextView = .playListView })
          { Text("プレイリスト") }
            .foregroundStyle(.primary)
        }
#if DEBUG
        HStack {
          Image(systemName: "wand.and.stars.inverse")
          Button(action: { showTestSheet.toggle() })
          { Text("テスト") }
            .foregroundStyle(.primary)
        }
#endif
      }
    case .AllSoundView:
      GroupListView(viewTitle: "全曲", nextView: $nextView, targetGroupInfos: viewModel.fullSoundInfos)
    case .folderView:
      GroupListView(viewTitle: "フォルダ", nextView: $nextView, targetGroupInfos: viewModel.folderInfos)
    case .playListView:
      GroupListView(viewTitle: "プレイリスト", nextView: $nextView, targetGroupInfos: viewModel.playListInfos)
    }
    
    // フッター
    Fotter()
  }
}

struct otherView: View {
  @Binding var nextView: subViews1
  
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
