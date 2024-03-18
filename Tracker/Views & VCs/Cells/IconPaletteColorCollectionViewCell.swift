//
//  IconPaletteColorCollectionViewCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 25.01.2024.
//

import UIKit

class IconPaletteColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "IconPalleteColorCell"
    
    private lazy var colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func getColor() -> UIColor {
        colorView.backgroundColor ?? UIColor()
    }
    
    private func configure(){
        contentView.layer.borderWidth = 3
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.systemBackground.cgColor
        contentView.addSubviews(colorView)
        colorView.layer.cornerRadius = 10
        
        let padding: CGFloat = 6
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
}
