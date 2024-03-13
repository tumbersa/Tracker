//
//  TRModalCreationVC.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

protocol ModalChoiceVCDelegate: AnyObject {
    func showCreationTrackerVC(vc: UIViewController, state: ModalCreationTrackerVCMode)
}

final class ModalChoiceViewController: UIViewController {
    
    private let habitButton: UIButton = {
        let habitButton = UIButton()
        habitButton.backgroundColor = UIColor(resource: .trBlack)
        habitButton.setTitle(NSLocalizedString("habit", comment: ""), for: .normal)
        habitButton.layer.cornerRadius = 16
        return habitButton
    }()
    
    private let irregularEventButton: UIButton = {
        let irregularEventButton = UIButton()
        irregularEventButton.backgroundColor = UIColor(resource: .trBlack)
        irregularEventButton.setTitle(NSLocalizedString("irregularEvent", comment: ""), for: .normal)
        irregularEventButton.layer.cornerRadius = 16
        return irregularEventButton
    }()

    weak var delegate: ModalChoiceVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configure()
    }
    
    private func configure() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        title = NSLocalizedString("creatingTracker", comment: "")
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        view.addSubviews(habitButton, irregularEventButton)
        
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
    
    @objc private func irregularEventButtonTapped() {
        delegate?.showCreationTrackerVC(vc: self, state: .irregularEvent)
    }
    
    @objc private func habitButtonTapped(){
        delegate?.showCreationTrackerVC(vc: self, state: .habit)
    }
}
