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
        
        shift.modalTransition = .fade
        
        view.shift.animations = [.fade]
        
        whiteSquare.shift.animations = [.move(.up(303))]
        whiteSquare.shift.superview = .container
        smallSquare.shift.animations = [.move(.right(414)), .color(.red)]
        square.shift.contentSizing = .stretch
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
