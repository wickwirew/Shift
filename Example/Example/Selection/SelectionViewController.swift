//
//  SelectionViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Transition

class SelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var examples: [Section] = [
        Section(name: "Demos", examples: [
            Example(name: "Music Player", viewController: "ArtistViewController"),
            Example(name: "Playground", viewController: "FirstPlaygroundViewController"),
            Example(name: "Space", viewController: "SpaceViewController", isModal: false),
        ]),
        Section(name: "Modal Transitions", examples: [
            Example(name: "Fade", viewController: "ContentViewController", modalTransition: .fade),
            Example(name: "Slide Left", viewController: "ContentViewController", modalTransition: .slide(.left)),
            Example(name: "Slide Right", viewController: "ContentViewController", modalTransition: .slide(.right)),
            Example(name: "Slide Up", viewController: "ContentViewController", modalTransition: .slide(.up)),
            Example(name: "Slide Down", viewController: "ContentViewController", modalTransition: .slide(.down)),
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    struct Example {
        let name: String
        let viewController: String
        let modalTransition: ModalTransition
        let isModal: Bool
        
        init(name: String,
             viewController: String,
             modalTransition: ModalTransition = .fade,
             isModal: Bool = true) {
            self.name = name
            self.viewController = viewController
            self.modalTransition = modalTransition
            self.isModal = isModal
        }
    }
    
    struct Section {
        let name: String
        let examples: [Example]
    }
}

extension SelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = examples[indexPath.section].examples[indexPath.row].name
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples[section].examples.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return examples[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let example = examples[indexPath.section].examples[indexPath.row]
        
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: example.viewController)
        viewController.shift.modalTransition = example.modalTransition
        
        if example.isModal {
            present(viewController, animated: true, completion: nil)
        } else {
            let nav = UINavigationController(rootViewController: viewController)
            nav.shift.modalTransition = .fade
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
}
