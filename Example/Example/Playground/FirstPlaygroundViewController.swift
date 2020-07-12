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
    @IBOutlet weak var item: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        item.shift.id = "item"
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "SecondPlaygroundViewController")
        viewController.shift.enable()
        present(viewController, animated: true, completion: nil)
    }
}
