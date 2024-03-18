//
//  StatisticsView.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.03.2024.
//

import UIKit

final class StatisticsView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var numLabel: UILabel = {
        let numLabel = UILabel()
        numLabel.font = .systemFont(ofSize: 34, weight: .bold)
        numLabel.text = "0"
        return numLabel
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.text = NSLocalizedString("trackersCompleted", comment: "")
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureStackView()

    }
    
    convenience init() {
        self.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(num: Int){
        numLabel.text = "\(num)"
    }
    
    private func configureStackView() {
        addSubviews(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(numLabel)
        stackView.addArrangedSubview(titleLabel)
    }
}
