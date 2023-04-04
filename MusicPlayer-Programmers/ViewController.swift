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
    
    var player: AVPlayer?
    var playerItem:AVPlayerItem?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playerButtonState: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    
    var songs = Songs(singer: "", album: "", title: "", duration: 0, image: "", file: "", lyrics: "")
    let formatter = DateComponentsFormatter()
    
    @IBAction func playerButton(_ sender: Any) {
        
        let duration : CMTime = (playerItem?.currentTime())!
        let seconds: Double = CMTimeGetSeconds(duration)
//        let formattedDuration = formatter.string(from: seconds) ?? "00:00"
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
        
        // DateFormatter
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
        
        musicSlider.addTarget(self, action: #selector(onSliderValueChanged), for: .valueChanged)
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
    
    // 1초마다 addPeriodicTimeObserver(forInterval:queue:)를 통해 currentTimeLabel 변경
    private func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let currentItem = self?.player?.currentItem else {
                return
            }
            let currentTime = currentItem.currentTime().seconds
            let formattedDuration = self?.formatter.string(from: currentTime) ?? "00:00"
            self?.currentTimeLabel.text = formattedDuration
            
            self?.updateSlider()
        }
    }
}
