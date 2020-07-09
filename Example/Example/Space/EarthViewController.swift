//
//  EarthViewController.swift
//  Example
//
//  Created by Wes Wickwire on 10/11/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class EarthViewController: UIViewController {

    @IBOutlet weak var earth: UIImageView!
    @IBOutlet weak var earthLabel: UILabel!
    @IBOutlet weak var earthDescription: UILabel!
    @IBOutlet weak var moon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.baselineDuration = 0.75
        
        view.shift.animations = [.fade]
        
        earth.shift.animations = [.move(.up(300)), .move(.right(100)), .fade]
        
        earthLabel.shift.animations = [.move(.right(200)), .fade]
        earthDescription.shift.animations = [.move(.right(200)), .fade]
        
        moon.shift.animations = [.move(.left(200)), .fade]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(moonTapped))
        moon.isUserInteractionEnabled = true
        moon.addGestureRecognizer(tap)
    }
    
    @objc func moonTapped() {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "MoonViewController")
        viewController.shift.enable()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
