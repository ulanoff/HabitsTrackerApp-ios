//
//  CategoryNameViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 06.11.2023.
//

import UIKit

protocol CategoryNameViewControllerDelegate: AnyObject {
    func newCategoryViewController(
        _ viewController: CategoryNameViewController,
        didSetupNewCategory trackerCategory: TrackerCategory
    )
    func newCategoryViewController(
        _ viewController: CategoryNameViewController,
        didEditedCategory trackerCategory: TrackerCategory,
        to newTrackerCategory: TrackerCategory
    )
}

enum CategoryNameViewControllerType {
    case creating
    case editing
}

final class CategoryNameViewController: UIViewController {
    // MARK: - Properties
    private var oldCategoryName = ""
    private var categoryName = ""
    private let controllerType: CategoryNameViewControllerType
    private var isValidationPassed = false
    
    weak var delegate: CategoryNameViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var textField: TextField = {
        let textField = TextField()
        textField.delegate = self
        textField.placeholder = "Введите название категории"
        textField.clearButtonMode = .whileEditing
        textField.text = oldCategoryName
        return textField
    }()
    
    private lazy var continueButton: Button = {
        let button = Button()
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(type: CategoryNameViewControllerType, categoryName: String?) {
        self.controllerType = type
        super.init(nibName: nil, bundle: nil)
        if let categoryName {
            self.oldCategoryName = categoryName
            self.categoryName = categoryName
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContinueButtonState()
        addMainViewTapGesture()
    }
    
    // MARK: - Event Handlers
    @objc private func didTapContinueButton() {
        let trackerCategory = TrackerCategory(name: categoryName, trackers: [])
        let oldTrackerCategory = TrackerCategory(name: oldCategoryName, trackers: [])
        switch controllerType {
        case .creating:
            delegate?.newCategoryViewController(self, didSetupNewCategory: trackerCategory)
        case .editing:
            delegate?.newCategoryViewController(self, didEditedCategory: oldTrackerCategory, to: trackerCategory)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Public Methods
}

// MARK: - Private Methods
private extension CategoryNameViewController {
    func updateContinueButtonState() {
        if isValidationPassed
        {
            continueButton.isUserInteractionEnabled = true
            continueButton.backgroundColor = .ypBlack
        } else {
            continueButton.isUserInteractionEnabled = false
            continueButton.backgroundColor = .ypGray
        }
    }
    
    func addMainViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(textField)
        view.addSubview(continueButton)
        
        // MARK: - Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            
            continueButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        // MARK: - Views Configuring
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .ypWhite
        switch controllerType {
        case .creating:
            title = "Новая категория"
        case .editing:
            title = "Редактирование категории"
        }
    }
}

// MARK: - Protocols Conforming
extension CategoryNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 24
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty || updatedText.isBlank {
            isValidationPassed = false
            updateContinueButtonState()
            return true
        } else {
            isValidationPassed = true
        }
        
        categoryName = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if updatedText.count > maxLength {
            isValidationPassed = false
        } else {
            isValidationPassed = true
        }
        
        updateContinueButtonState()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isValidationPassed = false
        updateContinueButtonState()
        return true
    }
}
