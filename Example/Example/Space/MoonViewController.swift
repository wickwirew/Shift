//
//  MoonViewController.swift
//  Example
//
//  Created by Wes Wickwire on 10/18/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class MoonViewController: UIViewController {
    
    @IBOutlet weak var moonLabel: UILabel!
    @IBOutlet weak var moonDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.baselineDuration = 0.75
        
        view.shift.animations.fade()
        
        moonLabel.shift.animations.move(.left(200)).fade()
        moonDescription.shift.animations.move(.left(200)).fade()
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
