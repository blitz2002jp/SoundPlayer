//
//  GroupSelectionView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/12.
//

import SwiftUI

struct GroupSelectionView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State private var selectedFolder: String = " "
  @State private var pickerItems: [String] = []
  @State private var showInputNewNameArert = false
  @State private var showInputNewNameArert15 = false
  @State private var okCancel: OkCancel = .cancel
  @State private var newPlaylistName = ""
  
  /// 操作対象Group Sound
  var targetGroup: GroupInfo?
  var targetSound: SoundInfo?
  
  private var targetGroups: [GroupInfo] {
    get {
      var res = [GroupInfo]()
      if let _targetGroup = targetGroup {
        switch _targetGroup.groupType {
        case .Folder:
          res = viewModel.folderInfos
        case .PlayList:
          res = viewModel.playListInfos
        case .FullSound:
          res = viewModel.fullSoundInfos
        }
      }
      return res
    }
  }
  
  var body: some View {
    if let _targetGroup = targetGroup {
      if let _targetSound = targetSound {
        VStack {
          TitleView(title: _targetSound.fileNameNoExt, subTitle: _targetGroup.text, targetGroup: targetGroup, targetSound: targetSound, trailingItem: .none) {
          }
          NavigationView {
            List {
              Picker("", selection: $selectedFolder) {
                ForEach(pickerItems, id: \.self) { item in
                  let folderName = item == "" ? "Document" : item
                  if self.isSourceFolder(folderName: item) {
                    Text(folderName)
                      .opacity(0.2)
                  } else {
                    Text(folderName)
                  }
                }
              }
              .onChange(of: self.selectedFolder) { newItem in
                if self.isSourceFolder(folderName: newItem) {
                  self.selectedFolder = " "
                }
              }
            }
            .pickerStyle(.inline)
            .onAppear() {
              self.pickerItems = self.targetGroups.map { $0.text }
            }
            .navigationTitle("移動先")
          }
        }
        
        Spacer()
        Button(action: {
          self.moveSoundFile(distinationFolder: self.selectedFolder)
          
          dismiss()
        }, label: {Text("OK")})
        .disabled(!self.isSelected())
      }
    }
  }
  
  private func isSelected() -> Bool {
    if self.selectedFolder == " " {
      return false
    }
    return true
  }
  
  private func isSourceFolder(folderName: String) -> Bool {
    if let _playingGroup = targetGroup {
      if folderName == _playingGroup.text {
        return true
      }
    }
    return false
  }
  
  private func moveSoundFile(distinationFolder: String) {
    if let _targetGroup = self.targetGroup {
      if let _targetSound = self.targetSound {
        // フォルダーの場合
        if _targetGroup.groupType == .Folder {
          if let _at = _targetSound.fullPath {
            if var _to = utility.getDocumentDirectory() {
              _to = _to.appendingPathComponent("\(distinationFolder)/\(_targetSound.fileName)")
              // コピー
              utility.copySoundFile(action: .newFileName, at: _at, to: _to)
              
              // コピー元ファイルの削除
              self.viewModel.removeSound(targetGroup: self.targetGroup, targetSound: _targetSound)
            }
          }
          // PlayListの場合
        } else if _targetGroup.groupType == .PlayList {
          if let _distinationGroup = self.targetGroups.first(where: { $0.text == distinationFolder}) {
            _distinationGroup.soundInfos.append(_targetSound)
            // Sound削除
            self.viewModel.removeSound(targetGroup: _targetGroup, targetSound: _targetSound)
          }
        }
      }
    }
  }
}

