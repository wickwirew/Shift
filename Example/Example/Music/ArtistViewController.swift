//
//  ViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class ArtistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerSongTitle: UILabel!
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.formatterBehavior = .behavior10_4
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    var songs: [Song] = [
        Song(name: "Starboy", numberOfListens: 1_456_542_453),
        Song(name: "Call Out My Name", numberOfListens: 436_645_343),
        Song(name: "The Hills", numberOfListens: 843_345_733),
        Song(name: "I Feel It Coming", numberOfListens: 345_878_476),
        Song(name: "Can't Feel My Face", numberOfListens: 844_452_224),
    ]
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.enable()
        shift.defaultAnimation = DefaultAnimations.Scale(.down)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        playerSongTitle.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(titlePressed))
        playerSongTitle.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delay {
            self.titlePressed()
        }
    }
    
    @objc func titlePressed() {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "SongPlayerViewController")
        viewController.view.backgroundColor = .black
        viewController.shift.enable()
        present(viewController, animated: true, completion: nil)
    }
    
    struct Song {
        let name: String
        let numberOfListens: Int
    }
}

extension ArtistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongCell
        cell.songTitle.text = songs[indexPath.row].name
        cell.listens.text = formatter.string(from: songs[indexPath.row].numberOfListens as NSNumber)
        cell.trackNumber.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
}
