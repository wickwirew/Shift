//
//  SpaceViewController.swift
//  Example
//
//  Created by Wes Wickwire on 10/11/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Transition

class SpaceViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var ticketsAvailable: UIButton!
    @IBOutlet weak var spaceMan: UIImageView!
    @IBOutlet weak var spaceTravel: UILabel!
    @IBOutlet weak var earth: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.shift.position = .front
        contentView.shift.superview = .container
        contentView.shift.animations = [.fade]
        
        bottomSheet.layer.cornerRadius = 20
        bottomSheet.layer.masksToBounds = true
        bottomSheet.shift.animations = [.move(.up(280))]
        
        ticketsAvailable.layer.masksToBounds = true
        ticketsAvailable.layer.cornerRadius = 25
        ticketsAvailable.shift.animations = [.fade]
        
        spaceTravel.shift.animations = [.fade]
        earth.shift.animations = [.move(.up(100))]
        
        spaceMan.shift.animations = [.fade, .scale(3), .move(.up(400))]
    }
    
    @IBAction func ticketsAvailablePressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "EarthViewController")
        viewController.shift.modalTransition = .fade
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
