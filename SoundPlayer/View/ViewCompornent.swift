//
//  ViewCompornent.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/01/20.
//

import SwiftUI

/// Repeateボタン
struct RepeatButton: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    
    Button(action: {
      if let _currentGroup = self.viewModel.currentGroup {
        // アイコンをクリックした時のアクション
        switch _currentGroup.repeatMode {
        case .noRepeate:
          _currentGroup.repeatMode = .repeateAll
          break
        case .repeateOne:
          _currentGroup.repeatMode = .noRepeate
          break
        case .repeateAll:
          _currentGroup.repeatMode = .repeateOne
          break
        }
      }
      // 再描画
      self.viewModel.redraw()
    })
    {
      if let _currentGroup = self.viewModel.currentGroup {
        switch _currentGroup.repeatMode {
        case .noRepeate:
          Image(systemName: "repeat")
            .foregroundColor(.gray)
            .imageScale(.large)
        case .repeateOne:
          Image(systemName: "repeat.1")
            .imageScale(.large)
        case .repeateAll:
          Image(systemName: "repeat")
            .imageScale(.large)
        }
      }
    }
    .padding()
  }
}

/// 詳細入力ボタン
struct SoundDetailButton: View {
  @EnvironmentObject var viewModel: ViewModel
  var action: () -> Void

  var body: some View {
    Button("#"){
      self.action()
      // 再描画
      viewModel.redraw()
    }
  }
}

/// Playボタン
struct PlayButton: View {
  @EnvironmentObject var viewModel: ViewModel
  var action: () -> Void

  var body: some View {
    Button(action: {
      self.action()
      // 再描画
      viewModel.redraw()
    })
    {
      // 表示を切り替える
       if self.viewModel.playMode == .play {
           Image(systemName: "pause")
               .imageScale(.large)
       } else {
           Image(systemName: "play")
               .imageScale(.large)
       }
    }
    .padding()
  }
}

enum ResultSaveView: String, Codable{
  case cancel
  case ok
  case remove
}

///
///
///  タイトル、時間の入力View
///
///
class TitleTimeModel {
  var title = ""
  var titles = [String]()
  var hours = 0
  var minutes = 0
  var seconds = 0
  var strHours: String {
    get{
      return String(format: "%02d", self.hours)
    }
    set(val){
      self.hours = Int(val) ?? 0
    }
  }
  var strMinutes: String {
    get{
      return String(format: "%02d", self.minutes)
    }
    set(val){
      self.minutes = Int(val) ?? 0
    }
  }
  var strSeconds: String {
    get{
      return String(format: "%02d", self.seconds)
    }
    set(val){
      self.seconds = Int(val) ?? 0
    }
  }

  init(title: String, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
    self.title = title
    self.hours = hours
    self.strHours = String(format: "%02d", hours)
    self.minutes = minutes
    self.strMinutes = String(format: "%02d", minutes)
    self.seconds = seconds
    self.strSeconds = String(format: "%02d", seconds)
  }
}

struct TitleInput: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var title: String
  @Binding var result: ResultSaveView
  
  @Environment(\.dismiss) var dismiss
  @State var showingAlert = false
  
  @State var inputTitle = ""
  var body: some View {
    HStack {
      Button("Cancel"){
        dismiss()
      }
      Spacer()
      Button("OK"){
        self.result = .ok
        dismiss()
      }
      .disabled(self.inputTitle.count <= 0)
      Spacer()
      Button(action: {}, label: {Image(systemName: "trash")})
      .foregroundColor(.red)
      .alert(isPresented: $showingAlert) {
          Alert(
            title: Text("Remove"),
              message: Text("削除しますか？"),
              primaryButton: .default(Text("OK"), action: {
                self.result = .remove
              }),
              secondaryButton: .cancel(Text("Cancel"), action: {
              })
          )
      }
    }
    .padding([.leading, .trailing], 20 )

    Form{
      Section(header: Text("タイトル")) {
        Picker("", selection: $title) {
          ForEach(self.viewModel.playListInfos){ item in
            Text(item.text).tag(item.text)
          }
        }
        .onChange(of: title) { item in
          inputTitle = item
        }
        
        TextField("Title", text: $inputTitle)
      }
    }
  }
}

struct TitleTimeInput: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var model: TitleTimeModel
  @Binding var result: ResultSaveView
  @State var title = ""
  var soundInfo: SoundInfo
  
  @Environment(\.dismiss) var dismiss
  @State var showingAlert = false
  
  @State var selectedTitle = ""
  @State var inputTitle = ""

  var body: some View {
    HStack{
      Button("Cancel"){
        
        dismiss()
      }
      Spacer()
      Button("OK"){
        self.result = .ok
        self.model.title = self.inputTitle
        dismiss()
      }
      .disabled(self.inputTitle.count <= 0)
/*
      Spacer()
      Button("Remove"){
      }
      .foregroundColor(.red)
      .alert(isPresented: $showingAlert) {
          Alert(
              title: Text("Remode"),
              message: Text("削除しますか？"),
              primaryButton: .default(Text("OK"), action: {
                self.result = .remove
              }),
              secondaryButton: .cancel(Text("Cancel"), action: {
              })
          )
      }
      */
    }
    .padding([.leading, .trailing], 20 )

    Form{
      Section(header: Text("タイトル")) {
        Picker("タイトル", selection: self.$selectedTitle) {
          ForEach(self.viewModel.playListInfos){ item in
            Text(item.text).tag(item.text)
          }
        }
        .onChange(of: self.selectedTitle) { item in
          self.inputTitle = item
        }

        TextField("Title", text: self.$inputTitle)

      }

      Section(header: Text("時")) {
        Stepper(value: $model.hours, in: 0...4, step: 1, onEditingChanged: {
          editing in
          if( editing == false ){
            model.strHours = String(model.hours)
          }
        })
        {
          TextField("", text: $model.strHours)
        }
      }
      Section(header: Text("分")) {
        Stepper(value: $model.minutes, in: 0...59, step: 1, onEditingChanged: {
          editing in
          if( editing == false ){
            model.strMinutes = String(model.minutes)
          }
        })
        {
          TextField("", text: $model.strMinutes)
        }
      }
      
      Section(header: Text("秒")) {
        Stepper(value: $model.seconds, in: 0...59, step: 1, onEditingChanged: {
          editing in
          if( editing == false ){
            model.strSeconds = String(model.seconds)
          }
        })
        {
          TextField("", text: $model.strSeconds)
        }
      }
    }
  }
}

