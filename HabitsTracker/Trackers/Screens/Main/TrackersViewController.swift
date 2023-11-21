//
//  TrackersViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.10.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: TrackersViewModel
    
    // MARK: - UI Elements
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Date().onlyDate
        datePicker.addTarget(self, action: #selector(didChangeDateInDatePicker(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        let placeholder = NSLocalizedString("mainScreen.searchTextField.placeholder", comment: "")
        let cancelButtonText = NSLocalizedString("mainScreen.searchTextField.candelButton", comment: "")
        textField.placeholder = placeholder
        textField.borderStyle = .line
        textField.setCustomClearButtonWithText(cancelButtonText)
        textField.delegate = self
        return textField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(TrackersHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersHeaderView.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        let bottomInset: CGFloat = 75.0
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSLocalizedString("mainScreen.filterButton", comment: "")
        button.backgroundColor = .ypBlue
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapFiltersButton(_:)), for: .touchUpInside)
        button.hide()
        return button
    }()
    
    private lazy var filtersButtonActiveView: UIView = {
        let activeView = UIView()
        activeView.backgroundColor = .ypRed
        activeView.layer.cornerRadius = 7.5
        activeView.hide()
        return activeView
    }()
    
    private lazy var noTrackersView: EmptyView = {
        let view = EmptyView()
        let text = NSLocalizedString("mainScreen.emptyStateByDate", comment: "")
        view.configure(image: .noTrackers, text: text)
        view.hide()
        return view
    }()
    
    private lazy var notFoundTrackersView: EmptyView = {
        let view = EmptyView()
        let text = NSLocalizedString("mainScreen.emptyStateBySearch", comment: "")
        view.configure(image: .notFound, text: text)
        view.hide()
        return view
    }()
    
    // MARK: - Lifecycle
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupUI()
        viewModel.updateState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.borderStyle = .roundedRect
    }
    
    // MARK: - Event Handlers
    @objc private func didTapAddButton(_ sender: UIButton) {
        let controller = SelectTypeViewController()
        controller.newTrackerDelegate = viewModel
        present(controller.wrappedInNavigationController(), animated: true)
    }
    
    @objc private func didTapFiltersButton(_ sender: UIButton) {
        let viewModel = FiltersViewModel(
            delegate: viewModel,
            selectedFilter: viewModel.selectedFilterOperation
        )
        let controller = FiltersViewController(viewModel: viewModel)
        present(controller.wrappedInNavigationController(), animated: true)
    }
    
    @objc private func didChangeDateInDatePicker(_ sender: UIDatePicker) {
        viewModel.didChangeDate(newDate: sender.date)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - Private Methods
private extension TrackersViewController {
    func bind() {
        viewModel.$visibleCategories.bind { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.$state.bind { [weak self] state in
            switch state {
            case .standart:
                self?.filtersButton.show()
                self?.filtersButtonActiveView.hide()
                self?.noTrackersView.hide()
                self?.notFoundTrackersView.hide()
            case .emptyByDefault:
                self?.filtersButton.hide()
                self?.filtersButtonActiveView.hide()
                self?.noTrackersView.show()
                self?.notFoundTrackersView.hide()
            case .emptyBySearch:
                self?.filtersButton.hide()
                self?.filtersButtonActiveView.hide()
                self?.noTrackersView.hide()
                self?.notFoundTrackersView.show()
            case .emptyByFilter:
                self?.filtersButton.show()
                self?.filtersButtonActiveView.show()
                self?.noTrackersView.hide()
                self?.notFoundTrackersView.show()
            case .filtersEnabled:
                self?.filtersButton.show()
                self?.filtersButtonActiveView.show()
                self?.noTrackersView.hide()
                self?.notFoundTrackersView.hide()
            }
        }
        
        viewModel.$selectedDate.bind { [weak self] date in
            self?.datePicker.setDate(date, animated: true)
        }
    }
    
    func showCancelButton() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func deleteTrackerAt(index: TrackerIndex) {
        let alertTitle = NSLocalizedString("actionSheet.title", comment: "")
        let deleteActionTitle = NSLocalizedString("actionSheet.deleteAction.title", comment: "")
        let cancelActionTitle = NSLocalizedString("actionSheet.cancelAction.title", comment: "")
        
        let alert = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(title: deleteActionTitle, style: .destructive) { [weak self] _ in
            self?.viewModel.didDeleteTrackerAt(index: index)
        }
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        view.addSubview(noTrackersView)
        view.addSubview(notFoundTrackersView)
        view.addSubview(filtersButtonActiveView)
        
        // MARK: - Constraints
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        noTrackersView.translatesAutoresizingMaskIntoConstraints = false
        notFoundTrackersView.translatesAutoresizingMaskIntoConstraints = false
        filtersButtonActiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            
            filtersButtonActiveView.widthAnchor.constraint(equalToConstant: 15),
            filtersButtonActiveView.heightAnchor.constraint(equalToConstant: 15),
            filtersButtonActiveView.topAnchor.constraint(equalTo: filtersButton.topAnchor, constant: -4.5),
            filtersButtonActiveView.trailingAnchor.constraint(equalTo: filtersButton.trailingAnchor, constant: 4.5),
            
            noTrackersView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            noTrackersView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            
            notFoundTrackersView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            notFoundTrackersView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
        ])
        
        // MARK: - Views Configuring
        setupNavigationBar()
        view.backgroundColor = .ypWhite
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupNavigationBar() {
        title = NSLocalizedString("mainScreen.title", comment: "")
        let leftBarButton = makeLeftBarButton()
        let rightBarButton = makeRightBarButton()
        navigationItem.setLeftBarButton(leftBarButton, animated: false)
        navigationItem.setRightBarButton(rightBarButton, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func makeLeftBarButton() -> UIBarButtonItem {
        let leftBarButton = UIBarButtonItem(
            title: "+",
            style: .plain,
            target: self,
            action: #selector(didTapAddButton(_:))
        )
        leftBarButton.setTitleTextAttributes(
            [.font : UIFont.systemFont(ofSize: 36)],
            for: .normal
        )
        leftBarButton.setTitleTextAttributes(
            [.font : UIFont.systemFont(ofSize: 36)],
            for: .highlighted
        )
        leftBarButton.tintColor = .ypBlack
        return leftBarButton
    }
    
    func makeRightBarButton() -> UIBarButtonItem {
        let rightBarButton = UIBarButtonItem(customView: datePicker)
        return rightBarButton
    }
    
    func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .absolute(148))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(148))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(9)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 9
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: headerSize,
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            assertionFailure("Couldn't deque reusable cell of type TrackerCell")
            return UICollectionViewCell()
        }
        let tracker = viewModel.visibleCategories[indexPath.section].trackers[indexPath.item]
        let trackerViewConfiguration = viewModel.trackerViewConfiguration(for: tracker)
        cell.configure(withTracker: tracker,
                       configuration: trackerViewConfiguration,
                       indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersHeaderView.reuseIdentifier, for: indexPath) as? TrackersHeaderView 
        else {
            return UICollectionReusableView()
        }
        view.configure(withTitle: viewModel.visibleCategories[indexPath.section].name)
        return view
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {}

// MARK: - UISearchTextFieldDelegate
extension TrackersViewController: UISearchTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        viewModel.didSearchFor(name: updatedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        viewModel.didSearchFor(name: "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint) -> UIContextMenuConfiguration?
    {
        guard let indexPath = indexPaths.first else {
            return nil
        }
        let trackerIndex = TrackerIndex(
            categoryIndex: indexPath.section,
            trackerIndex: indexPath.item
        )
        let isPinned = viewModel.isTrackerPinnedAt(index: trackerIndex)
        
        let configuration = UIContextMenuConfiguration(actionProvider: { [weak self] suggestedActions in
            guard let self else { return UIMenu() }
            
            let editButtonTitle = NSLocalizedString("contextMenu.edit", comment: "")
            let deleteButtonTitle = NSLocalizedString("contextMenu.delete", comment: "")
            let pinButtonTitle = switch isPinned {
            case true: NSLocalizedString("contextMenu.unpin", comment: "")
            case false: NSLocalizedString("contextMenu.pin", comment: "")
            }
            
            return UIMenu(children: [
                UIAction(title: pinButtonTitle) { [weak self] action in
                    guard let self else { return }
                    viewModel.didPinOrUnpinTracker(index: trackerIndex)
                },
                UIAction(title: editButtonTitle) { [weak self] action in
                    guard let self else { return }
                    let tracker = viewModel.trackerForEdit(at: trackerIndex)
                    let controller = TrackerSettingsViewController(tracker: tracker)
                    controller.delegate = viewModel
                    present(controller.wrappedInNavigationController(), animated: true)
                },
                UIAction(title: deleteButtonTitle, attributes: .destructive) { [weak self] action in
                    guard let self else { return }
                    deleteTrackerAt(index: trackerIndex)
                },
            ])
        })
        return configuration
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCell(_ trackerCell: TrackerCell, didTapDoneButton button: UIButton, trackerState: TrackerState, trackerId: UUID, indexPath: IndexPath) {
        viewModel.didTapDoneButtonOnTracker(trackerState: trackerState, trackerId: trackerId)
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}
