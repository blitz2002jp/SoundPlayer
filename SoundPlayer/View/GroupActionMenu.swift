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
  @State private var showReNameAlert = false
  @State private var showReNameAlert15 = false
  @State private var showDeleteAlert = false
  @State private var renameText = ""
  @State private var okCancel: OkCancel = .cancel
  
  /// 操作対象Sound
  var targetGroup: GroupInfo?

  /// 削除メッセージ
  var removeMessage: String = "削除しますか？"
  
  var body: some View {
    VStack {
      if let _targetGroup = self.targetGroup {
        TitleView(title: _targetGroup.text, subTitle: "", targetGroup: targetGroup, targetSound: nil, trailingItem: .none)
      }

      List {
        Section {
          HStack {
            Image(systemName: "note.text.badge.plus")
            
            Text("名称変更")
              .onTapGesture {
                if #available(iOS 16.0, *) {
                  self.showReNameAlert.toggle()
                } else {
                  self.showReNameAlert15.toggle()
                }
              }
              // iOS 16 以降の場合はAlertで名称変更する
              .alert("名称変更", isPresented: self.$showReNameAlert) {
                TextField("", text: self.$renameText)
                Button("Cancel"){  }
                Button("OK") {
                  do {
                    // GroupName 変更
                    if let _targetGroup = self.targetGroup {
                      try self.viewModel.renameGroupName(targetGroup: _targetGroup, newGroupName: self.renameText)
                      // 再表示
                      viewModel.redraw()
                    }
                  } catch {
                    print(error.localizedDescription)
                  }
                }
                .disabled(!self.viewModel.validationGroupName(text: self.renameText))
              }
              .sheet(isPresented: self.$showReNameAlert15, onDismiss: {
                if self.okCancel == .ok {
                  do {
                    // GroupName 変更
                    try self.viewModel.renameGroupName(targetGroup: self.targetGroup, newGroupName: self.renameText)
                    
                    self.okCancel = .ok
                  } catch {
                    print(error.localizedDescription)
                  }
                }
                // 再表示
                viewModel.redraw()

              }) {
                InputTextView(okCancel: self.$okCancel, title: "名称変更", targetGroup: self.targetGroup, inputText: self.$renameText)
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
                    // 再表示
                    viewModel.redraw()
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
        if let _targetGroup = self.targetGroup {
          self.renameText = _targetGroup.text
        }
      }
    }
  }
}

struct InputTextView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @Binding var okCancel: OkCancel
  var title: String = "テキスト"
  /// 操作対象Sound
  var targetGroup: GroupInfo?

  @Binding var inputText: String
  
  var body: some View {
    TitleView(title: self.title, subTitle: "", targetGroup: targetGroup, targetSound: nil, trailingItem: .none)
    
    Spacer()
    
    VStack {
      TextField("", text: self.$inputText)
        .onAppear() {
          if let _targetGroup = self.targetGroup {
            self.inputText = _targetGroup.text
          }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.bottom, 50)
      
      HStack {
        Spacer()
        Button("Cancel") {
          self.okCancel = .cancel
          dismiss()
        }
        .frame(width: 170, height: 50) // 幅と高さを指定
        .background(.blue)
        .foregroundStyle(.primary)

        Spacer()

        Button("OK") {
          self.okCancel = .ok
          dismiss()
        }
        .frame(width: 170, height: 50) // 幅と高さを指定
        .background(self.viewModel.validationGroupName(text: self.inputText) ? Color.blue : Color.gray) // 背景色を指定
        .foregroundStyle(.white)
        .disabled(!self.viewModel.validationGroupName(text: self.inputText))

      }
    }
    .padding([.leading, .trailing], 20)
    Spacer()
  }
}
