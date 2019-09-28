//
//  ModalTransitionPresentationController.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class ModalTransitionPresentationController: UIPresentationController {
    
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }
}
