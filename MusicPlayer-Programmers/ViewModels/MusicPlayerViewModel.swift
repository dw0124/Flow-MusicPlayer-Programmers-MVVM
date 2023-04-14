//
//  MusicPlayerViewModel.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/11.
//

import Foundation
import AVFoundation
import UIKit

class MusicPlayerViewModel {
    
    var music: Music!
    
    var formatter = DateComponentsFormatter()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var imageData: Data?
    
    var lyricsDic = [String: String]()
    var currentLyric: String = ""
    var currentSliderValue: Float = 0
    
    // MARK: Computed properties
    var album: String {
        return music.album
    }
    
    var title: String {
        return music.title
    }
    
    var singer: String {
        return music.singer
    }
    
    var musicFileUrl: String {
        return music.file
    }
    
    var lyrics: String {
        return music.lyrics
    }
    
    var duration: Int {
        return music.duration
    }
    
    var isPlaying: Bool = false {
        didSet {
            isPlaying == true ? player?.play() : player?.pause()
        }
    }
    
    
    // MARK: - Init
    init(url: String) {
        getSong(url: url)
        
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
    }
    
    func getSong(url: String) {
        if let url = URL(string: url) {
            WebService().getData(url: url) { [weak self] (music: Music) in
                guard let self = self else { return }
                self.music = music
                // Image
                if let imageUrl = URL(string: self.music.image) {
                    WebService().updatePhoto(with: imageUrl) { (data) in
                        self.imageData = data
                    }
                }
                // MusicFile
                if let fileURL = URL(string: music.file) {
                    self.playerItem = AVPlayerItem(url: fileURL)
                    self.player = AVPlayer(playerItem: self.playerItem)
                }
                // Lyric
                self.getLyric()
            }
        }
    }
    
    func getLyric() {
        // 노래 가사
        music.lyrics.split(separator: "\n").forEach {
            let parts = $0.dropFirst().split(separator: "]").map { String($0) }
            let time = String(parts[0].prefix(5))
            let lyric = parts[1]
            self.lyricsDic[time] = lyric
        }
    }

    // MARK: - update Method
    func updateSlider() {
        var value: Float = 0
        
        if let currentTime = player?.currentTime(), let duration = playerItem?.duration {
            let currentTimeSeconds = CMTimeGetSeconds(currentTime)
            let durationSeconds = CMTimeGetSeconds(duration)
            value = Float(currentTimeSeconds / durationSeconds)
            
        }
        
        currentSliderValue = value
    }
    
    func updateLyric() {
        guard let currentItem = self.player?.currentItem else { return }
        let currentTime = currentItem.currentTime().seconds
        let formattedTime = self.formatter.string(from: currentTime) ?? "00:00"
        
        if lyricsDic[formattedTime] != nil {
            currentLyric = lyricsDic[formattedTime]!
        }
    }
    
    @objc func onSliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        guard let duration = self.playerItem?.duration else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: durationSeconds * Double(value), preferredTimescale: 1000)
        
        // 현재 재생 시간을 지정한 시간으로 변경 AVPlayerItem.seek(to:)
        self.player?.seek(to: seekTime)
    }
}
