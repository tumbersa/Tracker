//
//  DetailedFiltersViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 12.03.2024.
//

import UIKit

final class DetailedFiltersViewController: UIViewController {

    private let reuseCellID = "FilterCell"
    private let viewModel: FilterTrackersViewModelProtocol
    private let curFilter: Filters
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    init(viewModel: FilterTrackersViewModelProtocol, filter: Filters) {
        self.viewModel = viewModel
        self.curFilter = filter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureTableView()
    }
    
    private func configureVC(){
        view.backgroundColor = .systemBackground
        
        title = NSLocalizedString("Filters", comment: "")
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let topLineView = UIView()
        topLineView.backgroundColor = .systemBackground
        
        view.addSubviews(tableView, topLineView)
        
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 79),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300),
            
            topLineView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 1),
            topLineView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            topLineView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            topLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

extension DetailedFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseCellID)
        
        cell.backgroundColor = .trGray
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        if indexPath.row == curFilter.rawValue {
            cell.accessoryType = .checkmark
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("allTrackers", comment: "")
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case 1:
            cell.textLabel?.text = NSLocalizedString("trackersForToday", comment: "")
        case 2:
            cell.textLabel?.text = NSLocalizedString("finished", comment: "")
        case 3:
            cell.textLabel?.text = NSLocalizedString("unfinished", comment: "")
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: CGFloat.greatestFiniteMagnitude/2.0)
        default: break
        }
        
        return cell
    }
    
}

extension DetailedFiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.applyFilter(filterRawValue: indexPath.row)
        dismiss(animated: true)
    }
}
