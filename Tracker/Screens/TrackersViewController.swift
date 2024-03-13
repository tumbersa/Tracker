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
        emptyStateLabel.text = NSLocalizedString("emptyState.title", comment: "")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    private lazy var datePicker: TRDatePicker = TRDatePicker()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let filtersButton = UIButton()
        filtersButton.backgroundColor = .trBlue
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filtersButton.layer.cornerRadius = 16
        let titleStr = NSLocalizedString("filters", comment: "")
        filtersButton.setTitle(titleStr, for: .normal)
        return filtersButton
    }()

    private let analyticsService = AnalyticsService()
    
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
        configureFiltersButton()
        configureEmptyState(isEmpty: viewModel.visibleTrackerCategories.isEmpty)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: AnalyticsEvents.open, params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: AnalyticsEvents.close, params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main])

    }
    
    @objc private func actionAddBarItem(){
        let vcToShow = ModalChoiceViewController()
        vcToShow.delegate = self
        present(UINavigationController(rootViewController: vcToShow), animated: true)
        analyticsService.report(event: AnalyticsEvents.click,
                                params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main,
                                         AnalyticsKeysForParams.item : AnalyticsItems.addTrack])
    }
    
    private func configureVC(){
        //MARK: - clousers viewModel
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
            
            cell.countDaysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("numberOfDays", comment: "Number of days"),
                countDayRecord)
        }
       
        viewModel.pinBinding = {[weak self] indexPath in
            guard let self else { return }
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                cell.isPinned.toggle()
            }
        }
        
        
        view.backgroundColor = .systemBackground
        dateFormatter.dateFormat = "dd.MM.yy"
    
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(actionAddBarItem))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.set(text: dateFormatter.string(from: currentDate))
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
        datePicker.set(text: formattedDate)
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self else { return }
            self.filtersButton.layer.opacity = 1
        }
        
        if viewModel.curFilter == .byDays {
            viewModel.updateTrackers()
        }
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
    
    private func configureFiltersButton() {
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        
        view.addSubviews(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func filtersButtonTapped(){
        guard let viewModelForVC = viewModel as? FilterTrackersViewModelProtocol else { return }
        let vc = DetailedFiltersViewController(viewModel: viewModelForVC, filter: viewModel.curFilter)
        present(UINavigationController(rootViewController: vc), animated: true)
        
        analyticsService.report(event: AnalyticsEvents.click,
                                params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main,
                                         AnalyticsKeysForParams.item : AnalyticsItems.filter])
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
        let category = viewModel.visibleTrackerCategories[indexPath.section]
        let trackerItem = category.trackers[indexPath.item]
        viewModel.setInitialStateButton(someDataForBinding: cell, trackerItem: trackerItem)
        
        var isPinned = false
        if category.header == "Закрепленные" {
            isPinned = true
        }
        cell.set(
            backgroundColor: trackerItem.color,
            emoji: trackerItem.emoji,
            name: trackerItem.name,
            isPinned: isPinned)
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
        var header = viewModel.visibleTrackerCategories[indexPath.section].header
        if header == "Закрепленные" {
            header = NSLocalizedString("pinned", comment: "")
        }
        view.set(text: header)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
            return UITargetedPreview(view: cell.containerView)
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let indexPath = indexPaths.first else { return nil }
        let category = viewModel.visibleTrackerCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let id = tracker.id
        
        var pinAction: UIAction = UIAction(handler: {_ in })
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
            if !cell.isPinned {
                pinAction = UIAction(title: NSLocalizedString("pin", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    viewModel.pinTracker(trackerID: id, nameCategory: category.header, indexPath: indexPath)
                }
            } else {
                
                pinAction = UIAction(title: NSLocalizedString("unpin", comment: "")) { [weak self] _ in
                    guard let self else { return }
                    viewModel.unpinTracker(trackerID: id, indexPath: indexPath)
                }
            }
        }
        
        let editStr = NSLocalizedString("edit", comment: "")
        let editAction = UIAction(title: editStr) { [weak self] _ in
            guard let self else { return }
            let vc = DetailedTrackerViewController(
                trackerForEdit: tracker,
                headerCategoryForEdit: category.header,
                recordCount: viewModel.getRecordCount(id: tracker.id))
            
            vc.delegate = viewModel
            present(UINavigationController(rootViewController: vc), animated: true)
            
            analyticsService.report(event: AnalyticsEvents.click,
                                    params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main,
                                             AnalyticsKeysForParams.item : AnalyticsItems.edit])
        }
        
        let deleteStr = NSLocalizedString("delete", comment: "")
        let deleteAction = UIAction(title: deleteStr) { [weak self] _ in
            guard let self else { return }
            let alert = UIAlertController(
                title: nil,
                message: NSLocalizedString("deleteTracker.message", comment: ""),
                preferredStyle: .actionSheet)
            
            let deleteAlertAction = UIAlertAction(title: deleteStr, style: .destructive) { [weak self] _ in
                guard let self else { return }
                viewModel.deleteTracker(trackerID: id)
            }
            
            let cancelAlertAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) {_ in
            }
            
            alert.addAction(deleteAlertAction)
            alert.addAction(cancelAlertAction)
            present(alert, animated: true)
            
            analyticsService.report(event: AnalyticsEvents.click,
                                    params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main,
                                             AnalyticsKeysForParams.item : AnalyticsItems.delete])
        }
        
        let redColorAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red]
        let attributedTitle = NSAttributedString(string: deleteStr, attributes: redColorAttribute)
        
        deleteAction.setValue(attributedTitle, forKey: "attributedTitle")
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [pinAction, editAction, deleteAction])
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
                
        if offsetY > contentHeight - height {
            UIView.animate(withDuration: 0.15) { [weak self] in
                guard let self else { return }
                self.filtersButton.layer.opacity = 0
            }
        } else {
            UIView.animate(withDuration: 0.15) { [weak self] in
                guard let self else { return }
                self.filtersButton.layer.opacity = 1
            }
        }
    }
}

//MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func plusButtonTapped(cell: TrackerCollectionViewCell) {
        guard Date() >= currentDate else { return }
        if let indexPath = collectionView.indexPath(for: cell) {
            viewModel.plusButtonTapped(someDataForBinding: cell, indexPath: indexPath)
        }
        
        analyticsService.report(event: AnalyticsEvents.click,
                                params: [AnalyticsKeysForParams.screen : AnalyticsScreens.main,
                                         AnalyticsKeysForParams.item : AnalyticsItems.track])
    }
}

//MARK: - ModalChoiceVCDelegate

extension TrackersViewController: ModalChoiceVCDelegate {
    func showCreationTrackerVC(vc: UIViewController, state: ModalCreationTrackerVCMode) {
        vc.dismiss(animated: true)
        let vc = DetailedTrackerViewController(mode: state)
        vc.delegate = viewModel
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

