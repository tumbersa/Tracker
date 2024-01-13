//
//  ViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.01.2024.
//

import UIKit

class TrackersVC: UIViewController {
    
    let dateFormatter = DateFormatter()
        
    
    private var categories: [TrackerCategory]       = []
    private var completedTrackers: [TrackerRecord]  = []
    private var completedId: Set<UUID>              = []
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds,collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
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
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if categories.isEmpty { configureEmptyState() }
    }

    @objc func actionAddBarItem(){}

    func configureVC(){
        categories.append(TrackerCategory(header: "Домашний уют", trackers: [Tracker(id: UUID(), name: "Поливать растения", color: .systemGreen, emoji: "❤️", schedule: [.allDays])]))
        view.addSubview(collectionView)
       
        
        
        view.backgroundColor = .systemBackground
        collectionView.register(TRCollectionViewCell.self, forCellWithReuseIdentifier: TRCollectionViewCell.reuseID)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem            = UIBarButtonItem(barButtonSystemItem: .add,
                                                                      target: self,
                                                                      action: #selector(actionAddBarItem))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: getDatePicker())
    }
    
    
    func getDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact

        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
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

extension TrackersVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TRCollectionViewCell.reuseID, for: indexPath) as? TRCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let trackerItem = categories[indexPath.section].trackers[indexPath.item]
        
        cell.set(backgroundColor: trackerItem.color, emoji: trackerItem.emoji, name: trackerItem.name, countDaysText: "0 дней")
        
        return cell
    }
}


extension TrackersVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat            = 16
        let minimumItemSpacing: CGFloat = 9
        let availavleWidth = view.frame.width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availavleWidth / 2
        return CGSize(width: itemWidth, height: itemWidth + 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
}
