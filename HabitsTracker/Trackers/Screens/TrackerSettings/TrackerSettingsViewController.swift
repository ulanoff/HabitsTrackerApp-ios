//
//  TrackerSettingsViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

// MARK: - Constants
fileprivate struct TableSettings {
    static let settingsTableRowHeight: CGFloat = 75
    static let settingsTableRowLabels = [
        NSLocalizedString("trackerSettingsScreen.categoryButton", comment: ""),
        NSLocalizedString("trackerSettingsScreen.scheduleButton", comment: "")
    ]
}

fileprivate struct CollectionSettings {
    static let settingsCollectionViewInteritemSpacing: CGFloat = 5
    static let settingsCollectionViewLineSpacing: CGFloat = 0
    static let settingsCollectionViewItemsPerLine = 6
}

protocol TrackerSettingsViewControllerDelegate: AnyObject {
    func trackerSettingsViewController(
        _ trackerSettingsViewController: TrackerSettingsViewController,
        didCreateTrackerWith settings: TrackerSettings
    )
    func trackerSettingsViewController(
        _ trackerSettingsViewController: TrackerSettingsViewController,
        didEditTracker tracker: Tracker,
        to newTracker: Tracker
    )
}

final class TrackerSettingsViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: TrackerSettingsViewControllerDelegate?
    private let viewModel: TrackerSettingsViewModel
    private let settingsEmojis = TrackerConstants.trackerEmojis
    private let settingsColors: [UIColor] = TrackerConstants.trackerColors
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var textFieldMessageHeightConstraint: NSLayoutConstraint!
    private var settingsCollectionViewHeightConstraint: NSLayoutConstraint!
    private let navBarTitle: String
    private let confirmButtonTitle: String
    
    private var settingsTableNumberOfRows: Int {
        viewModel.trackerSettings.trackerType == .habit ? 2 : 1
    }
    
    private var settingsTableHeight: CGFloat {
        viewModel.trackerSettings.trackerType == .habit ?
        TableSettings.settingsTableRowHeight * 2 :
        TableSettings.settingsTableRowHeight
    }
    
    private var settingsCollectionViewItemSize: CGSize {
        let itemsInLine = CollectionSettings.settingsCollectionViewItemsPerLine
        let interitemSpacing = CollectionSettings.settingsCollectionViewInteritemSpacing
        let spacing = CGFloat(itemsInLine) * interitemSpacing
        let availableSpace = settingsCollectionView.frame.width - spacing
        let width = availableSpace / CGFloat(itemsInLine)
        let size = CGSize(width: width, height: width)
        return size
    }
    
    private var settingsCollectionViewHeight: CGFloat {
        let itemsInLine = CollectionSettings.settingsCollectionViewItemsPerLine
        let linesCount = (TrackerConstants.trackerEmojis.count + TrackerConstants.trackerColors.count) / itemsInLine
        let lineSpacing = CollectionSettings.settingsCollectionViewLineSpacing
        let spacing = lineSpacing * CGFloat(linesCount)
        var height = CGFloat(linesCount) * settingsCollectionViewItemSize.height + spacing
        height += 130
        return height
    }
    
    private var isValidCollectionHeight: Bool {
        settingsCollectionViewHeight > 150
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
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        if let days = viewModel.trackerRecordsCount {
            label.text = pluralizeDays(days)
        }
        return label
    }()
    
    private lazy var trackerNameTextField: TextField = {
        let textField = TextField()
        let placeholder = NSLocalizedString("trackerSettingsScreen.nameTextField.placeholder", comment: "")
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGray]
        )
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
        tableView.separatorColor = .ypGray
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
    
    private lazy var confirmButton: Button = {
        let button = Button()
        let title = NSLocalizedString(confirmButtonTitle, comment: "")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(didTapConfirmButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: Button = {
        let button = Button()
        let title = NSLocalizedString("trackerSettingsScreen.cancelButton", comment: "")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(didTapCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(trackerType: TrackerType) {
        viewModel = TrackerSettingsViewModel(trackerType: trackerType)
        navBarTitle = switch trackerType {
        case .habit:
            NSLocalizedString("trackerSettingsScreen.title.habitCreating", comment: "")
        case .irregularEvent:
            NSLocalizedString("trackerSettingsScreen.title.eventCreating", comment: "")
        }
        confirmButtonTitle = NSLocalizedString("trackerSettingsScreen.confirmButton.create", comment: "")
        super.init(nibName: nil, bundle: nil)
    }
    
    init(tracker: Tracker) {
        viewModel = TrackerSettingsViewModel(tracker: tracker)
        navBarTitle = switch tracker.type {
        case .habit:
            NSLocalizedString("trackerSettingsScreen.title.habitEditing", comment: "")
        case .irregularEvent:
            NSLocalizedString("trackerSettingsScreen.title.eventEditing", comment: "")
        }
        confirmButtonTitle = NSLocalizedString("trackerSettingsScreen.confirmButton.save", comment: "")
        super.init(nibName: nil, bundle: nil)
        trackerNameTextField.text = tracker.name
        updateCreateButtonState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isValidCollectionHeight {
            settingsCollectionViewHeightConstraint.constant = settingsCollectionViewHeight
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Event Handlers
    @objc private func didTapConfirmButton(_ button: UIButton) {
        dismiss(animated: true)
        if viewModel.isCreatingNew {
            delegate?.trackerSettingsViewController(self, didCreateTrackerWith: viewModel.trackerSettings)
        } else {
            guard 
                let trackerForEditing = viewModel.trackerForEditing,
                let editedTracker = viewModel.editedTracker()
            else {
                return
            }
            
            delegate?.trackerSettingsViewController(
                self,
                didEditTracker: trackerForEditing,
                to: editedTracker
            )
        }
    }
    
    @objc private func didTapCancelButton(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - Private Methods
private extension TrackerSettingsViewController {
    func bind() {
        viewModel.$isValidName.bind { [weak self] _ in
            self?.updateCreateButtonState()
        }
        
        viewModel.$nameErrorMessage.bind { [weak self] nameErrorMessage in
            if let message = nameErrorMessage {
                self?.showTextFieldMessage(text: message)
            } else {
                self?.hideTextFieldMessage()
            }
        }
        
        viewModel.$trackerSettings.bind { [weak self] _ in
            self?.updateCreateButtonState()
        }
        
        viewModel.$trackerCategory.bind { [weak self] _ in
            let categoryIndexPath = IndexPath(row: 0, section: 0)
            self?.settingsTableView.reloadRows(at: [categoryIndexPath], with: .automatic)
        }
    }
    
    func pluralizeDays(_ number: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("days", comment: ""),
            number
        )
    }
    
    func makeScheduleDescription() -> String? {
        guard let schedule = viewModel.trackerSettings.schedule else { return nil }
        if schedule.count == 7 {
            let everyday = NSLocalizedString("weekDay.everyday", comment: "")
            return everyday
        }
        let sortedSchedule = schedule.sorted(by: <)
        let weekDays = sortedSchedule.map { $0.description }
        let description = (weekDays.map { $0 }.joined(separator: ", "))
        return description
    }
    
    func makeEmojiCell(collectionView: UICollectionView, indexPath: IndexPath) -> EmojiCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell
        else {
            assertionFailure("Failed to cast reusable cell to EmojiCell")
            return EmojiCell()
        }
        let emoji = settingsEmojis[indexPath.item]
        cell.configure(emoji: emoji)
        if viewModel.isEmojiSelected(emoji: emoji) {
            selectOrDeselectEmojiCell(cell: cell, indexPath: indexPath, isSelect: true)
        }
        return cell
    }
    
    func makeColorCell(collectionView: UICollectionView, indexPath: IndexPath) -> ColorCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell
        else {
            assertionFailure("Failed to cast reusable cell to ColorCell")
            return ColorCell()
        }
        let color = settingsColors[indexPath.item]
        cell.setup(color: color)
        if viewModel.isColorSelected(color: color) {
            selectOrDeselectColorCell(cell: cell, indexPath: indexPath, isSelect: true)
        }
        return cell
    }
    
    func selectOrDeselectEmojiCell(cell: UICollectionViewCell, indexPath: IndexPath, isSelect: Bool) {
        guard
            let emojiCell = cell as? EmojiCell
        else {
            return
        }
        
        if isSelect {
            self.selectedEmojiIndexPath = indexPath
            emojiCell.selected()
            viewModel.didUpdateEmoji(newEmoji: settingsEmojis[indexPath.item])
        } else {
            emojiCell.deselected()
            viewModel.didUpdateEmoji(newEmoji: nil)
        }
    }
    
    func selectOrDeselectColorCell(cell: UICollectionViewCell, indexPath: IndexPath, isSelect: Bool) {
        guard
            let colorCell = cell as? ColorCell
        else {
            return
        }
        
        if isSelect {
            self.selectedColorIndexPath = indexPath
            colorCell.selected()
            viewModel.didUpdateColor(newColor: settingsColors[indexPath.item])
        } else {
            colorCell.deselected()
            viewModel.didUpdateColor(newColor: nil)
        }
    }
    
    func updateCreateButtonState() {
        
        if viewModel.trackerSettings.isValid &&
           viewModel.isValidName {
            confirmButton.isUserInteractionEnabled = true
            confirmButton.backgroundColor = .ypBlack
        } else {
            confirmButton.isUserInteractionEnabled = false
            confirmButton.backgroundColor = .ypGray
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
        scrollContentView.addSubview(daysLabel)
        scrollContentView.addSubview(trackerNameTextField)
        scrollContentView.addSubview(textFieldMessageLabel)
        scrollContentView.addSubview(settingsCollectionView)
        scrollContentView.addSubview(settingsTableView)
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(confirmButton)
        view.addSubview(scrollView)
        view.addSubview(buttonStack)
        
        // MARK: - Constraints
        trackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        textFieldMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        settingsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        let trackerNameTextFieldTopConstant: CGFloat = viewModel.isCreatingNew ? 0 : 40
        textFieldMessageHeightConstraint = textFieldMessageLabel.heightAnchor.constraint(equalToConstant: 0)
        settingsCollectionViewHeightConstraint = settingsCollectionView.heightAnchor.constraint(equalToConstant: 0)
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
            
            daysLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 24),
            daysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: trackerNameTextFieldTopConstant),
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
            settingsCollectionViewHeightConstraint
        ])
        
        // MARK: - Views Configuring
        view.backgroundColor = .ypWhite
        navigationItem.setHidesBackButton(true, animated: false)
        title = navBarTitle
    }
}

// MARK: - UITableViewDataSource
extension TrackerSettingsViewController: UITableViewDataSource {
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
        
        if indexPath.row == 0,
           let categoryName = viewModel.trackerSettings.categoryName {
            cell.detailTextLabel?.text = categoryName
        }
        
        if indexPath.row == 1,
           viewModel.trackerSettings.schedule != nil,
           let scheduleDescription = makeScheduleDescription() {
            cell.detailTextLabel?.text = scheduleDescription
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: settingsTableView.frame.size.width)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let viewModel = CategoriesViewModel(delegate: self.viewModel, selectedCategory: viewModel.trackerSettings.categoryName)
            let controller = CategoriesViewController(viewModel: viewModel)
            
            navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = ScheduleViewController(currentSchedule: viewModel.trackerSettings.schedule ?? [])
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        default:
            assertionFailure("Not expected indexPath")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerSettingsViewController: UICollectionViewDataSource {
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
extension TrackerSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return
        }
        
        switch indexPath.section {
        case 0:
            if let selectedEmojiIndexPath {
                collectionView.deselectItem(at: selectedEmojiIndexPath, animated: false)
                collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: selectedEmojiIndexPath)
                self.selectedEmojiIndexPath = indexPath
            }
            selectOrDeselectEmojiCell(cell: cell, indexPath: indexPath, isSelect: true)
        case 1:
            if let selectedColorIndexPath {
                collectionView.deselectItem(at: selectedColorIndexPath, animated: false)
                collectionView.delegate?.collectionView?(collectionView, didDeselectItemAt: selectedColorIndexPath)
                self.selectedColorIndexPath = indexPath
            }
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
        settingsCollectionViewItemSize
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
            NSLocalizedString("trackerSettingsScreen.emojiTitle", comment: "")
        } else {
            NSLocalizedString("trackerSettingsScreen.colorTitle", comment: "")
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
extension TrackerSettingsViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ scheduleViewController: ScheduleViewController, didSelectWeekDays weekDays: [WeekDay]) {
        viewModel.didUpdateSchedule(newSchedule: weekDays)
        let scheduleIndexPath = IndexPath(row: 1, section: 0)
        settingsTableView.reloadRows(at: [scheduleIndexPath], with: .automatic)
    }
}

// MARK: - UITextFieldDelegate
extension TrackerSettingsViewController: UITextFieldDelegate {
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
