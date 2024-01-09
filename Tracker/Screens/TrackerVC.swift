//
//  ViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.01.2024.
//

import UIKit

class TrackerVC: UIViewController {
    
    private var trackers: [Tracker] = []
    
    private lazy var emptyStateImageView: UIImageView = {
        let emptyStateImageView = UIImageView()
        emptyStateImageView.image = UIImage(resource: .trEmptyStateTrackers)
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        return emptyStateImageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        return emptyStateLabel
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureVC()
        
        if trackers.isEmpty {
            configureEmptyState()
        }
    }

    @objc func actionAddBarItem(){}

    func configureVC(){
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem            = UIBarButtonItem(barButtonSystemItem: .add,
                                                                      target: self,
                                                                      action: #selector(actionAddBarItem))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func configureEmptyState() {
        view.addSubviews(emptyStateImageView, emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //812 - 80 = 732; 732 / 2 = 366; 402 - 366 = 36
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 36),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        
    }
}

