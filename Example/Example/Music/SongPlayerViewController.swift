//
//  NextViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class SongPlayerViewController: UIViewController {
    
    @IBOutlet weak var albumCover: UIImageView!
    
    let gradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCover.layer.masksToBounds = false
        albumCover.layer.shadowColor = UIColor.black.cgColor
        albumCover.layer.shadowOffset = .zero
        albumCover.layer.shadowRadius = 15
        albumCover.layer.shadowOpacity = 0.3
        
        view.layer.insertSublayer(gradient, at: 0)
        
        gradient.colors = [
            UIColor(red: 128/255.0, green: 15/255.0, blue: 26/255.0, alpha: 1).cgColor,
            UIColor(red: 188/255.0, green: 28/255.0, blue: 44/255.0, alpha: 1).cgColor,
            UIColor(red: 84/255.0, green: 14/255.0, blue: 21/255.0, alpha: 1).cgColor,
        ]
        
        gradient.locations = [0, 0.3, 1]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        albumCover.layer.shadowPath = UIBezierPath(rect: albumCover.bounds).cgPath
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
