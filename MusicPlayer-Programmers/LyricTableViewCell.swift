//
//  LyricTableViewCell.swift
//  MusicPlayer-Programmers
//
//  Created by 김두원 on 2023/04/06.
//

import UIKit
import SnapKit

class LyricTableViewCell: UITableViewCell {
    // label 생성

    let lyricLabel = UILabel()
    static let identifier = "lyricsTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        lyricLabel.text = "가사정보"
        lyricLabel.textColor = .black
        lyricLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        lyricLabel.textAlignment = .left
        lyricLabel.numberOfLines = 0
        lyricLabel.sizeToFit()
        
        contentView.addSubview(lyricLabel)
        
        lyricLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
