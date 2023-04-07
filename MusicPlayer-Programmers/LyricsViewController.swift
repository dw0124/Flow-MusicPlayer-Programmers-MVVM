//
//  LyricsViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit

protocol LyricSelectionDelegate: AnyObject {
    func didSelectLyric(_ time: String)
}

class LyricsViewController: UIViewController {
    
    @IBOutlet weak var lyricsTableView: UITableView!
    
    var currentTIme: String = "00:00"
    var lyrics = [String: String]()
    var sortedLyrics = [String]()
    var preLyricsIndex: Int?
    var highlitedLyricIndex: Int?
    
    weak var delegate: LyricSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        sortedLyrics = lyrics.sorted() { $0.key < $1.key }.map { $0.value }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: Notification.Name("UpdateCurrentTimeNotification"), object: nil)
        
        
    }

    @objc func handleNotification(notification: Notification) {
        // Notification에 포함된 userInfo에서 시간 정보를 가져와서 뷰를 업데이트
        if let currentTime = notification.userInfo?["currentTime"] as? String {
            self.currentTIme = currentTime
            highlightLyrics(for: currentTime)
        }
    }
}

extension LyricsViewController {
    
    // highlitedIndex는 빨간색으로 변경, currentIndex는 검정색으로 변경
    // 시간을 조건으로 찾으면 될거같음
    
    func highlightLyrics(for currentTime: String) {
        for (index,lyric) in lyrics.sorted(by: { $0.key < $1.key}).enumerated() {
            if currentTime == lyric.key {
                highlitedLyricIndex = index
                break
            }
        }
        
        
        if let cell = lyricsTableView.cellForRow(at: IndexPath(row: highlitedLyricIndex ?? 0, section: 0)) as? LyricTableViewCell {
            cell.lyricLabel.textColor = .red
        }
        
        // 나머지 셀들을 검정색으로 변경
        for (index,_) in sortedLyrics.enumerated() {
            if index != highlitedLyricIndex {
                if let cell = lyricsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? LyricTableViewCell {
                    cell.lyricLabel.textColor = .black
                }
            }
        }
    }

}


extension LyricsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTime = lyrics.sorted { $0.key < $1.key }[indexPath.row].key
        delegate?.didSelectLyric(selectedTime)
        self.dismiss(animated: true)
    }
}


extension LyricsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedLyrics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "lyricCell", for: indexPath) as? LyricTableViewCell else { return UITableViewCell() }
        
        cell.lyricLabel?.text = sortedLyrics[indexPath.row]
        
        return cell
    }

}
