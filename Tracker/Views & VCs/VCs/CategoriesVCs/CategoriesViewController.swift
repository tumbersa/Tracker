//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 21.02.2024.
//

import UIKit


final class CategoriesViewController: UIViewController {
    
    private let reuseCellID = "CategoriesCell"
    private var viewModel: CategoriesViewModelProtocol
    
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
    
    init(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        configure()
        layoutUI()
        configureTableView()
        configureEmptyState(isEmpty: viewModel.categories.isEmpty)
    }
    
  
    
    private func configure() {
        
        viewModel.insertOrEditCategoryBinding = { [weak self] update in
            guard let self else { return }
           
            ///флаги для обработки ячеек, у которых верхние или нижние края закруглены
            let countCategories = viewModel.categories.count
            var flagToReloadBegin = update.insertedIndexes.first ?? -1 == 0
            var flagToReloadEnd = update.insertedIndexes.first ?? -1 == countCategories - 1
            var flagToReloadMovedBeginOrEnd = false
            
            let insertedIndexPaths = update.insertedIndexes.map{IndexPath(row: $0, section: 0)}
            
            //Замена текста
            if let movedNewIndex = update.movedIndexes.first?.newIndex,
                let movedOldIndex = update.movedIndexes.first?.oldIndex {
                let cell = tableView.cellForRow(at: IndexPath(row: movedOldIndex, section: 0))
                cell?.textLabel?.text = viewModel.categories[movedNewIndex]
                
                flagToReloadBegin = flagToReloadBegin || movedNewIndex == 0
                flagToReloadEnd = flagToReloadEnd || movedNewIndex == countCategories - 1
                
                flagToReloadMovedBeginOrEnd = movedOldIndex == 0 || movedOldIndex == countCategories - 1
            }
            
            //Главная часть изменения таблицы
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }
                tableView.insertRows(at: insertedIndexPaths, with: .automatic)
                
                for move in update.movedIndexes {
                    print(move.oldIndex, move.newIndex)
                    tableView.moveRow (
                        at: IndexPath(row: move.oldIndex, section: 0),
                        to: IndexPath(row: move.newIndex, section: 0)
                    )
                }
            }
            
            ///Batch Updates для обработки ячеек, у которых верхние или нижние края закруглены
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }
                if countCategories != 1 {
                    if flagToReloadBegin {
                        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                    if flagToReloadEnd {
                        tableView.reloadRows(at: [IndexPath(row: countCategories - 2, section: 0)], with: .automatic)
                    }
                    
                    if flagToReloadMovedBeginOrEnd,
                       let newIndex = update.movedIndexes.first?.newIndex {
                        tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                    }
                    
                }
            }
            configureEmptyState(isEmpty: viewModel.categories.isEmpty)
        }
        
        viewModel.deleteCategoryBinding = {[weak self] update in
            guard let self else { return }
            
            ///флаги для обработки ячеек, у которых верхние или нижние края закруглены
            let countCategories = viewModel.categories.count
            let flagToReloadDeletedBegin = update.deletedIndexes.first ?? -1 == 0
            let flagToReloadDeletedEnd = update.deletedIndexes.first ?? -1 == countCategories
            
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            
            //Главная часть изменения таблицы
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }
                tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
            }
            
            ///Batch Updates для обработки ячеек, у которых верхние или нижние края закруглены
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }
                
                if countCategories != 0 {
                    if flagToReloadDeletedBegin {
                        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                    
                    if flagToReloadDeletedEnd {
                        tableView.reloadRows(at: [IndexPath(row: countCategories - 1, section: 0)], with: .automatic)
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

//MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let redColorAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red]
        let attributedTitle = NSAttributedString(string: "Удалить", attributes: redColorAttribute)
        
        let deleteAction =  UIAction(title: "Удалить") {[weak self] _ in
            guard let self else { return }
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            let alert = UIAlertController(title: nil, message: "Эта категория точно не нужна? Все её трекеры удалятся", preferredStyle: .actionSheet)
            
            let deleteAlertAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                guard let self else { return }
                viewModel.deleteTrackerCategory(headerTrackerCategory: cell?.textLabel?.text ?? "")
            }
            
            let cancelAlertAction = UIAlertAction(title: "Отменить", style: .cancel) {_ in
                cell?.accessoryType = .none
            }
            
            alert.addAction(deleteAlertAction)
            alert.addAction(cancelAlertAction)
            present(alert, animated: true)
        }
        deleteAction.setValue(attributedTitle, forKey: "attributedTitle")
        
        let editAction =  UIAction(title: "Редактировать") {[weak self] _ in
            guard let self else { return }
            let cell = tableView.cellForRow(at: indexPath)
            
            let vc = CategoriesSupplementaryViewController(mode: .edit,  categoryForEdit: cell?.textLabel?.text ?? "")
            vc.delegate = viewModel
            navigationController?.pushViewController(vc, animated: true)
        }
        return UIContextMenuConfiguration(actionProvider:  { actions in
            UIMenu(children: [editAction,deleteAction])
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType =  .checkmark
        delegate?.getNewCategory(categoryString: cell?.textLabel?.text ?? "")
        navigationController?.popViewController(animated: true)
    }
}
