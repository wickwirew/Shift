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
    
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var ticketsAvailable: UIButton!
    @IBOutlet weak var spaceMan: UIImageView!
    @IBOutlet weak var spaceTravel: UILabel!
    @IBOutlet weak var earth: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: bottomSheet.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 20)
        ).cgPath
        bottomSheet.layer.mask = maskLayer
        
        bottomSheet.shift.animations = [.move(.up(280))]
        
        ticketsAvailable.layer.masksToBounds = true
        ticketsAvailable.layer.cornerRadius = 25
        ticketsAvailable.shift.superview = .container
        ticketsAvailable.shift.animations = [.fade]
        
        spaceTravel.shift.superview = .parent
        spaceTravel.shift.animations = [.fade]
        spaceTravel.shift.contentAnimation = .none
        
        earth.shift.animations = [.move(.up(100))]
        
        spaceMan.shift.animations = [.fade, .scale(3), .move(.up(400))]
        spaceMan.shift.contentAnimation = .none
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
