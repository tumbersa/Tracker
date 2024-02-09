//
//  IconPalleteCollectionViewCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 25.01.2024.
//

import UIKit

class IconPaletteEmojiCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "IconPalleteEmojiCell"
    
    private let emojiLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func getEmoji() -> String {
        emojiLabel.text ?? ""
    }
    
    private func configure() {
        contentView.layer.cornerRadius = 16
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        contentView.addSubviews(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
