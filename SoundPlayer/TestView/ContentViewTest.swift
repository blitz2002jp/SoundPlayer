import SwiftUI

struct ContentViewTest: View {
    @State private var isNextViewActive = false
    
    var body: some View {
        VStack {
            if isNextViewActive {
                NextView(isActive: $isNextViewActive)
            } else {
                Button("次の画面に遷移") {
                    isNextViewActive = true
                }
            }
        }
    }
}

struct NextView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        VStack {
            Text("次の画面")
            Button("戻る") {
                isActive = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewTest()
    }
}

struct CreateTestData: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    Text("")
    /*
    Button("Create PlayList"){
      viewModel.playListInfos = [GroupInfo]()
      viewModel.playListInfos.append(GroupInfo(text: "PlayList 1"))
      viewModel.playListInfos[0].soundInfos = Array(repeating: SoundInfo(), count: 2)
      var idx = Int.random(in: 0...viewModel.soundInfos.count - 1)
      viewModel.playListInfos[0].soundInfos[0] = viewModel.soundInfos[idx].copy()
      viewModel.playListInfos[0].soundInfos[0].startTimeStr = "00:01:56"
      idx = Int.random(in: 0...viewModel.soundInfos.count - 1)
      viewModel.playListInfos[0].soundInfos[1] = viewModel.soundInfos[idx].copy()
      viewModel.playListInfos[0].soundInfos[1].startTimeStr = "00:02:03"

      viewModel.playListInfos.append(GroupInfo(text: "PlayList 1"))
      viewModel.playListInfos[1].soundInfos = Array(repeating: SoundInfo(), count: 2)
      idx = Int.random(in: 0...viewModel.soundInfos.count - 1)
      viewModel.playListInfos[1].soundInfos[0] = viewModel.soundInfos[idx].copy()
      idx = Int.random(in: 0...viewModel.soundInfos.count - 1)
      viewModel.playListInfos[1].soundInfos[1] = viewModel.soundInfos[idx].copy()

      try! utility.writePlayListInfo(url: utility.getSettingFilePathPlayList(), outputInfos: viewModel.playListInfos)
      let _ = utility.getPlayListInfo(url: utility.getSettingFilePathPlayList())
     */
      
/*
      @EnvironmentObject var viewModel: ViewModel

      viewModel.playerLib.playListInfos = [GroupInfo]()
      viewModel.playerLib.playListInfos.append(GroupInfo(text: "PlayList 1"))
      viewModel.playerLib.playListInfos[0].soundInfos = Array(repeating: SoundInfo(), count: 2)
      var idx = Int.random(in: 0...viewModel.playerLib.soundInfos.count - 1)
      viewModel.playerLib.playListInfos[0].soundInfos[0] = viewModel.playerLib.soundInfos[idx].copy()
      idx = Int.random(in: 0...viewModel.playerLib.soundInfos.count - 1)
      viewModel.playerLib.playListInfos[0].soundInfos[1] = viewModel.playerLib.soundInfos[idx].copy()

      viewModel.playerLib.playListInfos.append(GroupInfo(text: "PlayList 2"))
      viewModel.playerLib.playListInfos[1].soundInfos = Array(repeating: SoundInfo(), count: 2)
      idx = Int.random(in: 0...viewModel.playerLib.soundInfos.count - 1)
      viewModel.playerLib.playListInfos[1].soundInfos[0] = viewModel.playerLib.soundInfos[idx].copy()
      idx = Int.random(in: 0...viewModel.playerLib.soundInfos.count - 1)
      viewModel.playerLib.playListInfos[1].soundInfos[1] = viewModel.playerLib.soundInfos[idx].copy()
      
      viewModel.playerLib.writePlayListInfo()
 */
    }
  }

