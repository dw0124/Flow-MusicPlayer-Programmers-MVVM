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
    
    private var musicPlayerVM: MusicPlayerViewModel = MusicPlayerViewModel(url: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")
    
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
        musicPlayerVM.isPlaying.toggle()
        playerButtonState.isSelected.toggle()
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButtonSetUp()
        addPeriodicTimeObserver()
        
        musicSlider.addTarget(musicPlayerVM, action: #selector(musicPlayerVM.onSliderValueChanged(_:)), for: .touchUpInside)
        
        
        musicPlayerVM.bindingViewModel = { [weak self] in
            guard let self = self else { return }
            print("jhkim: \(self.musicPlayerVM.music)")
            self.setupDI(self.musicPlayerVM.music)
        }
        musicPlayerVM.bindingViewModel()
    }
}

@available(iOS 13.0, *)
extension ViewController {
    
    /// 비동기적으로 데이터를 받아왔기 때문에 메인 쓰레드에서 UI 작업을 수행한다.
    func setupDI(_ data: Music) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let formattedDuration = self.musicPlayerVM.formatter.string(from: Double(data.duration)) ?? "00:00"
            self.albumLabel.text = data.album
            self.titleLabel.text = data.title
            self.singerLabel.text = data.singer
            
            if let imageData = self.musicPlayerVM.imageData {
                self.imageView.image = UIImage(data: imageData)
            }
            self.totalTimeLabel.text = formattedDuration
        }
    }
    
    func playButtonSetUp() {
        playerButtonState.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .selected)
    }
    
    // 1초마다 addPeriodicTimeObserver(forInterval:queue:)를 통해 변경
    func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1)
        musicPlayerVM.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let currentItem = self.musicPlayerVM.player?.currentItem else {
                return
            }
            // update CurrentTime
            let currentTime = currentItem.currentTime().seconds
            let formattedTime = self.musicPlayerVM.formatter.string(from: currentTime) ?? "00:00"
            self.currentTimeLabel.text = formattedTime
            self.musicPlayerVM.updateCurrentTime(time: formattedTime)
            
            // update Slider
            self.musicPlayerVM.updateSlider()
            self.musicSlider.setValue(self.musicPlayerVM.currentSliderValue, animated: true)
            
            // update Lyric
            self.musicPlayerVM.updateLyric()
            self.lyricLabel.text = self.musicPlayerVM.currentLyric
        }
    }
    
}

@available(iOS 13.0, *)
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? LyricsViewController else {
            return
        }
        destination.lyricsVM = LyricsViewModel(lyricsDic: musicPlayerVM.lyricsDic)
        destination.musicPlayerVM = self.musicPlayerVM
        //destination.lyricsDic = musicPlayerVM.lyricsDic
    }
}
