import SwiftUI

struct CreateTestDataView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var showingCreateDataAlert = false
  @State private var showingSaveAlert = false
  @Environment(\.dismiss) var dismiss
  @State private var dataClearAlert: Bool = false
  
  @State private var val1: Bool = false
  @State private var val2: SettingModel?
  @State private var val3: Bool = false
  
  @State private var showSheet = false
  
  private let PL_FILE_BAME = "PLAY_LIST.json"
  
  var body: some View {
    List {
      VStack {
        TitleView(title: "テスト", subTitle: "", menuContent: nil)
        Button("Show Debug Log") {
          self.showSheet.toggle()
        }
        .sheet(isPresented: self.$showSheet) {
          DebugLogView()
        }
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
        Text("Setting Info : \(utility.getSettingInfo().showArtWork)")
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
        
        HStack {
          Spacer()
          
          Button("backupDB") {
            self.outputFile(key: "FULL_SOUND_INFO")
            self.outputFile(key: "FOLDER_INFO")
            self.outputFile(key: "PLAY_LIST_INFO")
          }
          
          Spacer()
          
          Button("Store DB") {
            self.StoreDB(jsonString: self.readFile(saveFileName: "FULL_SOUND_INFO"), key: "FULL_SOUND_INFO")
            self.StoreDB(jsonString: self.readFile(saveFileName: "FOLDER_INFO"), key: "FOLDER_INFO")
            self.StoreDB(jsonString: self.readFile(saveFileName: "PLAY_LIST_INFO"), key: "PLAY_LIST_INFO")
          }
          
          Spacer()
          
          Button("Create PlayList") {
            let jsonString = self.createPlayListFile()
            self.StoreDB(jsonString: jsonString, key: "PLAY_LIST_INFO")
          }
          Spacer()
          
          Button("CheckDB") {
            self.checkDB()
          }
          Spacer()
          
          
          Button("Backup PlayList") {
            self.backupPlayList(backupFileName: "PLAY_LIST2.txt")
          }
          Spacer()
        }
        Spacer()
        
        HStack {
          Spacer()
          Button("TEST") {
            self.val2 = utility.getSettingInfo()
          }
          Spacer()
          if let _val2 = self.val2 {
            Text(String(_val2.showArtWork))
          } else {
            Text("Nil")
          }
          Spacer()
        }
        
        Spacer()
        
        HStack {
          Spacer()
          Button("TTTTTT") {
            let res1 = utility.getSettingInfo()
            res1.showArtWork = true
            utility.saveSettingInfo(outputInfo: res1)
            let res2 = utility.getSettingInfo()
            self.val1 = res2.showArtWork
          }
          Spacer()
          Text(String(self.val1))
          Spacer()
          Button("FFFFFF") {
            let res1 = utility.getSettingInfo()
            res1.showArtWork = false
            utility.saveSettingInfo(outputInfo: res1)
            let res2 = utility.getSettingInfo()
            self.val1 = res2.showArtWork
          }
          Spacer()
        }
        .onAppear() {
          let res1 = utility.getSettingInfo()
          self.val1 = res1.showArtWork
        }
        
        Spacer()
        
        HStack {
          Spacer()
          Button("TEST") {
            self.val3 = utility.getSettingInfo2()
          }
          Spacer()
          Text(String(self.val3))
          Spacer()
        }
        
        Spacer()
        
        
        HStack {
          Spacer()
          Button("Id Dump") {
            print("----------- Full Sound --------------")
            self.printId(groupInfos: self.viewModel.fullSoundInfos)
            print("----------- Folder --------------")
            self.printId(groupInfos: self.viewModel.folderInfos)
            print("----------- Play List --------------")
            self.printId(groupInfos: self.viewModel.playListInfos)
          }
          
          Spacer()
          
          Button("Generic Dump") {
            self.decodeTest()
          }
          
          Spacer()
          
          Button("SetSpumdInfoPID") {
            self.setSoundInfoParentId(groupInfos: viewModel.playListInfos)
          }
        }
        
        Button("Get Directory") {
          let _ = utility.getFolders()
        }
      }
    }
  }
  
  private func printId(groupInfos: [GroupInfo]) {
    groupInfos.forEach { item1 in
      print("id : \(item1.id)")
      item1.soundInfos.forEach { item2 in
        print("pID : \(item2.parentId)")
      }
    }
  }
  
  private func outputFile(key: String) {
    if let data = UserDefaults.standard.string(forKey: key) {
      if let fileUrl = utility.getDocumentPath(fileName: "BACKUP/\(key).json") {
        do {
          try data.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
          utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
        }
      }
    }
  }
  
  private func createPlayListFile() -> String {
    var a = [PlayListInfo]()
    let b = PlayListInfo()
    b.text = "PLATLIST_NAMExxxxx"
    let c = SoundInfo(parentId: b.id)
    c.fileName = "aappoo.mp3"
    b.soundInfos.append(c)
    a.append(b)
    
    do {
      let jsonData = try JSONEncoder().encode(a)
      
      // JSONデータをStringに変換
      if let _jsonString = String(data: jsonData, encoding: .utf8) {
        return _jsonString
      }
    } catch {
      utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
    }
    
    return ""
  }
  
  private func checkDB() {
    let keys = ["FULL_SOUND_INFO", "FOLDER_INFO", "PLAY_LIST_INFO"]
    
    keys.forEach { key in
      if let _jsonString = UserDefaults.standard.string(forKey: key) {
        do {
          _ = try self.decodeGroupInfo(jsonString: _jsonString)
          print("\(key):OK")
        } catch {
          utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
        }
      }
    }
  }
  
  private func decodeGroupInfo(jsonString: String) throws -> [GroupInfo]? {
    // String型データをData型に変換
    if let jsonData = jsonString.data(using: .utf8) {
      // デコード
      return try JSONDecoder().decode([GroupInfo].self, from: jsonData)
    }
    
    return nil
  }
  
  private func readFile(saveFileName: String) -> String {
    if let fileUrl = utility.getDocumentPath(fileName: "BACKUP/\(saveFileName).json") {
      do {
        let jsonString = try String(contentsOf: fileUrl)
        return jsonString
      } catch {
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
      }
    }
    
    return ""
  }
  
  private func StoreDB(jsonString: String, key: String) {
    // DBに書き込み
    print("\(key):\(jsonString)")
    UserDefaults.standard.setValue(jsonString, forKey: key)
  }
  
  private func backupPlayList(backupFileName: String) {
    // UserDefaultsから保存データ取得
    if let jsonString = UserDefaults.standard.string(forKey: "PLAY_LIST_INFO") {
      
      if let fileUrl = utility.getDocumentPath(fileName: backupFileName) {
        // ファイルに書き込み
        do {
          try jsonString.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch {
          utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
        }
      }
    }
  }
  
  private func setSoundInfoParentId(groupInfos: [GroupInfo]) {
    groupInfos.forEach { item1 in
      item1.soundInfos.forEach { item2 in
        item2.parentId = item1.id
      }
    }
    
    utility.saveGroupInfo(outputInfos: groupInfos)
  }
  
  
  private func decodeTest() {
    if let res1: [FullSoundInfo]? =  utility.getJsonData(key: "FULL_SOUND_INFO") {
      print("")
    }
    if let res2: [FolderInfo]? =  utility.getJsonData(key: "FOLDER_INFO") {
      print("")
    }
    if let res2: [PlayListInfo]? =  utility.getJsonData(key: "PLAY_LIST_INFO") {
      print("")
    }
    
    let res3: TimeInterval = utility.getPlayingSoundDuration()
    print("")
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
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
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
        utility.exceptionMessage(className: String(describing: type(of: self)), functionName: #function, err: error)
      }
    }
  }
