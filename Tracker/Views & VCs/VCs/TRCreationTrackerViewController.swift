//
//  TRModalCreationTracker.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit

enum TRModalCreationTrackerVCState {
    case habit
    case irregularEvent
}

protocol TRModalCreationTrackerVCDelegate: AnyObject {
    func createTracker(category: TrackerCategory)
}

final class TRCreationTrackerViewController: UIViewController {
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
    
    private var state: TRModalCreationTrackerVCState
    var schedule: [DaysOfWeek] = []
    weak var delegate: TRModalCreationTrackerVCDelegate?
    
    init(state: TRModalCreationTrackerVCState) {
        self.state = state
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureTextField()
        configureTableView()
        configureButtons()
    }
    
    private func configureVC(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        title = state == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubviews(nameTextField, tableView, hStackView)
    }
    
    private func configureTextField(){
        nameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo:  view.topAnchor, constant: 87),
            nameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func configureTableView(){
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func configureButtons(){
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        hStackView.addArrangedSubview(cancelButton)
        hStackView.addArrangedSubview(createButton)
        
        NSLayoutConstraint.activate([
            hStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
        
        let category = TrackerCategory(
            header: cell?.detailTextLabel?.text ?? "",
            trackers: [Tracker(
                id: UUID(),
                name: nameTextField.text ?? "",
                color: .orange,
                emoji: "🫥",
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
        
        return flag
    }
}

extension TRCreationTrackerViewController: UITableViewDataSource {
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

extension TRCreationTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = TRScheduleViewController()
            vc.schedule = self.schedule
            vc.delegate = self
            present(UINavigationController(rootViewController: vc) ,animated: true)
        } else {
            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
        }
    }
}

extension TRCreationTrackerViewController: TRScheduleVCDelegate {
    func passSchedule(schedule: [DaysOfWeek], secondaryString: String) {
        self.schedule = schedule
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        cell?.detailTextLabel?.text = secondaryString
        tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: true)
    }
}

extension TRCreationTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
