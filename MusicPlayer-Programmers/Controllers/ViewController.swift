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
    
    private var musicPlayerVM: MusicPlayerViewModel!
    
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
        
        // 초기화
        musicPlayerVM = MusicPlayerViewModel(url: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUp()
        addPeriodicTimeObserver()
    }
}

@available(iOS 13.0, *)
extension ViewController {
    
    func setUp() {
        // PlayButton
        playerButtonState.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .selected)
        
        // Music UI
        let formattedDuration = musicPlayerVM.formatter.string(from: Double(musicPlayerVM.duration)) ?? "00:00"
        self.albumLabel.text = musicPlayerVM.album
        self.titleLabel.text = musicPlayerVM.title
        self.singerLabel.text = musicPlayerVM.singer
        self.imageView.image = UIImage(data: musicPlayerVM.imageData!)
        self.totalTimeLabel.text = formattedDuration
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
            
            // update Slider
            self.musicPlayerVM.updateSlider()
            self.musicSlider.setValue(self.musicPlayerVM.currentSliderValue, animated: true)
            
            // update Lyric
            self.musicPlayerVM.updateLyric()
            self.lyricLabel.text = self.musicPlayerVM.currentLyric
            
        }
        
    }
}

//@available(iOS 13.0, *)
//extension ViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let destination = segue.destination as? LyricsViewController else {
//            return
//        }
//    }
//}
