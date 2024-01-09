//
//  Songs.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/03.
//

import Foundation

struct Music: Codable {
    var singer, album, title: String
    var duration: Int
    var image: String
    var file: String
    var lyrics: String
}

