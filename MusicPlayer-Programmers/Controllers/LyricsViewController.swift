//
//  LyricsViewController.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit

class LyricsViewController: UIViewController {
    
    var lyricsVM: LyricsViewModel!
    
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var lyricsSwitch: UISwitch!
    
    @IBAction func lyricsViewDismissButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func lyricSwitchValueChanged(_ sender: Any) {
        Singletone.shared.switchState = self.lyricsSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}

extension LyricsViewController: UITableViewDelegate {
    
}

extension LyricsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lyricsVM.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "lyricCell") as? LyricTableViewCell else  { return UITableViewCell() }
        
        cell.lyricLabel.text = lyricsVM.Lyrics[indexPath.row]
        
        return cell
    }
    
    
}
