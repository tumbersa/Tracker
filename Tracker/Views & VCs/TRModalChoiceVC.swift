//
//  TRModalCreationVC.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

class TRModalChoiceVC: UIViewController {
    
    let habitButton = UIButton()
    let irregularEventButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configure()
    }
    
    func configure() {
        title = "Создание трекера"
        
        habitButton.backgroundColor = UIColor(resource: .trBlack)
        habitButton.tintColor = .white
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.layer.cornerRadius = 16
        
        irregularEventButton.backgroundColor = UIColor(resource: .trBlack)
        irregularEventButton.tintColor = .white
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.layer.cornerRadius = 16
        
        view.addSubviews(habitButton, irregularEventButton)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -247),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.bottomAnchor.constraint(equalTo: irregularEventButton.topAnchor, constant: -16),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
