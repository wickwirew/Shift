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
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(
            x: 20,
            y: containerView.frame.height - 350 - 20,
            width: containerView.frame.width - 40,
            height: 350
        )
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width - 40, height: 350)
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
