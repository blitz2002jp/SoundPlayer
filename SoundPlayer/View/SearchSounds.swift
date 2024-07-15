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
  @State private var selectedItem: SoundInfo?

  @State private var selectedGroup: SegmentType = .all
  private enum SegmentType: CaseIterable {
    case all
    case folder
    case palyList
  }
  
  @State private var timer: Timer?

  var body: some View {
    VStack {
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
                  .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
              }
            })
            .onChange(of: searchText) { newState in
              self.timer?.invalidate()
              self.timer = Timer.scheduledTimer(withTimeInterval:1.0, repeats: true){ _ in
                self.timer?.invalidate()

                utility.debugPrint(msg: "**SEARCE**(\(newState)")
                 // 検索
                 viewModel.SearchSound(searchText: newState)
                 
                 // 検索キーワード保存
                 utility.saveSearchKeyword(searchKeyword: newState)
                 viewModel.redraw()
              }
            }
            .frame(width: geo.size.width * 0.85)
          Spacer()
        }
        .frame(height: 50)
        .padding(.top, 20)
        Divider()
      }
      .frame(height: 100)
      
      Spacer()
      
      Picker("Layout", selection: $selectedGroup) {
          ForEach(SegmentType.allCases, id: \.self) {
              type in
              switch type {
              case .all:
                  Text("すべて")
              case .folder:
                  Text("全曲")
              case .palyList:
                  Text("プレイリスト")
              }
          }
      }.pickerStyle(SegmentedPickerStyle())
          .padding()

      Spacer()
      
      List {
        if self.selectedGroup == .all
            || self.selectedGroup == .folder {
          // Folder検索結果作成
          SearchedItemList(itemGrps: viewModel.folderInfos)
        }
        
        if self.selectedGroup == .all
            || self.selectedGroup == .palyList {
          // PlayList検索結果作成
          SearchedItemList(itemGrps: viewModel.playListInfos)
        }
      }
      .onAppear() {
        // 保存した検索キーワード取得
        self.searchText = utility.getSearchKeyword()

        // 検索
        viewModel.SearchSound(searchText: self.searchText)
      }
    }
  }
}
  
/// 検索結果List作成
  struct SearchedItemList: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State var itemGrps: [GroupInfo]
    @State private var selectedItem: SoundInfo?
    
    var body: some View {
      ForEach( itemGrps, id: \.id ) { itemGrp in
        // 検索結果がある場合
        if itemGrp.soundInfos.contains(where: {$0.isSearched} ) {
          Section {
            ForEach(itemGrp.soundInfos, id: \.id) { itemSound in
              if itemSound.isSearched {
                HStack {
                  viewModel.getArtWorkImage(soundInfo: itemSound)
                  Text(itemSound.fileNameNoExt)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Image(systemName: "ellipsis")
                    .onTapGesture {
                      self.selectedItem = itemSound
                    }
                    .sheet(item: self.$selectedItem, onDismiss: {
                    })
                  { item in
                    if #available(iOS 16.0, *) {
                      SoundActionMenu(targetGroup: itemGrp, targetSound: itemSound)
                        .presentationDetents([.medium])
                    } else {
                      SoundActionMenu(targetGroup: itemGrp, targetSound: itemSound)
                    }
                  }
                }
                .onTapGesture {
                  do {
                    try viewModel.playSound(targetGroup: itemGrp,  targetSound: itemSound)
                  } catch {
                    print(error.localizedDescription)
                  }
                }
              }
            }
          } header: {
            Text(itemGrp.text == "" ? "Document" : itemGrp.text)
          }
          // Sectionヘッダ文字がすべて大文字になるのを防ぐ
          .headerProminence(.increased)
        }
      }
    }
  }
