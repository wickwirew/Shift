//
//  MovieViewController.swift
//  Example
//
//  Created by Wes Wickwire on 7/9/20.
//  Copyright © 2020 Wes Wickwire. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    @IBOutlet weak var worker: UIImageView!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var xButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.baselineDuration = 0.4
        
        actionsButton.layer.cornerRadius = 34
        actionsButton.layer.masksToBounds = true
        actionsButton.shift.animations.move(.up(200))
        
        view.shift.animations.fade()
        xButton.shift.animations.fade()
        
        contentView.shift.animations.fade()
        
        background.shift.animations.scale(1.1)
        worker.shift.animations.move(.left(40))
    }
    
    @IBAction func actionsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func xPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
