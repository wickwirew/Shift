//
//  ActionsViewController.swift
//  Example
//
//  Created by Wes Wickwire on 7/9/20.
//  Copyright © 2020 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class ActionsViewController: UIViewController {
    let transition = ActionsTransitionDelegate()
    @IBOutlet weak var moveIcon: UIImageView!
    @IBOutlet weak var actionsLabel: UILabel!
    @IBOutlet weak var addToWatchLater: UIView!
    @IBOutlet weak var addToFavorites: UIView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTransition()
    }
    
    func setupTransition() {
        transitioningDelegate = transition
        modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.shift.id = "background"
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        moveIcon.shift.id = "movieIcon"
        
        styleContainer(addToWatchLater)
        styleContainer(addToFavorites)
    }
    
    func styleContainer(_ container: UIView) {
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 8
    }
}

class ActionsTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return ActionsPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionDismissing()
    }

    func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalTransitionPresenting()
    }
}

class ActionsPresentationController: UIPresentationController {
    let background = UIButton()
    let width = CGFloat(275)
    let height = CGFloat(263)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: containerView.frame.width - 20 - width,
            y: containerView.frame.height - 20 - height,
            width: width,
            height: height
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.insertSubview(background, at: 0)
        background.addTarget(self, action: #selector(backgroundSelected), for: .touchUpInside)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        background.frame = containerView?.frame ?? .zero
    }
    
    @objc func backgroundSelected() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
