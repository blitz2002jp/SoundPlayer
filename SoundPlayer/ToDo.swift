//
//  ToDo.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/04.
//

import Foundation

#warning("起動直後にPlayViewを表示したときの再生時間が正しいか？　すべて０になってる？")
#warning("GroupInfoのTextとして表示するDocumentの表示方法を整理する")
#warning("Exceptionの保存を確認（エラーになる）")
#warning("chtchで表示するprintを工夫してメソッド名などの表示も行えるようにする")
#warning("FolderListから表示した音声リストの再生アイコンが再生していない曲に表示される")
#warning("次に再生が再生されるー＞FooterのPauseボタンを押すと停止しないで頭から再生される")
#warning("検索処理を非同期に")

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
