//
//  LyricsViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit
import Foundation
import AVFoundation
import SnapKit

class LyricsViewController: UIViewController {
    
    var lyricsVM: LyricsViewModel?
    var musicPlayerVM: MusicPlayerViewModel?
    
    var lyricsDic = [String: String]()
    var sortedLyrics = [String]()
    
    let containerView = UIView()
    let lyricsTableView = UITableView()
    let lyricsSwitch = UISwitch()
    let dismissButton = UIButton()
    
    @objc func lyricsViewDismissButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func lyricSwitchValueChanged(_ sender: UISwitch) {
        Singletone.shared.switchState = sender.isOn
    }

    // MARK: ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        lyricsSwitch.isOn = Singletone.shared.switchState
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("UpdateCurrentTimeNotification"), object: nil)
    }

}

// MARK: - TableViewDelegate
extension LyricsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lyricsSwitch.isOn == false {
            self.dismiss(animated: true)
        }else {
            guard let selectedTime = musicPlayerVM?.sortedLyrics[indexPath.row].key else { return }
            musicPlayerVM?.lyricIndex = indexPath.row
            updateTime(selectedTime: selectedTime)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: LyricTableViewCell.identifier) as! LyricTableViewCell
        return cell.lyricLabel.intrinsicContentSize.height + 16
    }
}

// MARK: - TableViewDataSource
extension LyricsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsVM?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LyricTableViewCell.identifier) as? LyricTableViewCell else { return UITableViewCell() }
        
        cell.lyricLabel.text = lyricsVM?.sortedLyrics[indexPath.row]
        
        if indexPath.row == musicPlayerVM?.lyricIndex {
            cell.lyricLabel.textColor = .red
        }
  
        return cell
    }
}

// MARK: - Method
extension LyricsViewController {
    func updateTime(selectedTime: String) {
        let timeComponents = selectedTime.components(separatedBy: ":")
        let minutes = Int(timeComponents[0]) ?? 0
        let seconds = Int(timeComponents[1]) ?? 0
        
        let timeInSeconds = Double(minutes * 60 + seconds)
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 1)
        
        musicPlayerVM?.player?.seek(to: time)
        self.highlightLyrics(for: selectedTime)
    }
    
    func highlightLyrics(for currentTime: String) {
        if let cell = lyricsTableView.cellForRow(at: IndexPath(row: musicPlayerVM?.lyricIndex ?? 0, section: 0)) as? LyricTableViewCell {
            cell.lyricLabel.textColor = .red
        }
        // 나머지 셀들을 검정색으로 변경
        for index in 0..<(musicPlayerVM?.sortedLyrics.count ?? 0) {
            if index != musicPlayerVM?.lyricIndex {
                if let cell = lyricsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? LyricTableViewCell {
                    cell.lyricLabel.textColor = .black
                }
            }
        }
    }
    
    // Notification에 포함된 userInfo에서 시간 정보를 가져와서 뷰를 업데이트
    @objc func handleNotification(notification: Notification) {
        if let currentTime = notification.userInfo?["currentTime"] as? String {
            highlightLyrics(for: currentTime)
        }
    }
}

// MARK: - SetUI
extension LyricsViewController {
    func setUI() {
        
        view.backgroundColor = .white
        
        lyricsTableView.register(LyricTableViewCell.self, forCellReuseIdentifier: LyricTableViewCell.identifier)
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        view.addSubview(containerView)
        containerView.addSubview(lyricsSwitch)
        containerView.addSubview(dismissButton)
        view.addSubview(lyricsTableView)
       
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.setTitleColor(.black, for: .normal)
        dismissButton.addTarget(self, action: #selector(lyricsViewDismissButton(_:)), for: .touchUpInside)
        
        lyricsSwitch.addTarget(self, action: #selector(lyricSwitchValueChanged(_:)), for: .valueChanged)
        
        containerView.snp.makeConstraints {
          $0.top.leading.trailing.equalToSuperview()
          $0.height.equalTo(50)
        }
        
        lyricsSwitch.snp.makeConstraints {
          $0.centerY.equalToSuperview()
          $0.leading.equalToSuperview().inset(16)
        }
        
        dismissButton.snp.makeConstraints {
          $0.centerY.equalToSuperview()
          $0.trailing.equalToSuperview().inset(16)
        }
        
        lyricsTableView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}
