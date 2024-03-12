//
//  TRDatePicker.swift
//  Tracker
//
//  Created by Глеб Капустин on 12.03.2024.
//

import UIKit


final class TRDatePicker: UIDatePicker {
    
    private let patchLabel: UILabel = {
        let patchLabel = UILabel()
        patchLabel.backgroundColor = .trLightGray
        patchLabel.layer.cornerRadius = 8
        patchLabel.clipsToBounds = true
        patchLabel.isUserInteractionEnabled = false
        patchLabel.textAlignment = .center
        patchLabel.font = .systemFont(ofSize: 17, weight: .regular)
        return patchLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        datePickerMode = .date
        preferredDatePickerStyle = .compact
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        minimumDate = minDate
        maximumDate = maxDate
        
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 77),
            heightAnchor.constraint(equalToConstant: 34)
        ])
        
        addSubviews(patchLabel)
        NSLayoutConstraint.activate([
            patchLabel.topAnchor.constraint(equalTo: topAnchor),
            patchLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            patchLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            patchLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(text: String) {
        patchLabel.text = text
    }
}
