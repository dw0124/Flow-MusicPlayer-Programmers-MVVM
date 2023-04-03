//
//  ViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/03.
//

import UIKit
import AVFoundation

var player: AVPlayer?
var playerItem:AVPlayerItem?

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var playerButtonState: UIButton!
    
    var songs = Songs(singer: "", album: "", title: "", duration: 0, image: "", file: "", lyrics: "")
    let formatter = DateComponentsFormatter()
    
    @available(iOS 13.0, *)
    @IBAction func playerButton(_ sender: Any) {
        
        playerButtonState.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playerButtonState.setImage(UIImage(systemName: "pause"), for: .selected)
        
        playerButtonState.isSelected.toggle()
        
        if playerButtonState.state.rawValue == 5 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")
        
        WebService().getData(url: url!) { [weak self] songs in
            self?.songs = songs
            WebService().updatePhoto(with: URL(string: songs.image)!) { image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fileURL = URL(string: songs.file)
        playerItem = AVPlayerItem(url: fileURL!)
        player = AVPlayer(playerItem: playerItem)
        
        // To get overAll duration of the audio
        guard let duration : CMTime = playerItem?.asset.duration else { return }
        let seconds: Double = CMTimeGetSeconds(duration)
        let formattedDuration = formatter.string(from: seconds) ?? "00:00"
        
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = formattedDuration
    }

    
}
