//
//  TRCollectionViewCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

final class TRCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "TRCell"
    
    let containerView = UIView()
    let plusButton = UIButton()
    let countDaysLabel = UILabel()
    
    //TODO: - поменять на image
    let emojiLabel = UILabel()
    let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(containerView, countDaysLabel, plusButton)
        containerView.addSubviews(emojiLabel, nameLabel)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(backgroundColor: UIColor,emoji: String, name: String, countDaysText: String) {
        plusButton.backgroundColor = backgroundColor
        containerView.backgroundColor = backgroundColor
        
        emojiLabel.text = emoji
        nameLabel.text = name
        countDaysLabel.text = countDaysText
    }
    
    func configure() {
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.layer.cornerRadius = 17
        countDaysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        countDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -58),
            
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            countDaysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            countDaysLabel.heightAnchor.constraint(equalToConstant: 18),
            countDaysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            countDaysLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: 8),
            
            //ContainerView
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            //nameLabel.heightAnchor.constraint(equalToConstant: 34),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        
    }
}
