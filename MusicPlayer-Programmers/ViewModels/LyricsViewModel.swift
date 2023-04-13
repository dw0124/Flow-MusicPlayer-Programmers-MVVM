//
//  LyricsViewModel.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/11.
//

import Foundation

// Lyric들을 받아와서 테이블 뷰에 전달?
struct LyricsViewModel {
    var Lyrics: [String]
}

extension LyricsViewModel {
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return self.Lyrics.count
    }
    
    func LyricAtIndex(_ index: Int) -> LyricViewModel {
        let Lyric = self.Lyrics[index]
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
