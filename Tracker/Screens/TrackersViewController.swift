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
   
    private var viewModel: TrackersViewModelProtocol
   
    private var currentDate: Date {
        viewModel.currentDate
    }

    private lazy var emptyStateImageView: UIImageView = {
        let emptyStateImageView = UIImageView()
        emptyStateImageView.image = UIImage(resource: .trEmptyStateTrackers)
        return emptyStateImageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
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
    

    init(viewModel: TrackersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureVC()
        configureCollectionView()
        configurePatchViews()
        configureEmptyState(isEmpty: viewModel.visibleTrackerCategories.isEmpty)
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
        viewModel.allTrackerCategoriesBinding = { [weak self] _ in
            guard let self else { return }
            collectionView.reloadData()
            configureEmptyState(isEmpty: viewModel.visibleTrackerCategories.isEmpty)
        }
        
        viewModel.completedTrackersBinding = { (arg0) in
            
            let (isSetPlus, countDayRecord, cell) = arg0
            guard let cell = cell as? TrackerCollectionViewCell else { return }
            if isSetPlus {
                cell.plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
                cell.plusButton.alpha = 1
            } else {
                cell.plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                cell.plusButton.alpha = 0.3
            }
            
            cell.countDaysLabel.text = DaysOfWeek.printDaysMessage(countDayRecord)
        }
       
        
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
        
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseID)
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseID)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        viewModel.currentDate = selectedDate
        patchLabel.text = formattedDate
        
        
        viewModel.updateTrackers()
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
    
   
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.visibleTrackerCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.visibleTrackerCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseID, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let trackerItem = viewModel.visibleTrackerCategories[indexPath.section].trackers[indexPath.item]
        viewModel.setInitialStateButton(someDataForBinding: cell, trackerItem: trackerItem)
        
        cell.set(backgroundColor: trackerItem.color, emoji: trackerItem.emoji, name: trackerItem.name)
        return cell
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
        view.set(text: viewModel.visibleTrackerCategories[indexPath.section].header)
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
        if let indexPath = collectionView.indexPath(for: cell) {
            viewModel.plusButtonTapped(someDataForBinding: cell, indexPath: indexPath)
        }
    }
}

//MARK: - ModalChoiceVCDelegate

extension TrackersViewController: ModalChoiceVCDelegate {
    func showCreationTrackerVC(vc: UIViewController, state: ModalCreationTrackerVCMode) {
        vc.dismiss(animated: true)
        let vc = CreationTrackerViewController(mode: state)
        vc.delegate = viewModel
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

