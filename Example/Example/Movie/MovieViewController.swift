//
//  MovieViewController.swift
//  Example
//
//  Created by Wes Wickwire on 7/9/20.
//  Copyright © 2020 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class MovieViewController: UIViewController {
    @IBOutlet weak var worker: UIImageView!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var xButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shift.baselineDuration = 0.5
        
        let filter: Animations.Condition = { $0.toViewControllerType != ActionsViewController.self && !$0.isDisappear }
        
        actionsButton.layer.cornerRadius = 34
        actionsButton.layer.masksToBounds = true
        actionsButton.shift.id = "background"
        actionsButton.shift.animations.move(.up(200), filter)
        actionsButton.imageView?.shift.id = "movieIcon"
        
        view.shift.animations.fade(filter)
        xButton.shift.animations.fade(filter)
        
        contentView.shift.animations.fade(filter)
        
        background.shift.animations.scale(1.1, filter)
        worker.shift.animations.move(.left(40), filter)
    }
    
    @IBAction func actionsButtonPressed(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "ActionsViewController")
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func xPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
