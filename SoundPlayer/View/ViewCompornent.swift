//
//  ViewCompornent.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/01/20.
//

import SwiftUI

/// Repeateボタン
struct RepeatButton: View {
//  @ObservedObject var vm: ViewModel
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    
    Button(action: {
      // アイコンをクリックした時のアクション
      switch self.viewModel.currentGroup?.repeatMode {
      case .noRepeate:
        self.viewModel.currentGroup?.repeatMode = .repeateAll
        break
      case .repeateOne:
        self.viewModel.currentGroup?.repeatMode = .noRepeate
        break
      case .repeateAll:
        self.viewModel.currentGroup?.repeatMode = .repeateOne
        break
      case nil:
        print("ViewModelのcurrentGroup未設定")
      }
      // 再描画
      self.viewModel.redraw()
    })
    {
      switch self.viewModel.currentGroup?.repeatMode {
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
      case nil:
        Image(systemName: "repeat")
          .foregroundColor(.gray)
          .imageScale(.large)
      }

    }
    .padding()
  }
}

/// 詳細入力ボタン
struct SoundDetailButton: View {
//  @ObservedObject var vm: ViewModel
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
//  @ObservedObject var vm: ViewModel
  @EnvironmentObject var viewModel: ViewModel
  var action: () -> Void

  var body: some View {
    Button(action: {
      // アイコンをクリックした時のアクション
      switch self.viewModel.playMode {
      case .play:
        self.viewModel.playMode = .pause
        break
      case .pause:
        self.viewModel.playMode = .play
        break
      case .stop:
        break
      }
      self.action()
      // 再描画
      viewModel.redraw()
    })
    {
      // 表示を切り替える
       if self.viewModel.playMode == .play {
           Image(systemName: "play")
//               .foregroundColor(.gray)
               .imageScale(.large)
       } else {
           Image(systemName: "pause")
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
      return String(self.hours)
    }
    set(val){
      self.hours = Int(val) ?? 0
    }
  }
  var strMinutes: String {
    get{
      return String(self.minutes)
    }
    set(val){
      self.minutes = Int(val) ?? 0
    }
  }
  var strSeconds: String {
    get{
      return String(self.seconds)
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
    HStack{
      Button("Cancel"){
        
        dismiss()
      }
      Spacer()
      Button("OK"){
        self.result = .ok
        dismiss()
      }
      Spacer()
      Button("Remove"){
      }
      .foregroundColor(.red)
      .alert(isPresented: $showingAlert) {
          Alert(
              title: Text("Remode"),
              message: Text("削除しますか？"),
              primaryButton: .default(Text("Ok"), action: {
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
          Text("New Item").tag("NewItem")
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
        self.model.title = self.inputTitle
        self.result = .ok
        dismiss()
      }
      Spacer()
      Button("Remove"){
      }
      .foregroundColor(.red)
      .alert(isPresented: $showingAlert) {
          Alert(
              title: Text("Remode"),
              message: Text("削除しますか？"),
              primaryButton: .default(Text("Ok"), action: {
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
        /*
         TextField("", text: $model.title)
         */
        
        Picker("タイトルaaaa", selection: self.$selectedTitle) {
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
      Slider(value:$sliderVal, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          print("onReceive:\(sliderVal)")
          viewModel.setVolume(volume: Float(sliderVal))
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
        try? viewModel.playGroup(targetGroup: viewModel.currentGroup)
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
    VStack {
      Button("Close"){
        dismiss()
      }
      Spacer()

      // 再生位置
      PositionSlider(sliderVal: $viewModel.currentTime)
      Spacer()
      // ボリューム
      VolumeSlider(sliderVal: $volume)
      
    }
    .padding(.top, 50)
    .padding([.leading, .trailing], 30)
    Spacer()
  }
}

