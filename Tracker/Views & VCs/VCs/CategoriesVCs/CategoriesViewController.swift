//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 21.02.2024.
//

import UIKit

protocol CategoriesSupplementaryVCDelegate: AnyObject {
    func dismissVC(mode: CategoriesSupplementaryVCMode, categoryString: String)
}
final class CategoriesViewController: UIViewController {
    
    private let reuseCellID = "CategoriesCell"
    private var viewModel = CategoriesViewModel()
    
    private lazy var tableView = UITableView()
    private lazy var emptyStateImageView: UIImageView = {
        let emptyStateImageView = UIImageView()
        emptyStateImageView.image = UIImage(resource: .trEmptyStateTrackers)
        return emptyStateImageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.numberOfLines = 2
        emptyStateLabel.text = "Привычки и события можно \nобъединить по смыслу"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = UIButton()
        addCategoryButton.backgroundColor = .trBlack
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return addCategoryButton
    }()
    
    weak var delegate: CategoriesViewControllerDelegate?
    
    var categoryString: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        configure()
        layoutUI()
        configureTableView()
    }
    
  
    
    private func configure() {
        
        viewModel.categoriesBinding = { [weak self] update in
            guard let self else { return }
           
            let countCategories = viewModel.categories.count
            let flagToReloadBegin = update.insertedIndexes.first ?? -1 == 0
            let flagToReloadEnd = update.insertedIndexes.first ?? -1 == countCategories - 1
            
            let insertedIndexPaths = update.insertedIndexes.map{IndexPath(row: $0, section: 0)}
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }
                tableView.insertRows(at: insertedIndexPaths, with: .automatic)
                tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
                tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
                
                if countCategories != 1 {
                    if flagToReloadBegin {
                        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                    if flagToReloadEnd {
                        tableView.reloadRows(at: [IndexPath(row: countCategories - 2, section: 0)], with: .automatic)
                    }
                }
            }
            configureEmptyState(isEmpty: viewModel.categories.isEmpty)
        }
        
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        title = "Категория"
        
    }
    
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubviews(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 79),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
        ])
    }
    
    private func layoutUI(){
        view.addSubviews(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureEmptyState(isEmpty: Bool) {
        if isEmpty {
            view.addSubviews(emptyStateImageView, emptyStateLabel)
            
            NSLayoutConstraint.activate([
                emptyStateLabel.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -232),
                emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                emptyStateLabel.heightAnchor.constraint(equalToConstant: 36),
                
                emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyStateImageView.bottomAnchor.constraint(equalTo: emptyStateLabel.topAnchor, constant: -8),
                emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
                emptyStateImageView.widthAnchor.constraint(equalToConstant: 80)
            ])
            
        } else {
            emptyStateLabel.removeFromSuperview()
            emptyStateImageView.removeFromSuperview()
        }
    }
    
    @objc private func addCategoryButtonTapped(){
        let vc = CategoriesSupplementaryViewController(mode: .create)
        vc.delegate = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseCellID)
        cell.accessoryType = .none
        cell.backgroundColor = .trGray
        cell.layer.masksToBounds = true
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: CGFloat.greatestFiniteMagnitude/2.0)
        }
        let text = viewModel.categories[indexPath.row]
        cell.textLabel?.text = text
        if text == categoryString { cell.accessoryType = .checkmark }
        return cell
    }
    
    
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType =  .checkmark
        delegate?.getNewCategory(categoryString: cell?.textLabel?.text ?? "")
        navigationController?.popViewController(animated: true)
    }
}
