//
//  ViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Transition

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerSongTitle: UILabel!
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
    var songs: [Song] = [
        Song(name: "Daft Pretty Boys", numberOfListens: 54215834),
        Song(name: "Cardiac Arrest", numberOfListens: 35255653),
        Song(name: "Off She Goes", numberOfListens: 54786542),
        Song(name: "This Was a Home Once", numberOfListens: 12874755),
        Song(name: "Violet", numberOfListens: 1954381),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        playerSongTitle.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(titlePressed))
        playerSongTitle.addGestureRecognizer(tap)
    }
    
    @objc func titlePressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "NextViewController")
        viewController.view.backgroundColor = .black
        present(viewController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongCell
        cell.songTitle.text = songs[indexPath.row].name
        cell.listens.text = formatter.string(from: songs[indexPath.row].numberOfListens as NSNumber)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
}
