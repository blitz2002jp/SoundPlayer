//
//  SettingModel.swift
//  SoundPlayer
//
//  Created by masazumi oeda on 2024/06/05.
//

import Foundation

class SettingModel: Codable {
  var showArtWork: Bool = true
  var name = "NAME"
  
  init() {
    
  }
  
  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.showArtWork = try container.decode(Bool.self, forKey: .showArtWork)
    self.name = try container.decode(String.self, forKey: .name)
  }
  
}
