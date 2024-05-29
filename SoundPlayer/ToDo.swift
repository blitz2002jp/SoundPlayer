//
//  ToDo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/04.
//

import Foundation

#warning("検索結果一覧がスクロールしない")
#warning("ランダムに配列取得は「randomElement」でできる")

#warning("Remove Sound 、　Rename Sound、Rename Group")

/*
 Group Remove
  PlayList
    参照しているPlayListのFolderName変更
  Folder
    実際のフォルダ、配下のファイルすべて削除
    削除されだフォルダ配下のファイルを参照しているPlayList内のSoundの参照を削除
 
 Sound Remove
   PlayList
    参照のみ削除
 
   Folder
    実際のファイルを削除
    参照しているPlayList内のSoundを削除
 

 Group Name Rename
  PlayList
    変更したPlaylistName変更
 
  Folder
    実際のFolderName変更
    参照しているPlayListのFolderName変更
 
 Sound Name 変更
  PlayList
   実際のファイル名変更
   参照しているPlaylistのFileName変更

  Folder
    実際のファイル名変更
    参照しているPlaylistのFileName変更
 
 
 */




#warning("一通りテストしてみる")
#warning("プレイリスト追加処理で再生開始時間の設定は未完成？　リリースを優先たので手つかず")
#warning("ランダムFlagの保存、ViewModelでGroupInfoの作成時にフラグを付ける処理を追加する（SelectedFlagと同様に)")

#warning("Pickerの時分秒に指定する値の上限値を決める")
#warning("リリース準備")
#warning("UserDefaultに保存しているデータをまとめる（資料作成）")
#warning("TitleViewに右のアイコンを表示しない場合(.none)文字がズレる")


/*
 RepeatMode(Get):repeateOne
 RepeatMode(Get(Next)):noRepeate
 RepeatMode(Save):noRepeate
 
 RepeatMode(Get):noRepeate
 RepeatMode(Get(Next)):repeateAll
 RepeatMode(Save):repeateAll
 
 RepeatMode(Get):repeateAll
 RepeatMode(Get(Next)):repeateOne
 RepeatMode(Save):repeateOne
 */
