//
//  SearchSounds.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/25.
//

import SwiftUI

struct SearchSounds: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  
  @State private var searchText = ""
  @State private var searchedItem = [GroupInfo]()
  
  var body: some View {
    GeometryReader { geo in
      //      VStack {
      HStack {
        Spacer()
        // Close
        Image(systemName: "chevron.down").onTapGesture {dismiss()}
        Spacer()
        // 検索キーワード
        Capsule()
          .opacity(0.1)
          .overlay(content: {
            HStack {
              Image(systemName: "magnifyingglass")
                .padding(.leading, 10)
              TextField("検索キーワード", text: self.$searchText)
            }
          })
          .onChange(of: searchText) { oldState, newState in
            self.searchedItem = viewModel.searchSounds(searchText: newState)
          }
          .frame(width: geo.size.width * 0.85)
        Spacer()
      }
      .frame(height: 50)
      .padding(.top, 20)
      Divider()
      Spacer()
    }
    
    List {
      ForEach( self.searchedItem, id: \.id) { itemGrp in
        Section {
          ForEach( itemGrp.soundInfos, id: \.id) {itemSound in
            HStack {
              viewModel.getArtWorkImage(soundInfo: itemSound)
              Text(itemSound.fileNameNoExt)
            }
            .onTapGesture {
              do {
                try viewModel.playSound(targetGroup: itemGrp,  targetSound: itemSound)
              } catch {
                print(error.localizedDescription)
              }
            }
            
          }
        } header: {
          Text(self.getSectionTitle(groupInfo: itemGrp))
        }
      }
    }
  }
  
  private func getSectionTitle(groupInfo: GroupInfo) -> String {
    var res = ""
    switch groupInfo.groupType {
    case .Folder:
      res = "全曲/"
      if groupInfo.text == "" {
        res += "Document"
      } else {
        res += groupInfo.text
      }
      break
    case .FullSound:
      break
    case .PlayList:
      res = "プレイリスト/"
      res += groupInfo.text
      break
    }
    return res
  }
}
