//
//  TRScheduleVC.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit

protocol ScheduleVCDelegate: AnyObject {
    func passSchedule(schedule: [DaysOfWeek], secondaryString: String)
}

final class ScheduleViewController: UIViewController {

    private let tableView = UITableView()
    
    private let readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.backgroundColor = .trBlack
        readyButton.setTitle("Готово", for: .normal)
        readyButton.layer.cornerRadius = 16
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        return readyButton
    }()
    
    var schedule: [DaysOfWeek] = []
    
    weak var delegate: ScheduleVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureVC()
        configureTableView()
        configureButton()
    }

    private func configureVC() {
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        title = "Расписание"
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureTableView(){
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let topLineView = UIView()
        topLineView.backgroundColor = .systemBackground
        
        view.addSubviews(tableView, topLineView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 79),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            topLineView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 1),
            topLineView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            topLineView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            topLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func configureButton() {
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func readyButtonTapped(){
        var schedule: [DaysOfWeek] = []
        for i in 0...6 {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ScheduleTableViewCell
            if cell.switchIsOn(),
               let dayOfWeek = getDayOfWeek(i: i) {
                schedule.append(dayOfWeek)
            }
        }
        let secondaryString = DaysOfWeek.getShortenedDays(days: schedule)
        navigationController?.popViewController(animated: true)
        delegate?.passSchedule(schedule: schedule, secondaryString: secondaryString)
    }
    
    private func getDayOfWeek(i: Int) -> DaysOfWeek? {
        return switch i {
        case 0: DaysOfWeek.monday
        case 1: DaysOfWeek.tuesday
        case 2: DaysOfWeek.wednesday
        case 3: DaysOfWeek.thursday
        case 4: DaysOfWeek.friday
        case 5: DaysOfWeek.saturday
        case 6: DaysOfWeek.sunday
        default: nil
        }
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ScheduleTableViewCell()
        
        cell.backgroundColor = .trGray
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .gray
        
        setupCell(cell: &cell, indexPath: indexPath)
        
        return cell
    }
    
    private func setupCell(cell: inout ScheduleTableViewCell, indexPath: IndexPath){
        switch indexPath.row {
        case 0:
            if schedule.contains(.monday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Понедельник"
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case 1:
            if schedule.contains(.tuesday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Вторник"
        case 2:
            if schedule.contains(.wednesday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Среда"
        case 3:
            if schedule.contains(.thursday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Четверг"
        case 4:
            if schedule.contains(.friday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Пятница"
        case 5:
            if schedule.contains(.saturday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Суббота"
        case 6:
            if schedule.contains(.sunday) { cell.switchSetOn(true) }
            cell.textLabel?.text = "Воскресенье"
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: CGFloat.greatestFiniteMagnitude/2.0)
        default: break
        }
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
