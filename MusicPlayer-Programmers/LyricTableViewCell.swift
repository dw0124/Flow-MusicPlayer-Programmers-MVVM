//
//  LyricTableViewCell.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit

class LyricTableViewCell: UITableViewCell {

    @IBOutlet weak var lyricLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
