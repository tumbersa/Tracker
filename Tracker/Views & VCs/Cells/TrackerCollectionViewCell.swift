//
//  TRCollectionViewCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

protocol SomeData {}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "TrackerCollectionCell"

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        return containerView
    }()
    
    private let containerEmojiView: UIView = {
        let containerEmojiView = UIView()
        containerEmojiView.layer.cornerRadius = 12
        containerEmojiView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        containerEmojiView.clipsToBounds = true
        return containerEmojiView
    }()
    
    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.textAlignment = .center
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        return nameLabel
    }()
    
    let plusButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.layer.cornerRadius = 17
        return plusButton
    }()
    
    let countDaysLabel: UILabel = {
        let countDaysLabel = UILabel()
        countDaysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return countDaysLabel
    }()
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(containerView, countDaysLabel, plusButton)
        containerView.addSubviews(containerEmojiView, nameLabel)
        containerEmojiView.addSubview(emojiLabel)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(backgroundColor: UIColor,emoji: String, name: String) {
        plusButton.backgroundColor = backgroundColor
        containerView.backgroundColor = backgroundColor
        emojiLabel.text = emoji
        nameLabel.text = name
    }
    
    @objc func plusButtonTapped(){
        delegate?.plusButtonTapped(cell: self)
    }
    
    func configure() {
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
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
            
            //containerEmojiView
            containerEmojiView.heightAnchor.constraint(equalToConstant: 24),
            containerEmojiView.widthAnchor.constraint(equalToConstant: 24),
            containerEmojiView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            containerEmojiView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            emojiLabel.leadingAnchor.constraint(equalTo: containerEmojiView.leadingAnchor, constant: 4),
            emojiLabel.trailingAnchor.constraint(equalTo: containerEmojiView.trailingAnchor, constant: -4),
            emojiLabel.topAnchor.constraint(equalTo: containerEmojiView.topAnchor, constant: 1),
            emojiLabel.bottomAnchor.constraint(equalTo: containerEmojiView.bottomAnchor, constant: -1),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
}

extension TrackerCollectionViewCell: SomeData {}
