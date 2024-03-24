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
  @Binding var nextView: subViews1
  var targetGroupInfos: [GroupInfo]
  @State private var isPresented = false
  
  // アラート表示SwitchとMessage
  @State private var isShowAlert = false
  @State private var errorMessage = ""
  
  //
  @State private var isEditing = false
  
  @State private var isActive = false
  
  @State private var selectItem: GroupInfo?
  
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
                    self.selectItem = item
                    isActive = true
                  }
                
                Spacer()
                Button(action: {
                  isEditing.toggle()
                }, label: {
                  Image(systemName: "pencil")
                })
                .padding(.trailing, 20)
                
                Button(action:{
                  do {
                    try self.viewModel.playGroup(targetGroup: item)
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
          .background(
            NavigationLink(destination: SoundListView(selectedItem: self.selectItem, viewModel: _viewModel), isActive: $isActive) {
              EmptyView()
            }
          )
        }
      }
      
      .navigationBarTitle(self.viewTitle, displayMode: .inline)
      .navigationBarItems(leading: Button(action: {nextView = .topView}, label: {
        HStack {
          Image(systemName: "chevron.left")
          Text("戻る")
        }
      }))
      
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
