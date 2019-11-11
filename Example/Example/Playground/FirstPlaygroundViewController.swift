//
//  PlaygroundViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class FirstPlaygroundViewController: UIViewController {
    
    @IBAction func buttonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "SecondPlaygroundViewController")
        viewController.shift.modalTransition = .fade
        present(viewController, animated: true, completion: nil)
    }
}
