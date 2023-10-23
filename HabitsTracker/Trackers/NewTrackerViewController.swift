//
//  NewTrackerViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func newTrackerViewController(_ newTrackerViewController: NewTrackerViewController, didBuildTrackerWith settings: TrackerSettings)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?
    private var trackerSettings: TrackerSettings {
        didSet {
            updateCreateButtonState()
        }
    }
    private let settingsTableRowLabels = ["Категория", "Расписание"]
    private let settingsTableRowHeight: CGFloat = 75
    private var settingsTableHeight: CGFloat {
        get {
            trackerSettings.trackerType == .habit ?
            settingsTableRowHeight * 2 :
            settingsTableRowHeight
        }
    }
    private var settingsTableNumberOfRows: Int {
        trackerSettings.trackerType == .habit ? 2 : 1
    }
    private var textFieldMessageHeightConstraint: NSLayoutConstraint!
    private var isValidationPassed = true {
        didSet {
            updateCreateButtonState()
        }
    }
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
        return scrollView
    }()
    
    private lazy var scrollContentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private lazy var trackerNameTextField: TextField = {
        let textField = TextField()
        textField.delegate = self
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var textFieldMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = settingsTableRowHeight
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var createButton: Button = {
        let button = Button()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapCreateButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: Button = {
        let button = Button()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(trackerType: TrackerType) {
        trackerSettings = TrackerSettings(trackerType: trackerType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let category = TrackerCategory(name: "Важное", trackers: [])
        trackerSettings.category = category
        trackerSettings.color = .ypSelection10
        trackerSettings.emoji = "🤍"
        trackerSettings.id = UUID()
    }
    
    // MARK: - Event Handlers
    @objc private func didTapCreateButton(_ button: UIButton) {
        dismiss(animated: true)
        delegate?.newTrackerViewController(self, didBuildTrackerWith: trackerSettings)
    }
    
    @objc private func didTapCancelButton(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Public Methods
}

// MARK: - Private Methods
private extension NewTrackerViewController {
    func makeScheduleDescription() -> String? {
        guard let schedule = trackerSettings.schedule else { return nil }
        if schedule.count == 7 {
            return "Каждый день"
        }
        let sortedSchedule = schedule.sorted(by: <)
        let weekDays = sortedSchedule.map { $0.description }
        let description = (weekDays.map{$0}.joined(separator: ", "))
        return description
    }
    
    func updateCreateButtonState() {
        if trackerSettings.isReady &&
            isValidationPassed
        {
            createButton.isUserInteractionEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isUserInteractionEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    func showTextFieldMessage(text: String) {
        textFieldMessageLabel.text = text
        textFieldMessageHeightConstraint.constant = 38
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func hideTextFieldMessage() {
        textFieldMessageHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Add Subviews
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(trackerNameTextField)
        scrollContentView.addSubview(settingsTableView)
        scrollContentView.addSubview(textFieldMessageLabel)
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        view.addSubview(scrollView)
        view.addSubview(buttonStack)
        
        // MARK: - Constraints
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        textFieldMessageHeightConstraint = textFieldMessageLabel.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -16),
            
            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
                .prioritized(250),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            
            trackerNameTextField.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            trackerNameTextField.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            trackerNameTextField.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            
            textFieldMessageHeightConstraint,
            textFieldMessageLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor),
            textFieldMessageLabel.leadingAnchor.constraint(equalTo: trackerNameTextField.leadingAnchor),
            textFieldMessageLabel.trailingAnchor.constraint(equalTo: trackerNameTextField.trailingAnchor),
            
            settingsTableView.topAnchor.constraint(equalTo: textFieldMessageLabel.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            settingsTableView.heightAnchor.constraint(equalToConstant: settingsTableHeight)
        ])
        
        // MARK: - Views Configuring
        view.backgroundColor = .ypWhite
        navigationItem.setHidesBackButton(true, animated: false)
        title = trackerSettings.trackerType == .habit ?
        "Новая привычка":
        "Новое нерегулярное событие"
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsTableNumberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = settingsTableRowLabels[indexPath.row]
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .ypBackground
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        if indexPath.row == 1,
           let _ = trackerSettings.schedule,
           let scheduleDescription = makeScheduleDescription()
        {
            cell.detailTextLabel?.text = scheduleDescription
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: settingsTableView.frame.size.width)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let controller = ScheduleViewController(currentSchedule: trackerSettings.schedule ?? [])
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ scheduleViewController: ScheduleViewController, didSelectWeekDays weekDays: [WeekDay]) {
        trackerSettings.schedule = weekDays
        let scheduleIndexPath = IndexPath(row: 1, section: 0)
        settingsTableView.reloadRows(at: [scheduleIndexPath], with: .automatic)
    }
}

// MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        trackerSettings.name = updatedText
        
        if updatedText.count > maxLength {
            showTextFieldMessage(text: "Ограничение 38 символов")
            isValidationPassed = false
        } else {
            hideTextFieldMessage()
            isValidationPassed = true
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isValidationPassed = false
        updateCreateButtonState()
        hideTextFieldMessage()
        return true
    }
}

