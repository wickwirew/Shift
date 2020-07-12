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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.enable()
        item.shift.id = "item"
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
