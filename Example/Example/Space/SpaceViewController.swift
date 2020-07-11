//
//  SpaceViewController.swift
//  Example
//
//  Created by Wes Wickwire on 10/11/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class SpaceViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var ticketsAvailable: UIButton!
    @IBOutlet weak var spaceMan: UIImageView!
    @IBOutlet weak var spaceTravel: UILabel!
    @IBOutlet weak var earth: UIImageView!
    @IBOutlet weak var astronautTumbnail: UIImageView!
    @IBOutlet weak var astronautTumbnailContainer: UIView!
    @IBOutlet weak var movieDescription: UILabel!
    @IBOutlet weak var rating: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.baselineDuration = 0.75
        
        contentView.shift.position = .front
        contentView.shift.superview = .container
        contentView.shift.animations.fade()
        
        bottomSheet.layer.cornerRadius = 20
        bottomSheet.layer.masksToBounds = true
        bottomSheet.shift.animations.move(.up(280))
        
        astronautTumbnailContainer.shift.animations.move(.up(170))
        rating.shift.animations.move(.up(300))
        movieDescription.shift.animations.move(.up(400))
        
        ticketsAvailable.shift.animations.fade()
        
        spaceTravel.shift.animations.fade()
        
        earth.shift.animations.move(.up(100))
        
        spaceMan.shift.animations.scale(4).move(.up(600))
        
        ticketsAvailable.layer.masksToBounds = true
        ticketsAvailable.layer.cornerRadius = 25
        
        spaceTravel.layer.shadowColor = UIColor.black.cgColor
        spaceTravel.layer.shadowOffset = .zero
        spaceTravel.layer.shadowRadius = 10
        spaceTravel.layer.shadowOpacity = 0.3
        
        astronautTumbnail.layer.masksToBounds = true
        astronautTumbnail.layer.cornerRadius = 12
        
        astronautTumbnailContainer.layer.cornerRadius = 12
        astronautTumbnailContainer.layer.shadowColor = UIColor.black.cgColor
        astronautTumbnailContainer.layer.shadowOffset = .zero
        astronautTumbnailContainer.layer.shadowRadius = 10
        astronautTumbnailContainer.layer.shadowOpacity = 0.3
        astronautTumbnailContainer.layer.shadowPath = UIBezierPath(rect: astronautTumbnailContainer.bounds).cgPath
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.setLeftBarButton(UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(exitPressed)
        ), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delay {
            self.ticketsAvailablePressed(self)
        }
    }
    
    @IBAction func ticketsAvailablePressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "EarthViewController")
        viewController.shift.enable()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

func delay(_ action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: action)
}
