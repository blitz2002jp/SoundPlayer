//
//  CustomDefine.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/05/01.
//

import SwiftUI

#warning("Coustoフォントを使用するか？")
extension Font {
    static func defaultFont(size: CGFloat) -> Font {
      return Font.custom("Rockwell", size: size)
    }
}
