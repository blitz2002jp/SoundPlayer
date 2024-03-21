import SwiftUI

struct CreateTestDataView: View {
  @State private var showingAlert = false
  @Environment(\.dismiss) var dismiss

  var body: some View {
    Button("CreateTestData") {
      // 確認ダイアログ表示
      self.showingAlert = true
    }
    .alert(isPresented: $showingAlert) {
      Alert(
        title: Text("テストデータ作成"),
        message: Text("テストデータを作成しますか？"),
        primaryButton: .default(Text("OK")) {
          // テストデータ作成
          CreateTestData().createTestData()
        },
        secondaryButton: .cancel()
      )
    }
    Spacer()
    Button("Close"){
      dismiss()
    }
  }
  
  class CreateTestData {
    func createTestData() {
      if let docFolder = utility.getDocumentDirectory() {
        
        /// Documenフォルダのファイルを全て削除
        self.cleanDocFolder(docUrl: docFolder)
        
        /// コピー(MP3ファイル)
        self.copyMp3Files(docUrl: docFolder)
        
        /// PlayList情報設定(ResourceにあるJsonファイルを実行環境に設定する)
        self.createPlayList()
      }
    }
    
    /// Documenフォルダのファイルを全て削除
    private func cleanDocFolder(docUrl: URL) {
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
    }
    
    /// コピー(MP3ファイル)
    private func copyMp3Files(docUrl: URL) {
      let rootFileNames = ["001", "002", "003", "004"]
      let wedFileNames = ["おまえ本当に大学出たのか", "ここをキャンプ地とする！", "トンネルだトンネルだ", "みっちゃん", "糸ようじ"]
      
      do {
        // コピー(Documentフォルダ直下に置くファイル)
        try self.copyMp3File(files: rootFileNames, to: docUrl)
        
        // Document/Wedenesdayフォルダ作成
        let wedUrl = docUrl.appendingPathComponent("Wedenesday")
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: wedUrl, withIntermediateDirectories: true, attributes: nil)
        
        // コピー(Document/Wedenesdayフォルダ直下に置くファイル)
        try self.copyMp3File(files: wedFileNames, to: wedUrl)
        
      } catch {
        print("copyMp3Filesでエラー:\(error.localizedDescription)")
      }
    }
    
    /// MP3ファイルコピー(ResourceにあるMP3ファイルを実行環境にコピーする)
    private func copyMp3File( files: [String], to: URL) throws {
      let fileManager = FileManager.default
      
      for fileName in files {
        if let path = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
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
        
          if let jsonString = String(data: try Data(contentsOf: path), encoding: .utf8) {
            print("")
          }
          // JsonDataをPlayListInfo配列に変換
          let playListInfo = try JSONDecoder().decode([PlayListInfo].self, from: jsonData)
          
          try utility.savePlayListInfo(outputInfos: playListInfo)
        }
      } catch {
        print("createPlayListでエラー:\(error.localizedDescription)")
      }
    }
  }
}
