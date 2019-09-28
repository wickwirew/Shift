//
//  NextViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    @IBOutlet weak var albumCover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCover.layer.masksToBounds = true
        albumCover.layer.cornerRadius = 10
    }
}
