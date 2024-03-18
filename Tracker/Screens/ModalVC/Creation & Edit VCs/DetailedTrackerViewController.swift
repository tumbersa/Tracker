//
//  TRModalCreationTracker.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit
import SnapKit

enum ModalCreationTrackerVCMode {
    case habit
    case irregularEvent
    case edit
}

protocol ModalCreationTrackerVCDelegate: AnyObject {
    func createTracker(category: TrackerCategory)
    func updateTracker(category: TrackerCategory)
}

protocol CategoriesViewControllerDelegate: AnyObject {
    func getNewCategory(categoryString: String)
}

final class DetailedTrackerViewController: UIViewController {
    private var (indexPathSection0, indexPathSection1): (IndexPath, IndexPath) = (IndexPath(), IndexPath())
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private lazy var nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.backgroundColor = .trGray
        nameTextField.layer.cornerRadius = 16
        nameTextField.clearButtonMode = .whileEditing
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:16, height:nameTextField.bounds.height))
        nameTextField.leftViewMode = .always
        nameTextField.leftView = spacerView
        return nameTextField
    }()
    
    private lazy var tableView = UITableView()
    
    private lazy var hStackView: UIStackView = {
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.distribution = .fillEqually
        return hStackView
    }()
    
    private lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.layer.cornerRadius = 16
        saveButton.backgroundColor = .gray
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.tintColor = .white
        return saveButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        return cancelButton
    }()
    
    private lazy var scrollView = UIScrollView()
    private lazy var iconPalleteCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var containerView = UIView()
    
    //edit mode
    private lazy var countDaysLabel: UILabel = {
        let countDaysLabel = UILabel()
        countDaysLabel.font = .systemFont(ofSize: 32, weight: .bold)
        countDaysLabel.textAlignment = .center
        return countDaysLabel
    }()
    
    private lazy var trackerForEdit: Tracker = Tracker(id: UUID(), name: "", color: .black, emoji: "", schedule: [])
    private lazy var headerCategoryForEdit: String = ""
    private lazy var recordCount: Int = 0
    //
    
    private var mode: ModalCreationTrackerVCMode
    
    var schedule: [DaysOfWeek] = []
    var categoryString: String = ""
    weak var delegate: ModalCreationTrackerVCDelegate?
    
    
    init(mode: ModalCreationTrackerVCMode) {
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(trackerForEdit: Tracker, headerCategoryForEdit: String, recordCount: Int) {
        self.init(mode: .edit)
        self.trackerForEdit = trackerForEdit
        self.headerCategoryForEdit = headerCategoryForEdit
        self.recordCount = recordCount
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        configureVC()
        configureScrollView()
        
        configurePalleteCollectionView()
        configureTableView()
        configureButtons()
        if mode == .edit { configureEditMode() }
        configureTextField()
        changeSaveButtonColor()
    }
    
    
    private func configureVC(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        let newHabitStr = NSLocalizedString("newHabit", comment: "")
        let newIrregularEventStr = NSLocalizedString("newIrregularEvent", comment: "")
        let editStr = "Редактирование привычки"
        title = mode == .habit ? newHabitStr : mode == .irregularEvent ? newIrregularEventStr : editStr
    }
    
    private func configureScrollView(){
        view.addSubviews(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubviews(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.equalTo(scrollView.frameLayoutGuide.snp.height).priority(250)
        }
        
        containerView.addSubviews(nameTextField, tableView, hStackView)
    }
    
    private func configurePalleteCollectionView(){
        scrollView.addSubviews(iconPalleteCollectionView)
        
        iconPalleteCollectionView.dataSource = self
        iconPalleteCollectionView.delegate = self
        iconPalleteCollectionView.allowsMultipleSelection = true
        
        iconPalleteCollectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseID)
        iconPalleteCollectionView.register(IconPaletteEmojiCollectionViewCell.self, forCellWithReuseIdentifier: IconPaletteEmojiCollectionViewCell.reuseID)
        iconPalleteCollectionView.register(IconPaletteColorCollectionViewCell.self, forCellWithReuseIdentifier: IconPaletteColorCollectionViewCell.reuseID)
    
        let collectionViewHeight = itemWidth() * 6 + 2 * 34 + 4 * 24 + 16
        
        iconPalleteCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(16)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
            make.height.equalTo(collectionViewHeight)
        }
    }
    
    private func itemWidth() -> CGFloat {
        let leftPadding: CGFloat = 18
        let rightPadding: CGFloat = 19
        let minimumItemSpacing: CGFloat = 5
        let availableWidth: CGFloat = view.frame.width - leftPadding - rightPadding - minimumItemSpacing * 5
        let itemWidth = availableWidth / 6
        return itemWidth
    }
    
    private func configureTextField(){
        if mode == .edit {
            nameTextField.text = trackerForEdit.name
        } else {
            nameTextField.placeholder = NSLocalizedString("nameTrackerTextField.placeholder", comment: "")
        }
        
        nameTextField.delegate = self
        
        nameTextField.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            if mode != .edit {
                make.top.equalTo(containerView.snp.top).offset(24)
            } else {
                make.top.equalTo(countDaysLabel.snp.bottom).offset(40)
            }
            make.height.equalTo(75)
        }
        
    }
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        let height: CGFloat
        if mode == .irregularEvent {
            tableView.separatorColor = .systemBackground
            height = 75
        } else {
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            height = 150
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.leading).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.height.equalTo(height)
        }
    }
    
    private func configureButtons(){
        let titleSaveButton = mode == .edit ? "Сохранить" : NSLocalizedString("create", comment: "")
        saveButton.setTitle(titleSaveButton, for: .normal)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        if mode == .edit {
            saveButton.addTarget(self, action: #selector(saveButtonTappedForUpdate), for: .touchUpInside)
        } else {
            saveButton.addTarget(self, action: #selector(saveButtonTappedForCreate), for: .touchUpInside)
        }
        
        hStackView.addArrangedSubview(cancelButton)
        hStackView.addArrangedSubview(saveButton)
        
        hStackView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.bottom)
            make.leading.equalTo(containerView.snp.leading).offset(20)
            make.trailing.equalTo(containerView.snp.trailing).offset(-20)
            make.top.equalTo(iconPalleteCollectionView.snp.bottom).offset(16)
            make.height.equalTo(60)
        }
        
    }
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTappedForCreate(){
        if let curCategory = getCurrentCategory() {
            dismiss(animated: true)
            delegate?.createTracker(category: curCategory)
        }
    }
    
    @objc private func saveButtonTappedForUpdate() {
        if let curCategory = getCurrentCategory() {
            dismiss(animated: true)
            delegate?.updateTracker(category: curCategory)
        }
    }
    
    private func getCurrentCategory() -> TrackerCategory? {
        guard fielsIsNotEmpty() else { return nil}
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if mode == .irregularEvent {
            schedule = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        }
        
        guard let selectedEmoji, let selectedColor else { return nil}
        
        let category = TrackerCategory(
            header: cell?.detailTextLabel?.text ?? "",
            trackers: [Tracker(
                id: mode == .edit ? trackerForEdit.id : UUID(),
                name: nameTextField.text ?? "",
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: schedule
            )])
        
        return category
    }
    
    private func fielsIsNotEmpty() -> Bool {
        guard var flag = nameTextField.text?.isEmpty else { return false }
        flag.toggle()
        if mode == .habit {
            if let cellFlag = tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text?.isEmpty {
                flag = flag && !cellFlag
            } else {
                flag = false
            }
        }
        if let cellFlag = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text?.isEmpty {
            flag = flag && !cellFlag
        } else {
            flag = false
        }
        
        if selectedEmoji == nil || selectedColor == nil {
            flag = false
        }
        
        return flag
    }
    
    private func changeSaveButtonColor(){
        saveButton.backgroundColor = fielsIsNotEmpty() ? .black : .gray
    }
    
    private func configureEditMode() {
        countDaysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days"),
            recordCount)
        
        containerView.addSubviews(countDaysLabel)
        countDaysLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.top.equalTo(containerView.snp.top).offset(24)
        }
        
        view.layoutIfNeeded()
        
        for item in 0...iconPalleteCollectionView.numberOfItems(inSection: 0)-1 {
            let indexPath = IndexPath(item: item, section: 0)
            if let cell = iconPalleteCollectionView.cellForItem(at: indexPath) as? IconPaletteEmojiCollectionViewCell,
               cell.getEmoji() == trackerForEdit.emoji {
                iconPalleteCollectionView.delegate?.collectionView?(iconPalleteCollectionView, didSelectItemAt: indexPath)
            }
        }
        
        for item in 0...iconPalleteCollectionView.numberOfItems(inSection: 1)-1 {
            let indexPath = IndexPath(item: item, section: 1)
            if let cell = iconPalleteCollectionView.cellForItem(at: indexPath) as? IconPaletteColorCollectionViewCell,
               UIColorMarshalling.UIColorToHex(color:cell.getColor()) == UIColorMarshalling.UIColorToHex(color: trackerForEdit.color) {
                iconPalleteCollectionView.delegate?.collectionView?(iconPalleteCollectionView, didSelectItemAt: indexPath)
            }
        }
    }
}


