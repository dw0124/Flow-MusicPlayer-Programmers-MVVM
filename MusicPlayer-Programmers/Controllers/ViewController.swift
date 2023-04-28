//
//  snapkitTestViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/22.
//

import UIKit
import AVFoundation
import SnapKit

@available(iOS 13.0, *)
class ViewController: UIViewController {
    
    private var musicPlayerVM: MusicPlayerViewModel = MusicPlayerViewModel(url: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json")
    
    let button = UIButton()
    let slider = UISlider()
    let titleLabel = UILabel()
    let singerLabel = UILabel()
    let lyricLabel = UILabel()
    let currentTimeLabel = UILabel()
    let totalTimeLabel = UILabel()
    let imageView = UIImageView()
    let playButton = UIButton()
    
    var playButtonState = true
    
    @objc func touchButton(_ sender: Any) {
        let lyricsVC = LyricsViewController()
        lyricsVC.lyricsVM = LyricsViewModel(lyricsDic: musicPlayerVM.lyricsDic)
        lyricsVC.musicPlayerVM = self.musicPlayerVM
        self.present(lyricsVC, animated: true)
    }
    
    @objc func touchPlayButton(_ sender: Any) {
        musicPlayerVM.isPlaying.toggle()
        playButton.isSelected.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        slider.addTarget(musicPlayerVM, action: #selector(musicPlayerVM.onSliderValueChanged(_:)), for: .touchUpInside)
        
        musicPlayerVM.bindingViewModel = { [weak self] in
            guard let self = self else { return }
            self.setupDI(self.musicPlayerVM.music)
        }
        musicPlayerVM.bindingViewModel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.addPeriodicTimeObserver()
        }
    }
}

@available(iOS 13.0, *)
extension ViewController {
    
    /// 비동기적으로 데이터를 받아왔기 때문에 메인 쓰레드에서 UI 작업을 수행
    func setupDI(_ data: Music) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let formattedDuration = self.musicPlayerVM.formatter.string(from: Double(data.duration)) ?? "00:00"
            //self.albumLabel.text = data.album
            self.titleLabel.text = data.title
            self.singerLabel.text = data.singer
            
            if let imageData = self.musicPlayerVM.imageData {
                self.imageView.image = UIImage(data: imageData)
            }
            self.totalTimeLabel.text = formattedDuration
        }
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
            if self.slider.isTracking == false {
                self.musicPlayerVM.updateSlider()
                self.slider.setValue(self.musicPlayerVM.currentSliderValue, animated: false)
            }
            
            // update Lyric
            self.musicPlayerVM.updateLyric()
            self.lyricLabel.text = self.musicPlayerVM.currentLyric
        }
    }
    
}

extension ViewController {
    func setUI() {
        
        view.backgroundColor = .white
        
        button.setTitle("전체 가사", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(touchButton(_:)), for: .touchUpInside)
        
        titleLabel.text = "title Label"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        singerLabel.text = "singer Label"
        singerLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        lyricLabel.text = ""
        lyricLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        totalTimeLabel.text = "00:00"
        totalTimeLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        imageView.image = UIImage(systemName: "mic.fill")!
        imageView.contentMode = .scaleAspectFill
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playButton.setImage(UIImage(systemName: "pause"), for: .selected)
        playButton.tintColor = .black
        playButton.addTarget(self, action: #selector(touchPlayButton(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(singerLabel)
        view.addSubview(lyricLabel)
        view.addSubview(currentTimeLabel)
        view.addSubview(totalTimeLabel)
        view.addSubview(slider)
        view.addSubview(playButton)
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        singerLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
        }
        
        lyricLabel.snp.makeConstraints { make in
            make.top.equalTo(singerLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(singerLabel.snp.bottom).offset(100)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(slider.snp.leading)
            make.top.equalTo(slider.snp.bottom).offset(10)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(slider.snp.trailing)
            make.top.equalTo(slider.snp.bottom).offset(10)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
