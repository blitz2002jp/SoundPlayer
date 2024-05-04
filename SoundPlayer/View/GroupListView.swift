//
//  GroupListView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/02/19.
//

import SwiftUI

struct GroupListView: View {
  var viewTitle = "View Title"
  @EnvironmentObject var viewModel: ViewModel
  @Binding var nextView: subViews
  var targetGroupInfos: [GroupInfo]
  @State private var isPresented = false
  
  // アラート表示SwitchとMessage
  @State private var isShowAlert = false
  @State private var errorMessage = ""
  
  //
  @State private var isEditing = false
  
  @State private var isActive = false
  
  @State private var selectItemSoundList: GroupInfo?
  @State private var selectItemMenu: GroupInfo?

  var body: some View {
    VStack {
      NavigationView {
        ScrollView {
          VStack {
            ForEach(self.targetGroupInfos, id: \.id) { item in
              HStack{
                Text(item.text.count < 1 ? "Document" : item.text)
                  .lineLimit(1)
                  .padding([.leading, .trailing, .top, .bottom], 20)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .onTapGesture {
                    self.selectItemSoundList = item
                    isActive = true
                  }

                if !(item is FullSoundInfo) {
                  Button(action: {
                    self.selectItemMenu = item
                  }, label: {Image(systemName: "contextualmenu.and.cursorarrow")})
                  .sheet(item: self.$selectItemMenu, onDismiss: {} )
                  { item in
                    if #available(iOS 16.0, *) {
                      GroupActionMenu(targetGroup: item)
                        .presentationDetents([.medium])
                    } else {
                      GroupActionMenu(targetGroup: item)
                    }
                  }
                }
 
                Button(action:{
                  do {
                    try self.viewModel.playGroup(targetGroupInfo: item)
                  } catch {
                    self.errorMessage = error.localizedDescription
                    self.isShowAlert = true
                  }
                }, label: {
                  Image(systemName: "play.circle")
                })
              }
            }
          }
          .navigationTitle(self.viewTitle)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarItems(leading: Button(action: {nextView = .topView}, label: {
            HStack {
              Image(systemName: "chevron.left")
              Text("戻る")
            }
          }))
        }
        .background(
          NavigationLink(destination: SoundListView(targetGroup: self.selectItemSoundList, viewModel: _viewModel), isActive: $isActive) {
            EmptyView()
          })
      }
      .onAppear{
      }
      .alert("Error", isPresented: $isShowAlert) {
        // ダイアログ内で行うアクション処理...
        
      } message: {
        // アラートのメッセージ...
        Text("エラーが発生しました\n\(self.errorMessage)")
      }
    }
  }
}


struct nextTest2View: View {
  var body: some View {
    Button("return") {
      
    }
  }
}