//MARK: - UITableViewDataSource
extension DetailedTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mode == .irregularEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.backgroundColor = .trGray
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        let categoryStr = NSLocalizedString("category", comment: "")
        if mode == .irregularEvent {
            cell.layer.cornerRadius = 16
            cell.textLabel?.text = categoryStr
        } else {
            if indexPath.row == 0 {
                if mode == .edit {
                    cell.detailTextLabel?.text = headerCategoryForEdit
                    self.categoryString = headerCategoryForEdit
                }
                
                cell.textLabel?.text = categoryStr
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                if mode == .edit {
                    cell.detailTextLabel?.text = DaysOfWeek.getShortenedDays(days: trackerForEdit.schedule)
                    schedule = trackerForEdit.schedule
                }
                
                cell.textLabel?.text = NSLocalizedString("schedule", comment: "")
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: CGFloat.greatestFiniteMagnitude/2.0)
            }
        }
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension DetailedTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.schedule = self.schedule
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CategoriesViewController(viewModel: CategoriesViewModel())
            vc.delegate = self
            vc.categoryString = self.categoryString
            navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        }
    }
}

//MARK: - ScheduleVCDelegate
extension DetailedTrackerViewController: ScheduleVCDelegate {
    func passSchedule(schedule: [DaysOfWeek], secondaryString: String) {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        cell?.detailTextLabel?.text = secondaryString
        self.schedule = schedule
        tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: true)
        changeSaveButtonColor()
    }
}

