//
//  ViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.01.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func plusButtonTapped(cell: TrackerCollectionViewCell)
}

final class TrackersViewController: UIViewController {
    private let dateFormatter = DateFormatter()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var allCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()

    private let emptyStateImageView: UIImageView = {
        let emptyStateImageView = UIImageView()
        emptyStateImageView.image = UIImage(resource: .trEmptyStateTrackers)
        return emptyStateImageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Что будем отслеживать?"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()

    private let patchView: UIView = {
        let patchView = UIView()
        patchView.backgroundColor = .systemBackground
        patchView.isUserInteractionEnabled = false
        patchView.translatesAutoresizingMaskIntoConstraints = false
        return patchView
    }()
    
    private let patchLabel: UILabel = {
        let patchLabel = UILabel()
        patchLabel.backgroundColor = .trLightGray
        patchLabel.layer.cornerRadius = 8
        patchLabel.clipsToBounds = true
        patchLabel.isUserInteractionEnabled = false
        patchLabel.textAlignment = .center
        patchLabel.font = .systemFont(ofSize: 17, weight: .regular)
        patchLabel.translatesAutoresizingMaskIntoConstraints = false
        return patchLabel
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
    
        return datePicker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureVC()
        configureCollectionView()
        configurePatchViews()
        configureEmptyState(isEmpty: categories.isEmpty)
    }

    private func configurePatchViews(){
        let bar = navigationController!.navigationBar
        bar.addSubview(patchView)
        bar.bringSubviewToFront(patchView)
        
        patchLabel.text = dateFormatter.string(from: currentDate)
        patchView.addSubview(patchLabel)
    
        NSLayoutConstraint.activate([
            patchView.topAnchor.constraint(equalTo: bar.topAnchor, constant: 0),
            patchView.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            patchView.widthAnchor.constraint(equalToConstant: 188),
            patchView.heightAnchor.constraint(equalToConstant: 44),
            
            patchLabel.widthAnchor.constraint(equalToConstant: 77),
            patchLabel.trailingAnchor.constraint(equalTo: patchView.trailingAnchor, constant: -16),
            patchLabel.topAnchor.constraint(equalTo: patchView.topAnchor, constant: 5),
            patchLabel.bottomAnchor.constraint(equalTo: patchView.bottomAnchor, constant: -5)
        ])
    }
    
    @objc private func actionAddBarItem(){
        let vcToShow = ModalChoiceViewController()
        vcToShow.delegate = self
        present(UINavigationController(rootViewController: vcToShow), animated: true)
    }

    
    private func configureVC(){
        //trackerCategoryStore.clearDB()
        //trackerCategoryStore.addNewTrackerCategory(MockData.category)
        
        allCategories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.trackerRecords
        
        view.backgroundColor = .systemBackground
        dateFormatter.dateFormat = "dd.MM.yy"
    
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(actionAddBarItem))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    private func configureCollectionView(){
        updateCategories()
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseID)
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseID)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        currentDate = selectedDate
        patchLabel.text = formattedDate
        
