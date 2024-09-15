//
//  DebugLogView.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/06/25.
//

import SwiftUI

struct DebugLogView: View {
  //  private var debugLogMng = DebugLogManager()
  @State private var debugLogItems = [DebugLogItemModel]()
  
  var body: some View {
    VStack {
      TitleView(title: "Log", subTitle: "", menuContent: nil)
      HStack {
        Spacer()
        Button(action: {
          self.debugLogItems = utility.readDebugLog()
        }
               , label: {Image(systemName: "arrow.counterclockwise")})
        Spacer()
        Button(action: {
          utility.clearDebugLog()
          self.debugLogItems = [DebugLogItemModel]()
        }
               , label: {Image(systemName: "trash")
          .foregroundStyle(.red)})
        Spacer()
      }
      ScrollView {
        ForEach(self.debugLogItems, id: \.id) { item in
          HStack {
            Text(item.dateTimeStr)
            Text(item.debugLog)
            Spacer()
          }
        }
      }
      .onAppear() {
        self.debugLogItems = utility.readDebugLog()
      }
    }
  }
}

#Preview {
  DebugLogView()
}

/// デバッグログModel
class DebugLogItemModel: Codable, Identifiable {
  var dateTime: Date
  var dateTimeStr: String {
    get {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .medium
      // Japanese Locale (ja_JP)
      dateFormatter.locale = Locale(identifier: "ja_JP")
      
      return dateFormatter.string(from: self.dateTime)
    }
  }
  var debugLog: String
  init(dateTime: Date = Date(), debugLog: String) {
    self.dateTime = dateTime
    self.debugLog = debugLog
  }
}