//MARK: - UITextFieldDelegate

extension DetailedTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeSaveButtonColor()
        return textField.resignFirstResponder()
    }
    //если клавиатура была убрана без клавиши return 
    func textFieldDidEndEditing(_ textField: UITextField) {
        changeSaveButtonColor()
    }
}

//MARK: - UICollectionViewDataSource
extension DetailedTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? IconPaletteResources.emojis.count : IconPaletteResources.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconPaletteEmojiCollectionViewCell.reuseID, for: indexPath) as? IconPaletteEmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.set(emoji: IconPaletteResources.emojis[indexPath.row])
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconPaletteColorCollectionViewCell.reuseID, for: indexPath) as? IconPaletteColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.set(color: IconPaletteResources.colors[indexPath.row])
            
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension DetailedTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = itemWidth()
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseID, for: indexPath) as! TrackerSupplementaryView
        
        let colorStr = NSLocalizedString("color", comment: "")
        let headerString = indexPath.section == 0 ? "Emoji" : colorStr
        view.set(text:  headerString, isIcon: true)
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
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
             let cell = collectionView.cellForItem(at: indexPath) as! IconPaletteEmojiCollectionViewCell
            
            selectedEmoji = cell.getEmoji()
            cell.contentView.backgroundColor = .trLightGray
            
            
            if let oldCell = collectionView.cellForItem(at: indexPathSection0) as? IconPaletteEmojiCollectionViewCell,
               oldCell.getEmoji() != cell.getEmoji(){
                oldCell.contentView.backgroundColor = .systemBackground
                iconPalleteCollectionView.deselectItem(at: indexPathSection0, animated: true)
            }
            indexPathSection0 = indexPath
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! IconPaletteColorCollectionViewCell
            
            let color = cell.getColor()
            selectedColor = color
            cell.contentView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
            
            if let oldCell = collectionView.cellForItem(at: indexPathSection1) as? IconPaletteColorCollectionViewCell,
               oldCell.getColor() != cell.getColor() {
                oldCell.contentView.layer.borderColor = UIColor.systemBackground.cgColor
                iconPalleteCollectionView.deselectItem(at: indexPathSection1, animated: true)
            }
            indexPathSection1 = indexPath
        }
        
        changeSaveButtonColor()
    }
    
}

extension DetailedTrackerViewController: CategoriesViewControllerDelegate {
    func getNewCategory(categoryString: String) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.detailTextLabel?.text = categoryString
        self.categoryString = categoryString
    }
}
