//
//  TRSupplementaryView.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import UIKit

final class TRSupplementaryView: UICollectionReusableView {
    static let reuseID = "header"
    
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(text: String) {
        headerLabel.text = text
    }
    
    func configure() {
        headerLabel.font = .systemFont(ofSize: 19, weight: .bold)
        
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
}
