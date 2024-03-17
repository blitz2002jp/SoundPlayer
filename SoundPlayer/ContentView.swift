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
//  @EnvironmentObject var vm: ViewModel
  @EnvironmentObject var viewModel: ViewModel
  @State private var nextView: subViews1 = .topView
  @State private var showTestSheet = false

  var body: some View {
    switch nextView {
    case .topView:
      List{
        Text("All List View")
          .onTapGesture{
            nextView = .AllSoundView
          }
        Text("FolderList View")
          .onTapGesture{
            nextView = .folderView
          }
        Text("PlayList View")
          .onTapGesture{
            nextView = .playListView
          }
        Text("Test1")
          .onTapGesture{
            showTestSheet.toggle()
          }
          .sheet(isPresented: $showTestSheet){
            CreateTestData()
          }
      }
    case .AllSoundView:
//      otherView(nextView: $nextView)
      GroupListView(viewTitle: "ALL", nextView: $nextView, targetGroupInfos: viewModel.fullSoundInfo)
    case .folderView:
//      GroupListView(viewTitle: "Folder", nextView: $nextView, targetGroupInfo: vm.playerLib.folderInfos)
      GroupListView(viewTitle: "Folder", nextView: $nextView, targetGroupInfos: viewModel.folderInfos)
    case .playListView:
//      GroupListView(viewTitle: "PlayList", nextView: $nextView, targetGroupInfo: vm.playerLib.playListInfos)
      GroupListView(viewTitle: "PlayList", nextView: $nextView, targetGroupInfos: viewModel.playListInfos)
    }
    
    // フッター
    Fotter()
    /*
    HStack {
      Text("\(viewModel.currentFileName)")
        .font(.footnote)
      
      // 繰り返しボタン
      RepeatButton()
    }
*/
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
