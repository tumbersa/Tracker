//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 19.02.2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let titleLabel: UILabel = {
        let titleLabel  = UILabel()
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
    }
    
    private func layoutUI(){
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame

        
        view.addSubviews(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    func set(image: UIImage, title: String){
        backgroundImageView.image = image
        titleLabel.text = title
    }
}