        updateCategories()
        collectionView.reloadData()
        configureEmptyState(isEmpty: categories.isEmpty)
    }
    
    private func configureEmptyState(isEmpty: Bool) {
        if isEmpty {
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
            emptyStateLabel.removeFromSuperview()
            emptyStateImageView.removeFromSuperview()
        }
    }
    
    private func updateCategories(){
        categories.removeAll()
        allCategories.forEach {
            var newTrackers: [Tracker] = []
            for tracker in $0.trackers {
                if tracker.schedule.contains(where: { $0.rawValue == currentDate.dayNumberOfWeek() }) {
                    newTrackers.append(tracker)
                }
            }
            if !newTrackers.isEmpty  {
                categories.append(TrackerCategory(header: $0.header, trackers: newTrackers))
            }
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let trackerItem = categories[indexPath.section].trackers[indexPath.item]
        setInitialStateButton(cell: cell, trackerItem: trackerItem)
        cell.set(backgroundColor: trackerItem.color, emoji: trackerItem.emoji, name: trackerItem.name)
        return cell
    }
    
    private func setInitialStateButton(cell: TrackerCollectionViewCell, trackerItem: Tracker){
        var isMarked: Bool = false
        var countDayRecord = 0
        completedTrackers.forEach {
            if trackerItem.id == $0.id && dateFormatter.string(from: currentDate) == dateFormatter.string(from: $0.date) {
                isMarked = true
            }
            if trackerItem.id == $0.id {
                countDayRecord += 1
            }
        }
        
        if isMarked {
            cell.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.plusButton.alpha = 0.3
        } else {
            cell.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.plusButton.alpha = 1
        }
        cell.countDaysLabel.text = DaysOfWeek.printDaysMessage(countDayRecord)
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat            = 16
        let minimumItemSpacing: CGFloat = 9
        let availavleWidth = view.frame.width - (padding * 2) - minimumItemSpacing
        let itemWidth = availavleWidth / 2
        
        //167 × 148  148 / 167 = 0,89
        return CGSize(width: itemWidth, height: itemWidth * 0.89)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    //MARK: -Supplementary view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseID, for: indexPath) as! TrackerSupplementaryView
        view.set(text: categories[indexPath.section].header)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(item: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, 
            height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
    func plusButtonTapped(cell: TrackerCollectionViewCell) {
        
        guard Date() >= currentDate else { return }
        
        let indexPath = collectionView.indexPath(for: cell)!
        let trackerItem = categories[indexPath.section].trackers[indexPath.item]
        let currentDateString = dateFormatter.string(from: currentDate)
        
        var isMarked: Bool = false
        var countDayRecord = 0
        completedTrackers.forEach {
            if trackerItem.id == $0.id && currentDateString == dateFormatter.string(from: $0.date) {
                isMarked = true
            }
            if trackerItem.id == $0.id {
                countDayRecord += 1
            }
        }
        
        if isMarked {
            trackerRecordStore.deleteTrackerRecord(
                trackerRecord: TrackerRecord(id: trackerItem.id, date: currentDate))
            completedTrackers.removeAll(where: {$0.id == trackerItem.id && currentDateString == dateFormatter.string(from: $0.date)})
            cell.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.plusButton.alpha = 1
            
            countDayRecord -= 1
        } else {
            let newTrackerRecord = TrackerRecord(id: trackerItem.id, date: currentDate)
            trackerRecordStore.addTrackerRecord(trackerRecord: newTrackerRecord)
            completedTrackers.append(newTrackerRecord)
            cell.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.plusButton.alpha = 0.3
            
            countDayRecord += 1
        }
        cell.countDaysLabel.text = DaysOfWeek.printDaysMessage(countDayRecord)
    }
}

extension TrackersViewController: ModalChoiceVCDelegate {
    func showCreationTrackerVC(vc: UIViewController, state: ModalCreationTrackerVCState) {
        vc.dismiss(animated: true)
        let vc = CreationTrackerViewController(state: state)
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension TrackersViewController: ModalCreationTrackerVCDelegate {
    func createTracker(category: TrackerCategory) {
        var isExist = false
        var trackers: [Tracker] = []
        for (index, i) in allCategories.enumerated() {
            if i.header == category.header {
                isExist = true
                trackers.append(contentsOf: i.trackers)
                trackers.append(contentsOf: category.trackers)
                
                let trackerCategory = TrackerCategory(header: i.header, trackers: trackers)
                trackerCategoryStore.updateObject(trackerCategory: trackerCategory)
                allCategories[index] = trackerCategory
            }
        }
        if !isExist {
            trackerCategoryStore.addNewTrackerCategory(category)
            allCategories.append(category)
        }
        updateCategories()
        collectionView.reloadData()
        configureEmptyState(isEmpty: categories.isEmpty)
    }
}
