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

class TRModalCreationTrackerVC: UIViewController {
    let nameTextField = UITextField()
    let tableView = UITableView()
    
    let hStackView = UIStackView()
    let createButton = UIButton()
    let cancelButton = UIButton()
    
    weak var delegate: TRModalCreationTrackerVCDelegate?
    
    var state: TRModalCreationTrackerVCState
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
    

    func configureVC(){
        view.backgroundColor = .systemBackground
        title = "Новая привычка"
        tableView.dataSource = self
        tableView.delegate = self
        
        [   nameTextField,
            tableView,
            hStackView
        ].forEach { subview in
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
         
    }
    
    func configureTextField(){
        nameTextField.backgroundColor = .trGray
        nameTextField.layer.cornerRadius = 16
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:16, height:nameTextField.bounds.height))
        nameTextField.leftViewMode = .always
        nameTextField.leftView = spacerView
        
        nameTextField.placeholder = "Введите название трекера"
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo:  view.topAnchor, constant: 87),
            nameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func configureTableView(){
        tableView.rowHeight = 75
        tableView.separatorColor = .systemBackground
        
        //tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func configureButtons(){
        
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .gray
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitle("Создать", for: .normal)
        createButton.tintColor = .white
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        hStackView.axis = .horizontal
        hStackView.spacing = 8
        hStackView.distribution = .fillEqually
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
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        let category = TrackerCategory(
            header: cell?.detailTextLabel?.text ?? "",
            trackers: [Tracker(
                id: UUID(),
                name: nameTextField.text ?? "",
                color: .orange,
                emoji: "🫥",
                schedule: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
            )])
        dismiss(animated: true)
        delegate?.createTracker(category: category)
        
    }
}

extension TRModalCreationTrackerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.backgroundColor = .trGray
        cell.layer.cornerRadius = 16
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Категория"
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.text = "Домашний уют"
        return cell
    }
    
}

extension TRModalCreationTrackerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}
