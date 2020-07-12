//
//  SecondPlaygroundViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class SecondPlaygroundViewController: UIViewController {
    @IBOutlet weak var item: UIView!
    @IBOutlet weak var star: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.enable()
        shift.baselineDuration = 1
        
        item.shift.animations
            .fade()
            .move(.right(150))
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
