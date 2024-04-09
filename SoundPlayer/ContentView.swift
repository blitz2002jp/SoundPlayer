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
  @EnvironmentObject var viewModel: ViewModel
  @State private var nextView: subViews1 = .topView
  @State private var showTestSheet = false

  var body: some View {
    switch nextView {
    case .topView:
      List{
        HStack {
          Image(systemName: "internaldrive")
          Text("全曲")
            .onTapGesture{
              nextView = .AllSoundView
            }
        }
        HStack {
          Image(systemName: "folder")
          Text("フォルダ")
            .onTapGesture{
              nextView = .folderView
            }
        }
        HStack {
          Image(systemName: "music.note.list")
          Text("プレイリスト")
            .onTapGesture{
              nextView = .playListView
            }
        }
#if DEBUG
        Text("テスト")
          .onTapGesture{
            showTestSheet.toggle()
          }
          .sheet(isPresented: $showTestSheet){
            CreateTestDataView()
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
    Fotter(enableTap: true)
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
