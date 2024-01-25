//
//  TRModalCreationTracker.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit

enum ModalCreationTrackerVCState {
    case habit
    case irregularEvent
}

protocol ModalCreationTrackerVCDelegate: AnyObject {
    func createTracker(category: TrackerCategory)
}

final class CreationTrackerViewController: UIViewController {
    var (indexPathSection0, indexPathSection1): (IndexPath, IndexPath) = (IndexPath(), IndexPath())
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.backgroundColor = .trGray
        nameTextField.layer.cornerRadius = 16
        nameTextField.clearButtonMode = .whileEditing
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:16, height:nameTextField.bounds.height))
        nameTextField.leftViewMode = .always
        nameTextField.leftView = spacerView
        nameTextField.placeholder = "Введите название трекера"
        return nameTextField
    }()
    
    private let tableView = UITableView()
    
    private let hStackView: UIStackView = {
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.distribution = .fillEqually
        return hStackView
    }()
    
    private let createButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .gray
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.tintColor = .white
        return createButton
    }()
    
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        return cancelButton
    }()
    
    private let scrollView = UIScrollView()
    
    private lazy var iconPalleteCollectionView: UICollectionView = {
        let iconPalleteCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        iconPalleteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return iconPalleteCollectionView
    }()
    
    let containerView = UIView()
    
    
    private var state: ModalCreationTrackerVCState
    var schedule: [DaysOfWeek] = []
    weak var delegate: ModalCreationTrackerVCDelegate?
    
    init(state: ModalCreationTrackerVCState) {
        self.state = state
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureScrollView()
        
        configurePalleteCollectionView()
        configureTextField()
        configureTableView()
        configureButtons()
    }
    
  
    
    private func configureVC(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        title = state == .habit ? "Новая привычка" : "Новое нерегулярное событие"
    }
    
    private func configureScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        scrollView.addSubviews(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        let heightConstraint = containerView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250)
        heightConstraint.isActive = true
        
        containerView.addSubviews(nameTextField, tableView, hStackView)
    }
    
    private func configurePalleteCollectionView(){
        scrollView.addSubview(iconPalleteCollectionView)
        
        iconPalleteCollectionView.dataSource = self
        iconPalleteCollectionView.delegate = self
        
        iconPalleteCollectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSupplementaryView.reuseID)
        iconPalleteCollectionView.register(IconPaletteEmojiCollectionViewCell.self, forCellWithReuseIdentifier: IconPaletteEmojiCollectionViewCell.reuseID)
        iconPalleteCollectionView.register(IconPaletteColorCollectionViewCell.self, forCellWithReuseIdentifier: IconPaletteColorCollectionViewCell.reuseID)
        
        iconPalleteCollectionView.allowsMultipleSelection = true
        
        let leftPadding: CGFloat = 18
        let rightPadding: CGFloat = 19
        let minimumItemSpacing: CGFloat = 5
        let availableWidth: CGFloat = view.frame.width - leftPadding - rightPadding - minimumItemSpacing * 5
        let itemWidth = availableWidth / 6
        
        let collectionViewHeight = itemWidth * 6 + 2 * 34 + 4 * 24 + 16
        NSLayoutConstraint.activate([
            iconPalleteCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            iconPalleteCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconPalleteCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            iconPalleteCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight)
        ])
    }
    
    private func configureTextField(){
        nameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo:  containerView.topAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        let height: CGFloat
        if state == .irregularEvent {
            tableView.separatorColor = .systemBackground
            height = 75
        } else {
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            height = 150
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func configureButtons(){
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        hStackView.addArrangedSubview(cancelButton)
        hStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            hStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            hStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            hStackView.topAnchor.constraint(equalTo: iconPalleteCollectionView.bottomAnchor, constant: 16),
            hStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped(){
        guard textFielsIsNotEmpty() else { return }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if state == .irregularEvent {
            schedule = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        }
        
        guard let selectedEmoji, let selectedColor else { return }
        
        let category = TrackerCategory(
            header: cell?.detailTextLabel?.text ?? "",
            trackers: [Tracker(
                id: UUID(),
                name: nameTextField.text ?? "",
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: schedule
            )])
        dismiss(animated: true)
        delegate?.createTracker(category: category)
        
    }
    
    private func textFielsIsNotEmpty() -> Bool{
        guard var flag = nameTextField.text?.isEmpty else { return false }
        flag.toggle()
        if state == .habit {
            if let cellFlag = tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text?.isEmpty {
                flag = flag && !cellFlag
            } else { flag = false}
        }
        if let cellFlag = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text?.isEmpty{
            flag = flag && !cellFlag
        } else { flag = false }
        
        if selectedEmoji == nil || selectedColor == nil { flag = false }
        
        return flag
    }
}

extension CreationTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state == .irregularEvent ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.backgroundColor = .trGray
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        if state == .irregularEvent {
            cell.layer.cornerRadius = 16
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = "Домашний уют"
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Категория"
                cell.detailTextLabel?.text = "Домашний уют"
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                cell.textLabel?.text = "Расписание"
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: CGFloat.greatestFiniteMagnitude/2.0)
            }
        }
        return cell
    }
    
}

extension CreationTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.schedule = self.schedule
            vc.delegate = self
            present(UINavigationController(rootViewController: vc) ,animated: true)
        } else {
            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        }
    }
}

extension CreationTrackerViewController: ScheduleVCDelegate {
    func passSchedule(schedule: [DaysOfWeek], secondaryString: String) {
        self.schedule = schedule
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        cell?.detailTextLabel?.text = secondaryString
        tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: true)
    }
}

extension CreationTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension CreationTrackerViewController: UICollectionViewDataSource {
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

extension CreationTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftPadding: CGFloat = 18
        let rightPadding: CGFloat = 19
        let minimumItemSpacing: CGFloat = 5
        let availableWidth: CGFloat = view.frame.width - leftPadding - rightPadding - minimumItemSpacing * 5
        let itemWidth = availableWidth / 6
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSupplementaryView.reuseID, for: indexPath) as! TrackerSupplementaryView
        
        let headerString = indexPath.section == 0 ? "Emoji" : "Цвет"
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
        print(indexPath)

        if indexPath.section == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IconPaletteEmojiCollectionViewCell else {
                return
            }
            selectedEmoji = cell.get()
            cell.contentView.backgroundColor = .trLightGray
            
            
            if let oldCell = collectionView.cellForItem(at: indexPathSection0) as? IconPaletteEmojiCollectionViewCell {
                oldCell.contentView.backgroundColor = .systemBackground
            }
            indexPathSection0 = indexPath
            
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IconPaletteColorCollectionViewCell else {
                return
            }
            let color = cell.get()
            selectedColor = color
            cell.contentView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
            
            
            if let oldCell = collectionView.cellForItem(at: indexPathSection1) as? IconPaletteColorCollectionViewCell {
                oldCell.contentView.layer.borderColor = UIColor.systemBackground.cgColor
            }
            indexPathSection1 = indexPath
        }
        
        
        print(selectedEmoji, " ", selectedColor)
    }
    
}

