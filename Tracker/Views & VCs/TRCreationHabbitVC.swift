//
//  TRCreationHabbitVC.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

class TRCreationHabbitVC: UIViewController {

    let nameTextField = UITextField()
    let tableView = UITableView()
    let createButton = UIButton()
    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func configure() {
        view.backgroundColor = .systemBackground
        title = "Новая Привычка"
        
        
    }

}
