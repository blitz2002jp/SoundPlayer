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
  
  // 対象データ・タイプ
  var targetGroupType: GroupType
  
  @State private var idx = -1
  
  // 対象データ
  var targetGroupInfos: [GroupInfo] {
    get {
      if let _targetGroupInfos = viewModel.getGroupInfos(groupType: self.targetGroupType) {
        return _targetGroupInfos
      }
      
      return [GroupInfo]()
    }
  }
  
  // アラート表示SwitchとMessage
  @State private var isShowAlert = false
  
  @State private var isActive = false
  
  @State private var selectItemGroup: GroupInfo?
  @State private var selectItemMenu: GroupInfo?
  
  private var selectItemGroupText: String {
    if let _selectItemGroup = self.selectItemGroup {
      return _selectItemGroup.displayText
    }
    return ""
  }

  var body: some View {
    VStack {
      NavigationView {
        ScrollView {
          VStack {
            ForEach(self.targetGroupInfos, id: \.id) { item in
              HStack{
                Text(item.displayText)
                  .lineLimit(1)
                  .padding([.leading, .trailing, .top, .bottom], 20)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .onTapGesture {
                    self.selectItemGroup = item
                    isActive = true
                  }
                if !(item is FullSoundInfo) {
                  Button(action: {
                    self.selectItemMenu = item
                  }, label: {Image(systemName: "ellipsis")})
                  .disabled(item.text == "")
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
                    utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
                    self.isShowAlert = true
                  }
                }, label: {
                  Image(systemName: "play.circle")
                })
              }
              .onTapGesture {
                print("****** \(item.text) ******")
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
          NavigationLink(destination: SoundListView(viewTitle: self.selectItemGroupText, targetGroup: self.selectItemGroup, viewModel: _viewModel), isActive: $isActive) {
            EmptyView()
          })
/*
        .background(
          NavigationLink(destination: SoundListView(viewTitle: self.selectItemGroup?.text, targetGroup: self.selectItemGroup, viewModel: _viewModel), isActive: $isActive) {
            EmptyView()
          })
 */
      }
    }
  }
  
  #if DEBUG
  private func getIndex(idx: Int) -> Int {
    return idx + 1
  }
  
  private func debug1(group: GroupInfo?) -> Int {
    if var _group = group {
      withUnsafePointer(to: &_group) { pointer in
        utility.debugPrint(msg: "\(pointer)")
      }
    }
    return 0
  }
  private func debug2(groups: [GroupInfo]) -> Int {
    groups.forEach { item in
      var _item = item
      withUnsafePointer(to: &_item) { pointer in
        utility.debugPrint(msg: "\(pointer)")
      }
    }
    return 0
  }
  #endif
}
