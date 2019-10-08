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
    @IBOutlet weak var whiteSquare: UIView!
    @IBOutlet weak var smallSquare: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.shift.animations = [.fade]
        whiteSquare.shift.animations = [.translate(y: 303)]
        whiteSquare.shift.superview = .container
        smallSquare.shift.animations = [.translate(x: 414)]
        square.shift.contentSizing = .final
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