/// 再生位置Slider
struct PositionSlider: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var sliderVal: TimeInterval
  
  var body: some View {
    VStack {
      HStack {
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.getCurrentTime()))").font(.footnote)
        Spacer()
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.getPlayTime()))").font(.footnote)
      }
      HStack {
        Button(action: {viewModel.adjustPlayPosition(seconds: -10)}, label: {Image(systemName: "goforward.10")})
        Slider(value:$sliderVal, in: 0.0...Double(viewModel.getPlayTime()) + 1, step: 0.01)
        {
          
        }onEditingChanged: { isEditing in
          viewModel.setPlayPosition(time: sliderVal)
        }
        /*
         .onChange(of: sliderVal) { newValue in
         vm.setPlayPosition(time: sliderVal)
         */
      }
      Button(action: {viewModel.adjustPlayPosition(seconds: 10)}, label: {Image(systemName: "gobackward.10")})
    }
    .padding([.leading, .trailing], 20)
  }
}

/// ボリュームSlider
struct VolumeSlider: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var sliderVal: Float
  
  var body: some View {
    HStack {
      Text("Vol").font(.footnote)
      Slider(value: $viewModel.volome, in: 0...1.0, step: 0.1)
//      Slider(value:$sliderVal, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          viewModel.volome = Float(sliderVal)
          print("newValue:\(newValue)")
          print("sliderVal:\(sliderVal)")
        }
        .font(.footnote)
    }
  }
}

struct Fotter: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var isShowSheet = false
  
  var body: some View {
    HStack {
      Text("\(viewModel.currentFileName)")
        .font(.footnote)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)

      PlayButton(action: {
        if let _currentGroup = self.viewModel.currentGroup {
          try? viewModel.playGroup(groupInfo: _currentGroup)
        }
      })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
    }
    .onTapGesture {
      // Play Sheet表示
      self.isShowSheet = true
    }
    .sheet(isPresented: $isShowSheet, onDismiss: {
      self.isShowSheet = false
    }) {
      PlayView()
    }
    .frame(height: 40)
    .background(
      // 背景に透明なViewを追加して、それをタップしたときにシートが表示されるようにする
      Color.gray
        .contentShape(Rectangle())
        .onTapGesture {
          // Play Sheet表示
          self.isShowSheet = true
        }
    )
  }
}

struct PlayView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State var volume: Float = 0
  
  var body: some View {
    HStack {
      Button("Close"){
        dismiss()
      }
      Spacer()
    }
    VStack {
      // 再生位置
      PositionSlider(sliderVal: $viewModel.currentTime)
      Spacer()
      // ボリューム
      VolumeSlider(sliderVal: $volume)
      
      Button("test") {
        viewModel.volome = 0.5
        viewModel.redraw()
      }
      
    }
    .padding(.top, 50)
    .padding([.leading, .trailing], 30)
    Spacer()
  }
}

struct SoundFileMenu: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State private var titleTime: TitleTimeModel = TitleTimeModel(title: "")
  @State private var saveViewResult: ResultSaveView = .cancel
  @State private var isPresented:Bool = false
  var soundInfo: SoundInfo

  var body: some View {
    VStack {
      List {
        Section {
          HStack {
            Image(systemName: "note.text.badge.plus")
            Text("プレイリストへ追加")
              .onTapGesture {
                let (hours, minutes, seconds) = utility.getHMS(time: viewModel.getCurrentTime())
                self.titleTime.hours = hours
                self.titleTime.minutes = minutes
                self.titleTime.seconds = seconds
                self.titleTime.titles = viewModel.playListInfos.map{ $0.text }
                self.isPresented.toggle()
              }
          .sheet(isPresented: $isPresented, onDismiss: {
            if self.saveViewResult == .ok {
              do {
                // 追加するSoundInfoの作成
                let addSoundInfo = self.soundInfo.copy()
                addSoundInfo.currentTimeStr = "\(self.titleTime.strHours):\(self.titleTime.strMinutes):\(self.titleTime.strSeconds)"

                // PlayList作成
                var playList = viewModel.playListInfos.first(where: {$0.text == self.titleTime.title})
                if playList == nil {
                  playList = PlayListInfo(text: self.titleTime.title)
                  viewModel.playListInfos.append(playList!)
                }
                playList?.soundInfos.append(addSoundInfo)
                
                try utility.savePlayListInfo(outputInfos: viewModel.playListInfos)
              } catch {
                print(error.localizedDescription)
              }
            }
          })
          {
            TitleTimeInput(model: self.titleTime, result: self.$saveViewResult, soundInfo: self.soundInfo)
          }
          }
          HStack {
            Image(systemName: "trash")
            Text("削除")
              .onTapGesture {
                print("")
              }
          }
        }
      }
      Button("Close"){
        dismiss()
      }
      Spacer()
    }
    .padding(.top, 50)
    .padding([.leading, .trailing], 30)
    Spacer()
  }
}

