//
//  NewCategoryViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 06.11.2023.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func newCategoryViewController(
        _ viewController: NewCategoryViewController,
        didSetupNewCategory trackerCategory: TrackerCategory
    )
}

final class NewCategoryViewController: UIViewController {
    // MARK: - Properties
    private var categoryName = ""
    private var isValidationPassed = false
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var textField: TextField = {
        let textField = TextField()
        textField.delegate = self
        textField.placeholder = "Введите название категории"
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var continueButton: Button = {
        let button = Button()
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContinueButtonState()
        addMainViewTapGesture()
    }
    // MARK: - Event Handlers
    @objc private func didTapContinueButton() {
        let trackerCategory = TrackerCategory(name: categoryName, trackers: [])
        delegate?.newCategoryViewController(self, didSetupNewCategory: trackerCategory)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Public Methods
}

// MARK: - Private Methods
private extension NewCategoryViewController {
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
        title = "Новая категория"
    }
}

// MARK: - Protocols Conforming
extension NewCategoryViewController: UITextFieldDelegate {
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
