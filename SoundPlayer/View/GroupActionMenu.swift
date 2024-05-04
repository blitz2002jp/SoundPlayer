//
//  GroupActionMenu.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/01.
//

import SwiftUI

struct GroupActionMenu: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showReNameDialog = false
  @State private var showDeleteAlert = false
  @State private var renameText = ""
  
  /// 操作対象Sound
  var targetGroup: GroupInfo
  /// 削除メッセージ
  var removeMessage: String = "削除しますか？"
  
  var body: some View {
    VStack {
      TitleView(titleName: self.targetGroup.text, showMenuIcon: false)
      
      List {
        Section {
          HStack {
            Image(systemName: "note.text.badge.plus")
            
            Text("名称変更")
              .onTapGesture {
                self.showReNameDialog.toggle()
              }
              .alert("名称変更", isPresented: self.$showReNameDialog) {
                TextField("User ID", text: self.$renameText)
                Button("Cancel"){  }
                Button("OK") {
                  do {
                    // GroupName 変更
                    try self.viewModel.renameGroupName(targetGroup: self.targetGroup, newGroupName: self.renameText)
                  } catch {
                    print(error.localizedDescription)
                  }
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
                Button("Cancel") {}
                Button("OK") {
                  do {
                    // 削除
                    try self.viewModel.removeGroup(targetGroup: targetGroup)
                  } catch {
                    print(error.localizedDescription)
                  }
                  // ダイアログClose
                  dismiss()
                }
              }
          }
        }
      }
      .onAppear() {
        self.renameText = self.targetGroup.text
      }
    }
  }
}
