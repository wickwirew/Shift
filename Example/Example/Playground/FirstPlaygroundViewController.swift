//
//  PlaygroundViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class FirstPlaygroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "SecondPlaygroundViewController")
        present(viewController, animated: true, completion: nil)
    }
}
