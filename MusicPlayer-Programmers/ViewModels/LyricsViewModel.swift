//
//  LyricsViewModel.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/11.
//

import Foundation

class LyricsViewModel {
    var sortedLyrics = [String]()
    var highlitedLyricIndex = 0
    var lyricIndex = 0
    
    init(lyricsDic: [String : String]) {
        self.sortedLyrics = lyricsDic.sorted() { $0.key < $1.key }.map { $0.value }
    }
}

extension LyricsViewModel {
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return self.sortedLyrics.count
    }
    
    func LyricAtIndex(_ index: Int) -> LyricViewModel {
        let Lyric = self.sortedLyrics[index]
        return LyricViewModel(Lyric)
    }
    
}

// Lyric 하나만 받아옴
struct LyricViewModel {
    private let Lyric: String
}

extension LyricViewModel {
    init(_ Lyric: String) {
        self.Lyric = Lyric
    }
}
