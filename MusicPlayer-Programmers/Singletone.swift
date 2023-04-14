//
//  Singletone.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/09.
//

import Foundation

class Singletone {
    static let shared = Singletone()
    
    var switchState: Bool = true
    
    private init() { }
}
