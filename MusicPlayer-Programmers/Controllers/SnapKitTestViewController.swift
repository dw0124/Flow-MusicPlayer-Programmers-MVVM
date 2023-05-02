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
class SnapkitTestViewController: UIViewController, UITableViewDelegate {
    
    let tableView = UITableView()
    
    let arr = ["1", "2", "3", "4", "5", "6", "7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        print(arr[1])
    }
    
}

extension SnapkitTestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard let cell = tableView.dequeueReusableCell(withIdentifier: "lyricCell") as? LyricTableViewCell else {
        //    return UITableViewCell()
        //}
        let cell = UITableViewCell()
        
        cell.textLabel?.text = arr[indexPath.row]
        
        return cell
    }
    
    
}
