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
    
    /// 네트워크 파싱 후 View로 완료했다는 것을 전달하기 위한 클로저
    var bindingViewModel: (() -> ()) = {}
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var music: Music = Music(singer: "가수", album: "앨범", title: "제목", duration: 0, image: "", file: "", lyrics: "")
    
    var formatter = DateComponentsFormatter()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var imageData: Data?
    
    var lyricsDic = [String: String]()
    var currentLyric: String = ""
    var currentSliderValue: Float = 0
    var sortedLyrics = [Dictionary<String, String>.Element]()
    var lyricIndex = 0
    
    // MARK: Computed properties
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
        
        guard let url = URL(string: url) else { return }
        
        self.semaphore.wait()
        WebService().getData(url: url) { [weak self] (music: Music) in
            guard let self = self else { return }
            self.music = music
            self.semaphore.signal()
        }
        
        // Image
        self.semaphore.wait()
        if let imageUrl = URL(string: self.music.image) {
            WebService().updatePhoto(with: imageUrl) { (data) in
                self.imageData = data
                self.semaphore.signal()
            }
        }
        
        // MusicFile
        self.semaphore.wait()
        if let fileURL = URL(string: self.music.file) {
            self.playerItem = AVPlayerItem(url: fileURL)
            self.player = AVPlayer(playerItem: self.playerItem)
            self.semaphore.signal()
        }
        
        // Lyric
        self.semaphore.wait()
        self.getLyric()
        self.semaphore.signal()
    }

    
    // 노래 가사
    func getLyric() {
        music.lyrics.split(separator: "\n").forEach {
            let parts = $0.dropFirst().split(separator: "]").map { String($0) }
            let time = String(parts[0].prefix(5))
            let lyric = parts[1]
            self.lyricsDic[time] = lyric
            sortedLyrics = lyricsDic.sorted(by: { $0.key < $1.key})
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
        
        for (index,lyric) in sortedLyrics.enumerated() {
            if lyric.key == formattedTime {
                currentLyric = lyric.value
                lyricIndex = index
                break
            }
        }
    }
    
    // 현재 노래의 재생 시간이 변경될 때마다 Notification을 실행
    func updateCurrentTime(time: String) {
        NotificationCenter.default.post(name: Notification.Name("UpdateCurrentTimeNotification"), object: nil, userInfo: ["currentTime": time])
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
