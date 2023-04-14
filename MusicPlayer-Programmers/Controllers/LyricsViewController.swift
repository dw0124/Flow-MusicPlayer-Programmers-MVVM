//
//  LyricsViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit
import Foundation
import AVFoundation

class LyricsViewController: UIViewController {
    
    var lyricsVM: LyricsViewModel?
    var musicPlayerVM: MusicPlayerViewModel?
    
    var lyricsDic = [String: String]()
    var sortedLyrics = [String]()
    
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var lyricsSwitch: UISwitch!
    
    @IBAction func lyricsViewDismissButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func lyricSwitchValueChanged(_ sender: Any) {
        Singletone.shared.switchState.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        if let lyricsVM = lyricsVM {
            lyricsDic = lyricsVM.lyricsDic
            sortedLyrics = lyricsVM.sortedLyrics
        }
        
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
            guard let selectedTime = lyricsVM?.lyricsDic.sorted(by: { $0.key < $1.key })[indexPath.row].key else { return }
            updateTime(selectedTime: selectedTime)
        }
    }
}

// MARK: - TableViewDataSource
extension LyricsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricsVM?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "lyricCell") as? LyricTableViewCell else  { return UITableViewCell() }
        
        cell.lyricLabel.text = lyricsVM?.sortedLyrics[indexPath.row]
        
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
    }
    
    func highlightLyrics(for currentTime: String) {
        for (index,lyric) in lyricsDic.sorted(by: { $0.key < $1.key}).enumerated() {
            if currentTime == lyric.key {
                lyricsVM?.highlitedLyricIndex = index
                break
            }
        }
        
        if let cell = lyricsTableView.cellForRow(at: IndexPath(row: lyricsVM?.highlitedLyricIndex ?? 0, section: 0)) as? LyricTableViewCell {
            cell.lyricLabel.textColor = .red
        }
        
        // 나머지 셀들을 검정색으로 변경
        for (index,_) in sortedLyrics.enumerated() {
            if index != lyricsVM?.highlitedLyricIndex {
                if let cell = lyricsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? LyricTableViewCell {
                    cell.lyricLabel.textColor = .black
                }
            }
        }
    }
    
    @objc func handleNotification(notification: Notification) {
        // Notification에 포함된 userInfo에서 시간 정보를 가져와서 뷰를 업데이트
        if let currentTime = notification.userInfo?["currentTime"] as? String {
            highlightLyrics(for: currentTime)
        }
    }
}
