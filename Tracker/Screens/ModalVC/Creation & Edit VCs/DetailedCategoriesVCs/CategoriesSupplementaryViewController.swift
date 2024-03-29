//
//  CategoriesSupplementaryViewController.swift
//  Tracker
//
//  Created by Глеб Капустин on 21.02.2024.
//

import UIKit

enum CategoriesSupplementaryVCMode {
    case edit
    case create
}

final class CategoriesSupplementaryViewController: UIViewController {

    private let mode: CategoriesSupplementaryVCMode
    weak var delegate: CategoriesSupplementaryVCDelegate?
    
    private let createCategoryTextField: UITextField = {
        let createCategoryTextField = UITextField()
        createCategoryTextField.backgroundColor = .trGray
        createCategoryTextField.layer.cornerRadius = 16
        createCategoryTextField.clearButtonMode = .whileEditing
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:16, height:createCategoryTextField.bounds.height))
        createCategoryTextField.leftView = spacerView
        createCategoryTextField.leftViewMode = .always
        return createCategoryTextField
    }()
    
    private lazy var readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.backgroundColor = .gray
        readyButton.layer.cornerRadius = 16
        readyButton.setTitle(NSLocalizedString("ready", comment: ""), for: .normal)
        readyButton.isUserInteractionEnabled = false
        readyButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return readyButton
    }()
    
    var categoryForEdit: String
    
    init(mode: CategoriesSupplementaryVCMode, categoryForEdit: String = "") {
        self.mode = mode
        self.categoryForEdit = categoryForEdit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        configure()
        configureTextField()
        layoutUI()
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        let newCategoryStr = NSLocalizedString("newCategory", comment: "")
        let editingCategoryStr = NSLocalizedString("editingCategory", comment: "")
        title = mode == .create ? newCategoryStr : editingCategoryStr
        createCategoryTextField.delegate = self
    }
    
    private func configureTextField(){
        if mode == .create {
            createCategoryTextField.placeholder = NSLocalizedString("nameCategoryTextField.placeholder", comment: "")
        } else {
            createCategoryTextField.text = categoryForEdit
        }
    }
    
    private func layoutUI(){
        view.addSubviews(createCategoryTextField, readyButton)
        
        NSLayoutConstraint.activate([
            createCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createCategoryTextField.heightAnchor.constraint(equalToConstant: 75),
            createCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func dismissVC(){
        navigationController?.popViewController(animated: true)
        delegate?.dismissVC(mode: mode, oldHeaderCategory: categoryForEdit, newHeaderCategory: createCategoryTextField.text ?? "")
    }
}

extension CategoriesSupplementaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return createCategoryTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            text != "" {
            readyButton.isUserInteractionEnabled = true
            readyButton.backgroundColor = .trBlack
        } else {
            readyButton.isUserInteractionEnabled = false
            readyButton.backgroundColor = .gray
        }
    }
}
