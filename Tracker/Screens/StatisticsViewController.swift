//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {

    private lazy var statisticsView = StatisticsView()
    
    private lazy var emptyStateImageView: UIImageView = {
        let emptyStateImageView = UIImageView()
        emptyStateImageView.image = UIImage(resource: .trEmptyStateStatistics)
        return emptyStateImageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = NSLocalizedString("statistics.EmptyState.title", comment: "")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    private var viewModel: StatisticsViewModelProtocol
    
    init(viewModel: StatisticsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureVC()
        configureStatisticsView()
        
        view.layoutIfNeeded()
        statisticsView.addGradientBorder(colors: [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1.0).cgColor, // #FD4C49
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1.0).cgColor, // #46E69D
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1.0).cgColor // #007BFA
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.isEmptyFinishedTrackers()
    }
    
    private func configureVC() {
        
        viewModel.completedTrackersBinding = {[weak self] (arg0) in
            guard let self else { return }
            
            if arg0.0 {
                configureEmptyState(isEmpty: true)
            } else {
                configureEmptyState(isEmpty: false)
                statisticsView.set(num: arg0.1 ?? 0)
            }
        }
        
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("statistics", comment: "")
    }
    
    private func configureStatisticsView() {
        view.addSubviews(statisticsView)
        
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            statisticsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func configureEmptyState(isEmpty: Bool) {
        if isEmpty {
            statisticsView.removeFromSuperview()
            
            view.addSubviews(emptyStateImageView, emptyStateLabel)
            
            NSLayoutConstraint.activate([
                emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 36),
                emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
                emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
                
                emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
                emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                emptyStateLabel.heightAnchor.constraint(equalToConstant: 18)
            ])
        } else {
            configureStatisticsView()
            
            emptyStateLabel.removeFromSuperview()
            emptyStateImageView.removeFromSuperview()
        }
    }

}

