//
//  SecondPlaygroundViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Transition

class SecondPlaygroundViewController: UIViewController {

    @IBOutlet weak var square: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        square.shift.contentAnimation = .fade
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
