//
//  NewTrackerViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

// MARK: - Constants
fileprivate struct TableSettings {
    static let settingsTableRowHeight: CGFloat = 75
    static let settingsTableRowLabels = ["Категория", "Расписание"]
}

fileprivate struct CollectionSettings {
    static let settingsCollectionViewInteritemSpacing: CGFloat = 5
    static let settingsCollectionViewLineSpacing: CGFloat = 0
    static let settingsCollectionViewItemsPerLineEmojiSection = 6
    static let settingsCollectionViewItemsPerLineColorSection = 6
}

protocol NewTrackerViewControllerDelegate: AnyObject {
    func newTrackerViewController(_ newTrackerViewController: NewTrackerViewController, didBuildTrackerWith settings: TrackerSettings)
}

final class NewTrackerViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: NewTrackerViewControllerDelegate?
    private let settingsEmojis = AppConstants.trackerEmojis
    private let settingsColors: [UIColor] = AppConstants.trackerColors
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var textFieldMessageHeightConstraint: NSLayoutConstraint!
    
    private var trackerSettings: TrackerSettings {
        didSet { updateCreateButtonState() }
    }
    
    private var isValidationPassed = true {
        didSet { updateCreateButtonState() }
    }
    
    private var settingsTableNumberOfRows: Int {
        trackerSettings.trackerType == .habit ? 2 : 1
    }
    
    private var settingsTableHeight: CGFloat {
        trackerSettings.trackerType == .habit ?
        TableSettings.settingsTableRowHeight * 2 :
        TableSettings.settingsTableRowHeight
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
        tableView.rowHeight = TableSettings.settingsTableRowHeight
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private lazy var settingsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.register(SettingsCollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SettingsCollectionHeaderView.reuseIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = true
        return collectionView
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
    
    func makeEmojiCell(collectionView: UICollectionView, indexPath: IndexPath) -> EmojiCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell
        else {
            assertionFailure("Failed to cast reusable cell to EmojiCell")
            return EmojiCell()
        }
        cell.configure(emoji: settingsEmojis[indexPath.item])
        return cell
    }
    
    func makeColorCell(collectionView: UICollectionView, indexPath: IndexPath) -> ColorCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell
        else {
            assertionFailure("Failed to cast reusable cell to ColorCell")
            return ColorCell()
        }
        cell.setup(color: settingsColors[indexPath.item])
        return cell
    }
    
    func selectOrDeselectEmojiCell(cell: UICollectionViewCell, indexPath: IndexPath, isSelect: Bool) {
        guard
            let emojiCell = cell as? EmojiCell
        else {
            return
        }
        
        if isSelect {
            emojiCell.selected()
        } else {
            emojiCell.deselected()
        }
        
        trackerSettings.emoji = settingsEmojis[indexPath.item]
    }
    
    func selectOrDeselectColorCell(cell: UICollectionViewCell, indexPath: IndexPath, isSelect: Bool) {
        guard
            let colorCell = cell as? ColorCell
        else {
            return
        }
        
        if isSelect {
            colorCell.selected()
        } else {
            colorCell.deselected()
        }
        
        trackerSettings.color = settingsColors[indexPath.item]
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
        // MARK: - Subviews
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(trackerNameTextField)
        scrollContentView.addSubview(textFieldMessageLabel)
        scrollContentView.addSubview(settingsCollectionView)
        scrollContentView.addSubview(settingsTableView)
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
        settingsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
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
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollContentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
                .prioritized(250),
            
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
            settingsTableView.heightAnchor.constraint(equalToConstant: settingsTableHeight),
            
            settingsCollectionView.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 32),
            settingsCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor),
            settingsCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor),
            settingsCollectionView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            settingsCollectionView.heightAnchor.constraint(equalToConstant: 465)
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
        cell.textLabel?.text = TableSettings.settingsTableRowLabels[indexPath.row]
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

// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return switch section {
        case 0:
            settingsEmojis.count
        case 1:
            settingsColors.count
        default:
            0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return switch indexPath.section {
        case 0:
            makeEmojiCell(collectionView: collectionView, indexPath: indexPath)
        case 1:
            makeColorCell(collectionView: collectionView, indexPath: indexPath)
        default:
            UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard 
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return
        }
        
        switch indexPath.section {
        case 0:
            if let selectedEmojiIndexPath {
                collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: selectedEmojiIndexPath)
                self.selectedEmojiIndexPath = indexPath
            }
            self.selectedEmojiIndexPath = indexPath
            selectOrDeselectEmojiCell(cell: cell, indexPath: indexPath, isSelect: true)
        case 1:
            if let selectedColorIndexPath {
                collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: selectedColorIndexPath)
                self.selectedColorIndexPath = indexPath
            }
            self.selectedColorIndexPath = indexPath
            selectOrDeselectColorCell(cell: cell, indexPath: indexPath, isSelect: true)
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return
        }
        
        switch indexPath.section {
        case 0:
            selectOrDeselectEmojiCell(cell: cell, indexPath: indexPath, isSelect: false)
        case 1:
            selectOrDeselectColorCell(cell: cell, indexPath: indexPath, isSelect: false)
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsInLine = if indexPath.section == 0 {
            CollectionSettings.settingsCollectionViewItemsPerLineEmojiSection
        } else {
            CollectionSettings.settingsCollectionViewItemsPerLineColorSection
        }
        let interitemSpacing = CollectionSettings.settingsCollectionViewInteritemSpacing
        let spacing = CGFloat(itemsInLine) * interitemSpacing
        let availableSpace = collectionView.frame.width - spacing
        let width = availableSpace / CGFloat(itemsInLine)
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        CollectionSettings.settingsCollectionViewInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CollectionSettings.settingsCollectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard 
            kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SettingsCollectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? SettingsCollectionHeaderView
        else {
            return UICollectionReusableView()
        }
        
        let headerText = if indexPath.section == 0 {
            "Emoji"
        } else {
            "Цвет"
        }
        headerView.configure(withText: headerText)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize 
    {
        return CGSize(width: collectionView.frame.width, height: 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard section == 0 else { return UIEdgeInsets() }
        return UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
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
        
        if updatedText.isEmpty || updatedText.isBlank {
            isValidationPassed = false
            updateCreateButtonState()
            return true
        } else {
            isValidationPassed = true
        }
        
        trackerSettings.name = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
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

