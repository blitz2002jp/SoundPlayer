//
//  ViewCompornent.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/01/20.
//

import Foundation
import SwiftUI

/// Repeateボタン
struct RepeatButton: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    
    Button(action: {
      if let _playingGroup = self.viewModel.playingGroup {
        // アイコンをクリックした時のアクション
        switch _playingGroup.repeatMode {
        case .noRepeate:
          _playingGroup.repeatMode = .repeateAll
          break
        case .repeateOne:
          _playingGroup.repeatMode = .noRepeate
          break
        case .repeateAll:
          _playingGroup.repeatMode = .repeateOne
          break
        }
      }
      // 再描画
      self.viewModel.redraw()
    })
    {
      if let _playingGroup = self.viewModel.playingGroup {
        switch _playingGroup.repeatMode {
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
#if DEBUG
      if let _selectedSound = viewModel.getPlayingSound() {
      }
#endif
      
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
/*
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
 */
    Text("oooo")
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
  
  @State private var selectedValues = [0, 0]
  let values1 = [0,1,2,3,4,5,6,7,8,9]
  let values2 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
  
  var body: some View {
    if let _playingGroup = viewModel.playingGroup {
      if let _playingSound = viewModel.getPlayingSound() {
        VStack {
          TitleView(titleName: _playingSound.fileNameNoExt, groupName: _playingGroup.text, targetSound: _playingSound, showMenuIcon: false)
          
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
          }
          .padding([.leading, .trailing], 20 )
          
          Section(header: Text("プレイリスト名")) {
            
            TextField("Title", text: self.$inputTitle)
            
            Picker("タイトル", selection: self.$selectedTitle) {
              ForEach(self.viewModel.playListInfos){ item in
                Text(item.text).tag(item.text)
              }
            }
            .onChange(of: self.selectedTitle) { item in
              self.inputTitle = item
            }
            .pickerStyle(WheelPickerStyle())
          }

          
          if utility.isPrivateMode() {
#warning("Pickerの時分秒に指定する値の上限値を決める")
            // Duration取得
            let (hours, minutes, seconds) = utility.getHMS(time: _playingSound.duration())
            Section(header: Text("再生開始時間")) {
              HStack {
                Picker(selection: $selectedValues[0], label: Text("")) {
                  ForEach(0..<hours, id: \.self) { index in
                    Text("\(index)")
                  }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
                Text(":")
                
                Picker(selection: $selectedValues[1], label: Text("")) {
                  ForEach(0..<60) { index in
                    Text("\(index)")
                  }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
                Text(":")
                
                Picker(selection: $selectedValues[1], label: Text("")) {
                  ForEach(0..<60) { index in
                    Text("\(index)")
                  }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 70, height: 100) // ピッカーの高さを指定
              }
            }
          }
          /*
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
           */
          //    }
        }
      }
    }
  }
}

/// ボリュームSlider
struct VolumeSlider: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var sliderVal: Float
  
  var body: some View {
    HStack {
      Button(action: {
        sliderVal = sliderVal > 0.0 ? sliderVal - 0.05 : 0.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.minus") })
      .foregroundStyle(.primary)

      Slider(value: $viewModel.volome, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          viewModel.volome = Float(sliderVal)
        }
        .onAppear() {
          sliderVal = viewModel.volome
        }
      Button(action: {
        sliderVal = sliderVal < 1.0 ? sliderVal + 0.05 : 1.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.plus") })
      .foregroundStyle(.primary)
    }
  }
  func volumeAdjust() {
    sliderVal = sliderVal > 0.0 ? sliderVal - 0.05 : 0.0
    viewModel.volome = sliderVal
  }
}

struct Fotter: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var isShowSheet = false
  
  var body: some View {
    HStack {
      Button(action: { self.isShowSheet = true })
      {
        Text("\(viewModel.getPlayingSound()?.fileNameNoExt ?? "")")
        .font(.footnote)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .padding(.leading, 10)
      }
      .foregroundStyle(.primary)
/*
      Text("\(viewModel.getPlayingSound()?.fileNameNoExt ?? "")")
        .font(.footnote)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .padding(.leading, 10)
        .onTapGesture {
          // Play Sheet表示
          self.isShowSheet = true
        }
        .foregroundStyle(.primary)
*/
      Spacer()
      Image(systemName: viewModel.playMode == .play ? "pause" : "play.fill")
        .imageScale(.large)
        .padding(.trailing, 10)
        .onTapGesture {
          if let _playingGroup = self.viewModel.playingGroup {
            if let _selectedSound = self.viewModel.getPlayingSound() {
              try? self.viewModel.playSound(targetGroup: _playingGroup, targetSound: _selectedSound)
            }
          }
        }

      Image(systemName: "forward.fill")
        .imageScale(.large)
        .padding(.trailing, 10)
    }
    .sheet(isPresented: $isShowSheet, onDismiss: {
    }) {
      if #available(iOS 16.0, *) {
        PlayView()
          .presentationDetents([.medium])
      } else {
        PlayView()
      }
    }
    .frame(height: 40)
    .background(
      // 背景に透明なViewを追加して、それをタップしたときにシートが表示されるようにする
      Color.gray
        .contentShape(Rectangle())
/*
        .onTapGesture {
          // Play Sheet表示
          self.isShowSheet = true
        }
 */
    )
  }
}

struct TitleView: View {
  var titleName: String = ""
  var groupName: String = ""
  var targetSound: SoundInfo?
  var showMenuIcon = true
  @State private var showMenu = false
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    VStack {
      HStack {
        Image(systemName: "chevron.down")
          .onTapGesture {
            dismiss()
          }
        Spacer() // Imageを右寄せにするためにSpacerを追加
        Text(titleName)
          .font(.title3)
          .frame(maxWidth: .infinity) // Textを水平方向に拡張して中央寄せにする
          .multilineTextAlignment(.center) // 複数行の場合にも中央寄せにする
        if self.showMenuIcon {
          Image(systemName: "ellipsis.circle")
            .onTapGesture {
              self.showMenu = true
            }
            .sheet(isPresented: self.$showMenu)
          {
            if let _targetSound = self.targetSound {
              SoundActionMenu(targetSound: _targetSound)
                .presentationDetents([.medium])
            }
          }
        }
      }
      Text(groupName)
        .font(.footnote)
        .foregroundStyle(Color.gray.opacity(0.5))
      Divider()
    }
    .padding([.top, .leading, .trailing], 10)
  }
}
