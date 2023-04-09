//
//  ViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/03.
//

import UIKit
import AVFoundation

@available(iOS 13.0, *)
class ViewController: UIViewController {
    
    var songs = Songs(singer: "", album: "", title: "", duration: 0, image: "", file: "", lyrics: "")
    var lyrics = [String: String]()
    let formatter = DateComponentsFormatter()
    
    var player: AVPlayer?
    var playerItem:AVPlayerItem?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var lyricLabel: UILabel!
    @IBOutlet weak var playerButtonState: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBAction func playerButton(_ sender: Any) {
        let duration : CMTime = (playerItem?.currentTime())!
        let seconds: Double = CMTimeGetSeconds(duration)
        let formattedDuration = formatter.string(from: seconds) ?? "00:00"
        
        currentTimeLabel.text = formattedDuration
        
        playerButtonState.isSelected.toggle()
        
        if playerButtonState.state.rawValue == 5 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // PlayButton
        playerButtonState.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .selected)
        
        // DateComponentsFormatter
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        // model 불러오기
        let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")
        WebService().getData(url: url!) { [weak self] songs in
            self?.songs = songs
            // imageView에 image 넣기
            WebService().updatePhoto(with: URL(string: songs.image)!) { image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
        
        
        
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUp()
        addPeriodicTimeObserver()
        
        musicSlider.addTarget(self, action: #selector(onSliderValueChanged), for: .touchUpInside)
    }
    
}

@available(iOS 13.0, *)
extension ViewController {
    
    // 노래 파일 불러오기, 시간 초기화(totalTimeLabel, currentTimeLabel(00:00))
    private func setUp() {
        let fileURL = URL(string: songs.file)
        playerItem = AVPlayerItem(url: fileURL!)
        player = AVPlayer(playerItem: playerItem)
        
        guard let duration : CMTime = playerItem?.asset.duration else { return }
        let seconds: Double = CMTimeGetSeconds(duration)
        let formattedDuration = formatter.string(from: seconds) ?? "00:00"
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = formattedDuration
        
        albumLabel.text = songs.album
        titleLabel.text = songs.title
        singerLabel.text = songs.singer
        
        // 노래 가사
        songs.lyrics.split(separator: "\n").forEach {
            let parts = $0.dropFirst().split(separator: "]").map { String($0) }
            let time = String(parts[0].prefix(5))
            let lyric = parts[1]
            lyrics[time] = lyric
        }
    }
    
    @objc func onSliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        guard let duration = playerItem?.duration else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: durationSeconds * Double(value), preferredTimescale: 1000)
        
        // 현재 재생 시간을 지정한 시간으로 변경 AVPlayerItem.seek(to:)
        player?.seek(to: seekTime)
    }

    private func updateSlider() {
        guard let currentTime = player?.currentTime(), let duration = playerItem?.duration else {
            return
        }
        let currentTimeSeconds = CMTimeGetSeconds(currentTime)
        let durationSeconds = CMTimeGetSeconds(duration)
        let value = Float(currentTimeSeconds / durationSeconds)
        musicSlider.setValue(value, animated: true)
    }
    
    private func updateLyric() {
        guard let currentItem = self.player?.currentItem else {
            return
        }
        let currentTime = currentItem.currentTime().seconds
        let formattedTime = self.formatter.string(from: currentTime) ?? "00:00"
        
        if lyrics[formattedTime] != nil {
            lyricLabel.text = lyrics[formattedTime]
        }
        
    }
    
    // 1초마다 addPeriodicTimeObserver(forInterval:queue:)를 통해 currentTimeLabel 변경
    private func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let currentItem = self?.player?.currentItem else {
                return
            }
            let currentTime = currentItem.currentTime().seconds
            let formattedTime = self?.formatter.string(from: currentTime) ?? "00:00"
            self?.currentTimeLabel.text = formattedTime
            
            self?.updateSlider()
            self?.updateLyric()
            self?.updateCurrentTime(time: formattedTime)
        }
    }
    
    func updateCurrentTime(time: String) {
        // 현재 노래의 재생 시간이 변경될 때마다 Notification을 실행
        NotificationCenter.default.post(name: Notification.Name("UpdateCurrentTimeNotification"), object: nil, userInfo: ["currentTime": time])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? LyricsViewController else {
            return
        }
        destination.currentTIme = self.currentTimeLabel.text ?? "00:00"
        destination.lyrics = self.lyrics
        destination.delegate = self
    }
}

@available(iOS 13.0, *)
extension ViewController: LyricSelectionDelegate {
    func didSelectLyric(_ time: String) {
        
        let lyricsVC = LyricsViewController()
        lyricsVC.delegate = self
        self.titleLabel.text = time
        
        print(time)

        let timeComponents = time.components(separatedBy: ":")
        let minutes = Int(timeComponents[0]) ?? 0
        let seconds = Int(timeComponents[1]) ?? 0

        let timeInSeconds = Double(minutes * 60 + seconds)
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 1)

        player?.currentItem?.seek(to: time)

    }
}





