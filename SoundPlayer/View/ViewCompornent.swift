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
#if DEBUG
      if let _selectedSound = viewModel.getCurrentSelectedSound() {
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
  //  var soundInfo: SoundInfo
  
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
    }
    .padding([.leading, .trailing], 20 )
    
//    Form {
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
//    }
  }
}

/// 再生位置Slider
struct PositionSlider: View, PlayerDelegateCurrentTime {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var sliderVal: TimeInterval
  @State var duration: TimeInterval
  
  // Playerからの再生時間通知デリゲート
  func notifyCurrentTime(currentTime: TimeInterval) {
    print("** notifyCurrentTime")
    var currentTimeStr: String = utility.timeIntervalToString(timeFormat: .HHMMSS, timeInterval: currentTime)
    self.viewModel.currentTime = currentTime
    
    // 音声情報に現在再生時間をセット
    if let _currentSound = self.viewModel.getCurrentSelectedSound() {
      _currentSound.currentTime = currentTime
    }
    
    // 現在再生時間の保存
    utility.saveCurrentPlayTime(currentTime: currentTimeStr)

  }
  
  var body: some View {
    VStack {
      HStack {
        Slider(value:$sliderVal, in: 0.0...Double(viewModel.currentSoundDuration) + 1, step: 0.01)
        {}onEditingChanged: { isEditing in
          viewModel.setPlayTime(time: sliderVal)
        }
        .padding([.trailing, .leading], 0)
        .onAppear() {
          sliderVal = viewModel.getCurrentTime()
        }
      }
      HStack {
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.getCurrentTime()))")
          .font(.footnote)
          .foregroundStyle(Color.gray.opacity(0.7))
        Spacer()
        Text("\(utility.timeIntervalToString(timeInterval: viewModel.currentSoundDuration))")
          .font(.footnote)
          .foregroundStyle(Color.gray.opacity(0.7))
      }
    }
    .onAppear() {
      // 再生時間通知デリゲート開始
      viewModel.player.delegateCurrentTime = self
    }
    .onDisappear() {
      // 再生時間通知デリゲート終了
      viewModel.player.delegateCurrentTime = nil
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
        sliderVal = sliderVal > 0.0 ? sliderVal - 0.1 : 0.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.minus")})

      Slider(value: $viewModel.volome, in: 0...1.0, step: 0.1)
        .onChange(of: sliderVal) { newValue in
          viewModel.volome = Float(sliderVal)
        }
        .onAppear() {
          sliderVal = viewModel.volome
        }
      Button(action: {
        sliderVal = sliderVal < 1.0 ? sliderVal + 0.1 : 1.0
        viewModel.volome = sliderVal
      }, label: { Image(systemName: "speaker.plus")})
    }
  }
  func volumeAdjust() {
    sliderVal = sliderVal > 0.0 ? sliderVal - 0.1 : 0.0
    viewModel.volome = sliderVal
  }
}

struct Fotter: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var isShowSheet = false
  @State var enableTap: Bool
  
  var body: some View {
    HStack {
      Text("\(viewModel.getCurrentSelectedSound()?.fileNameNoExt ?? "")")
        .font(.footnote)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .padding(.leading, 10)
      Spacer()
      Image(systemName: viewModel.playMode == .play ? "pause" : "play.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 50, height: 50)
        .padding(.trailing, 10)
        .onTapGesture {
          if let _currentGroup = self.viewModel.currentGroup {
            if let _selectedSound = self.viewModel.getCurrentSelectedSound() {
              try? self.viewModel.playSound(targetGroup: _currentGroup, targetSound: _selectedSound)
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
        .onTapGesture {
          // タップジェスチャーが有効なら
          if self.enableTap == true {
            // Play Sheet表示
            self.isShowSheet = true
          }
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
      Spacer()
      Text(viewModel.getCurrentSelectedSound()?.fileNameNoExt ?? "")
        .font(.title3)
      Text(viewModel.currentGroup?.text ?? "")
        .font(.footnote)
        .foregroundStyle(Color.gray.opacity(0.5))
      Divider()
      if let _sound = viewModel.getCurrentSelectedSound() {
        if let _artWork = utility.getArtWorkImage(url: _sound.fullPath) {
          _artWork
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
        }
      }

      Spacer()
      // 再生位置
      PositionSlider(sliderVal: $viewModel.currentTime, duration: viewModel.currentSoundDuration)
      Spacer()

      HStack {
        Image(systemName: "goforward.10")
          .font(.title3)
          .padding(.trailing, 30)
          .onTapGesture {
            viewModel.adjustPlayTime(seconds: 10)
          }

        Image(systemName: "backward.fill")
          .font(.title3)
          .padding(.trailing, 30)
          .onTapGesture {
            viewModel.playPrevSound()
          }

        Image(systemName: viewModel.player.isPlaying ? "pause.fill" :  "play.fill")
          .font(.title3)
          .padding(.trailing, 30)
          .onTapGesture {
            do {
              try viewModel.playSound(targetGroup: viewModel.currentGroup, targetSound: viewModel.getCurrentSelectedSound())
            } catch {
              print(error.localizedDescription)
            }
          }

        Image(systemName: "forward.fill")
          .font(.title3)
          .padding(.trailing, 30)
          .onTapGesture {
            viewModel.playNextSound()
          }
        Image(systemName: "gobackward.10")
          .font(.title3)
          .onTapGesture {
            viewModel.adjustPlayTime(seconds: -10)
          }
      }

      Spacer()
      // ボリューム
      VolumeSlider(sliderVal: $volume)
      
    }
    .onAppear() {
      if let _s = viewModel.getCurrentSelectedSound() {
        print("\(_s.currentTimeStr) : \(_s.currentTime)")
      }
      print()

    }
    .padding([.leading, .trailing], 10)
    
    // フッター
//    Fotter(enableTap: false)
  }
}

struct SoundFileMenu: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.dismiss) var dismiss
  @State private var titleTime: TitleTimeModel = TitleTimeModel(title: "")
  @State private var saveViewResult: ResultSaveView = .cancel
  @State private var isPresented:Bool = false
  //var soundInfo: SoundInfo
  
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
                  if let _currentSound = viewModel.getCurrentSelectedSound() {
                    // 追加するSoundInfoの作成
                    let addSoundInfo = _currentSound.copy()
                    addSoundInfo.currentTime = utility.stringToTimeInterval(HHMMSS: "\(self.titleTime.strHours):\(self.titleTime.strMinutes):\(self.titleTime.strSeconds)")
                    
                    // PlayList作成
                    var playList = viewModel.playListInfos.first(where: {$0.text == self.titleTime.title})
                    if playList == nil {
                      playList = PlayListInfo(text: self.titleTime.title)
                      viewModel.playListInfos.append(playList!)
                    }
                    playList?.soundInfos.append(addSoundInfo)
                    
                    utility.saveGroupInfo(outputInfos: viewModel.playListInfos)
                  }
                }
              })
            {
              if #available(iOS 16.0, *) {
                TitleTimeInput(model: self.titleTime, result: self.$saveViewResult)
                  .presentationDetents([.medium])
              } else {
                TitleTimeInput(model: self.titleTime, result: self.$saveViewResult)
              }
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
/*
      Button("Close"){
        dismiss()
      }
 */
      Spacer()
    }
  }
}

