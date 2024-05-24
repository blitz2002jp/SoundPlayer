import SwiftUI

struct CreateTestDataView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var showingCreateDataAlert = false
  @State private var showingSaveAlert = false
  @Environment(\.dismiss) var dismiss
  @State private var dataClearAlert: Bool = false

  var body: some View {
    Spacer()
    Button("Private Mode解除") {
      utility.removePrivateModeFile()
    }
    Spacer()
    Button("Selected Sound") {
      utility.selectedSoundCheck(viewModel: viewModel)
    }
    Spacer()
    Button("CreateTestData") {
      // 確認ダイアログ表示
      self.showingCreateDataAlert = true
    }
    .alert(isPresented: $showingCreateDataAlert) {
      Alert(
        title: Text("テストデータ作成"),
        message: Text("テストデータを作成しますか？"),
        primaryButton: .default(Text("OK")) {
          // テストデータ作成
          CreateTestData().create()
        },
        secondaryButton: .cancel()
      )
    }
    Spacer()
    Button("Save()") {
      self.showingSaveAlert.toggle()
    }
    .alert(isPresented: $showingSaveAlert) {
      Alert(
        title: Text("データ保存"),
        message: Text("保存しますか？"),
        primaryButton: .default(Text("OK")) {
          viewModel.saveGroupInfos()
        },
        secondaryButton: .cancel()
      )
    }
    Text("アプリの終了検知が呼ばれないので、とりあえずこのボタンでSave")
      .font(.footnote)
    Spacer()
    Button("Saveデータ読み込み") {
#if DEBUG
      utility.DebugPrintSaveData(viewModel: viewModel)
#endif
    }
    Spacer()
    
    Button("データ削除(UserDefaults)") {
      self.dataClearAlert.toggle()
    }
    .alert("削除しますか？", isPresented: self.$dataClearAlert) {
      Button("cancel"){}
      Button("ok"){
        utility.clearData()
      }
    }
    Spacer()
    
    Button("TEST") {
      if let _soundInfo = viewModel.soundInfos.first(where: {$0.fileName == "04_MA TICARICA.m4a"}) {
        utility.saveArtWork(imageData: _soundInfo.artWork, fileName: "artImage.PNG")
      }
    }
    
    Spacer()
    Button("Close"){
      dismiss()
    }
  }
  
  class CreateTestData {
    @StateObject internal var viewModel = ViewModel()

    func create() {
      if let docFolder = utility.getDocumentDirectory() {
        
        // Documenフォルダ内のフォルダとファイルを全て削除
        utility.clearData()

        // コピー(MP3ファイル)
        self.copyMp3Files(docUrl: docFolder)
        
        // PlayList情報設定(ResourceにあるJsonファイルを実行環境に設定する)
        self.createPlayList()
        
        // ViewModelへ作成したテストデータをセット
        self.viewModel.createDataModel()

        // 保存
        self.viewModel.saveGroupInfos()

        // Privateモードファイル作成
        utility.CreatePrivateModeFile()

      }
    }
    
    /// Documenフォルダ内のフォルダとファイルを全て削除
    private func cleanDocFolder(docUrl: URL) {
/*
      do {
        let fileManager = FileManager.default
        
        // フォルダ内のファイルとサブフォルダを取得
        let contents = try fileManager.contentsOfDirectory(atPath: docUrl.path)
        
        // フォルダ内のすべてのファイルとサブフォルダを削除
        for item in contents {
          let itemPath = "\(docUrl.path)/\(item)"
          try fileManager.removeItem(atPath: itemPath)
        }
      } catch {
        print("フォルダの内容を削除できませんでした: \(error.localizedDescription)")
      }
 */
    }
    
    /// コピー(MP3ファイル)
    private func copyMp3Files(docUrl: URL) {
      let rootFileNames = ["S1.mp3", "S2.mp3"]
      let subFolder = ["S3.mp3"]
      
      do {
        // コピー(Documentフォルダ直下に置くファイル)
        try self.copyMp3File(files: rootFileNames, to: docUrl)
        
        // Document/Wedenesdayフォルダ作成
        let wedUrl = docUrl.appendingPathComponent("SubFolder")
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: wedUrl, withIntermediateDirectories: true, attributes: nil)
        
        // コピー(Document/Wedenesdayフォルダ直下に置くファイル)
        try self.copyMp3File(files: subFolder, to: wedUrl)
        
      } catch {
        print("copyMp3Filesでエラー:\(error.localizedDescription)")
      }
    }
    
    /// MP3ファイルコピー(ResourceにあるMP3ファイルを実行環境にコピーする)
    private func copyMp3File( files: [String], to: URL) throws {
      let fileManager = FileManager.default
      
      for fileName in files {
        if let path = Bundle.main.url(forResource: fileName, withExtension: "") {
          let distinationUrl = to.appendingPathComponent(path.lastPathComponent)
          try fileManager.copyItem(at: path, to: distinationUrl)
        }
      }
    }
    
    /// PlayList情報設定(ResourceにあるJsonファイルを実行環境に設定する)
    private func createPlayList() {
      do {
        if let path = Bundle.main.url(forResource: "PlayList", withExtension: "json") {
          // ファイルのデータを読み込む
          let jsonData = try Data(contentsOf: path)
        
          if let _a = String(data: try Data(contentsOf: path), encoding: .utf8) {
            print("\(_a.count)")
          }

          // JsonDataをPlayListInfo配列に変換
          let playListInfo = try JSONDecoder().decode([PlayListInfo].self, from: jsonData)
          
          utility.saveGroupInfo(outputInfos: playListInfo)
        }
      } catch {
        print("createPlayListでエラー:\(error.localizedDescription)")
      }
    }
  }
}


