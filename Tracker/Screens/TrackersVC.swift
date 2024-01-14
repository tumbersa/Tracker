//
//  ViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.01.2024.
//

import UIKit

protocol TRCollectionViewCellDelegate: AnyObject {
    func plusButtonTapped(cell: TRCollectionViewCell)
}

final class TrackersVC: UIViewController {
    
    private let dateFormatter = DateFormatter()
        
    
    private var dictDays: Dictionary<DaysOfWeek.RawValue, [TrackerCategory]>  = [:]
    private var categories: [TrackerCategory]       = []
    private var completedTrackers: [TrackerRecord]  = []
    
    private var currentDate: Date = Date()
    
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
        configureCollectionView()
        
        if categories.isEmpty { configureEmptyState() }
    }

    @objc func actionAddBarItem(){
        present(UINavigationController(rootViewController: TRModalChoiceVC()), animated: true)
    }

    func configureVC(){
        view.backgroundColor = .systemBackground
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem            = UIBarButtonItem(barButtonSystemItem: .add,
                                                                      target: self,
                                                                      action: #selector(actionAddBarItem))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: getDatePicker())
    }
    
    func configureCollectionView(){
        //dictDays.updateValue(, forKey:)
        
        categories.append(TrackerCategory(header: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: .systemGreen, emoji: "❤️", schedule: [.sunday]),
            Tracker(id: UUID(), name: "Вынести мусор", color: .purple, emoji: "🙂", schedule: [.sunday])
        ]))
        
        categories.append(TrackerCategory(header: "Радостные мелочи", trackers: [
            Tracker(id: UUID(), name: "Свидания в апреле", color: .blue, emoji: "🥲", schedule: [.sunday])
        ]))
        
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TRCollectionViewCell.self, forCellWithReuseIdentifier: TRCollectionViewCell.reuseID)
        collectionView.register(TRSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TRSupplementaryView.reuseID)
       
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
        var prevDate = currentDate
        
        
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        currentDate = selectedDate
        print("Выбранная дата: \(formattedDate)")
        
        let cells = collectionView.visibleCells as! [TRCollectionViewCell]
        for cell in cells {
            print(cell.dictDateIsMarked)
            let isMarked = cell.dictDateIsMarked[formattedDate] ?? false
            if isMarked {
                cell.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                cell.plusButton.alpha = 0.3
            } else {
                cell.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                cell.plusButton.alpha = 1
            }
        }
        
//
//        guard let numDate = selectedDate.dayNumberOfWeek() else { return }
//        
//        var catCount: [Int] = []
//        var ids: [UUID] = []
//        
//        var categoriesWithDel: [TrackerCategory] = []
//        var visibleCategories: [TrackerCategory] = []
//        categories.forEach { i in
//            i.trackers.forEach { j in
//                catCount.append(i.trackers.count)
//                j.schedule?.forEach{ l in
//                    if l.rawValue == numDate  {
//                        visibleCategories.append(i)
//                    }
//                }
//                ids.append(j.id)
//            }
//        }
//        categories = visibleCategories
//        categories = [] //del
//        
//        var indexesToDel: [IndexPath] = []
//        
//        
//        var newCells = dictDays[numDate] ?? []
//        
//        var visCells = collectionView.visibleCells as! [TRCollectionViewCell]
//        
//        visCells.removeAll(where: { newCells.contains($0) })
//        
//        for cell in visCells {
//            indexesToDel.append(collectionView.indexPath(for: cell)!)
//        }
//        
//        let set = indexesToDel != [] ? IndexSet(arrayLiteral: 0,1) : []
//        
//        guard let keyPrev = prevDate.dayNumberOfWeek() else { return }
//        var oldCells = dictDays[keyPrev] ?? []
//        newCells.removeAll(where: { oldCells.contains($0) })
//        
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: indexesToDel)
//            collectionView.deleteSections(set)
//        }
        
        
        
        
        
        
        
        
//        func add(colors values: [UIColor]) {
//            
//            guard !values.isEmpty else { return }
//            
//            let count = colors.count
//            colors = colors + values
//                
//            collection.performBatchUpdates {
//                let indexes = (count..<colors.count).map { IndexPath(row: $0, section: 0) }
//                collection.insertItems(at: indexes)
//            }
//        }
        
        
//        visibleCategories.removeAll()
//        
//        var cellsToDelete: [UICollectionViewCell] = []
//        var cellGeneral: [UICollectionViewCell] = []
//        collectionView.visibleCells.forEach { i in
//            let cell = i as! TRCollectionViewCell
//           
//            if !ids.contains(cell.id) {
//                cellsToDelete.append(cell)
//            } else {
//                cellGeneral.append(cell)
//                ids.removeAll(where: {$0 == cell.id})
//            }
//        }
//        
//        
//        var indexPathsToDelete: [IndexPath] = []
//        cellsToDelete.forEach { i in
//            indexPathsToDelete.append(collectionView.indexPath(for: i)!)
//        }
//        
//        var indexPathsToInsert: [IndexPath] = []
//        categories.forEach { i in
//             
//        }
//        
//        
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: indexPathsToDelete)
//            collectionView.insertItems(at: [])
//        }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TRCollectionViewCell.reuseID, for: indexPath) as? TRCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let trackerItem = categories[indexPath.section].trackers[indexPath.item]
        
        cell.set(backgroundColor: trackerItem.color, emoji: trackerItem.emoji, name: trackerItem.name, countDaysText: "0 дней", id : trackerItem.id)
        
    
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
        
        //167 × 148  148 / 167 = 0,89
        return CGSize(width: itemWidth, height: itemWidth * 0.89)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    //Supplementary view
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TRSupplementaryView.reuseID, for: indexPath) as! TRSupplementaryView
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


extension TrackersVC: TRCollectionViewCellDelegate {
    func plusButtonTapped(cell: TRCollectionViewCell) {
        
        guard Date() >= currentDate else { return }
        
        let currentStringDate = dateFormatter.string(from:  currentDate)
        
        var isMarked: Bool
        isMarked = cell.dictDateIsMarked[currentStringDate] ?? false
        if isMarked {
            completedTrackers.removeAll(where: {$0.id == cell.id})
            cell.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.plusButton.alpha = 1
            
            cell.countDayRecord -= 1
            cell.countDaysLabel.text = DaysOfWeek.printDaysMessage(cell.countDayRecord)
        } else {
            completedTrackers.append(TrackerRecord(id: cell.id, date: currentDate))
            cell.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.plusButton.alpha = 0.3
            
            cell.countDayRecord += 1
            cell.countDaysLabel.text = DaysOfWeek.printDaysMessage(cell.countDayRecord)
        }
        
        isMarked.toggle()
        cell.dictDateIsMarked.updateValue(isMarked, forKey: currentStringDate)
    }
}
