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
    private let viewModel: CategoryNameViewModel
    private var oldCategoryName = ""
    private var categoryName = ""
    private let controllerType: CategoryNameViewControllerType
    private var isValidationPassed = false
    
    weak var delegate: CategoryNameViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var textField: TextField = {
        let textField = TextField()
        let placeholder = NSLocalizedString("newCategoryScreen.nameTextField.placeholder", comment: "")
        textField.delegate = self
        textField.placeholder = placeholder
        textField.clearButtonMode = .whileEditing
        textField.text = oldCategoryName
        return textField
    }()
    
    private lazy var continueButton: Button = {
        let button = Button()
        let title = NSLocalizedString("newCategoryScreen.confirmButton", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(type: CategoryNameViewControllerType, categoryName: String?, viewModel: CategoryNameViewModel) {
        self.viewModel = viewModel
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
        bind()
        setupUI()
        addMainViewTapGesture()
        viewModel.didEnterNewName(oldCategoryName)
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
    func bind() {
        viewModel.$categoryName.bind { [weak self] categoryName in
            guard let self else { return }
            self.categoryName = categoryName
        }
        
        viewModel.$isNameValid.bind { [weak self] isNameValid in
            guard let self else { return }
            self.updateContinueButtonState(isNameValid: isNameValid)
        }
    }
    
    func updateContinueButtonState(isNameValid: Bool) {
        if isNameValid
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
            title = NSLocalizedString("newCategoryScreen.title", comment: "")
        case .editing:
            title = NSLocalizedString("editCategoryScreen.title", comment: "")
        }
    }
}

// MARK: - Protocols Conforming
extension CategoryNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        viewModel.didEnterNewName(updatedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.didEnterNewName("")
        return true
    }
}
