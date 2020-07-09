//
//  SelectionViewController.swift
//  Example
//
//  Created by Wes Wickwire on 9/28/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit
import Shift

class SelectionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var examples: [Section] = [
        Section(name: "Demos", examples: [
            Example(name: "Music Player", viewController: "ArtistViewController"),
            Example(name: "Playground", viewController: "FirstPlaygroundViewController"),
            Example(name: "Space", viewController: "SpaceViewController", isModal: false),
        ]),
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
        let isModal: Bool
        
        init(name: String,
             viewController: String,
             isModal: Bool = true) {
            self.name = name
            self.viewController = viewController
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
        viewController.shift.enable()
        
        if example.isModal {
            present(viewController, animated: true, completion: nil)
        } else {
            let nav = UINavigationController(rootViewController: viewController)
            nav.shift.enable()
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
}
