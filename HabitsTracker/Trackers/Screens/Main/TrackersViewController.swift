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
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.borderStyle = .line
        textField.setCustomClearButtonWithText("Отменить")
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
        return collectionView
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlue
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(didTapFiltersButton(_:)), for: .touchUpInside)
        button.hide()
        return button
    }()
    
    private lazy var noTrackersView: EmptyView = {
        let view = EmptyView()
        view.configure(image: .noTrackers, text: "Что будем отслеживать?")
        view.hide()
        return view
    }()
    
    private lazy var notFoundTrackersView: EmptyView = {
        let view = EmptyView()
        view.configure(image: .notFound, text: "Ничего не найдено")
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
        showNeededViews()
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
            self?.showNeededViews()
            self?.collectionView.reloadData()
        }
    }
    
    func showCancelButton() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func showNeededViews() {
        if viewModel.visibleCategories.isEmpty {
            switch viewModel.lastFilterOperation {
            case .byWeekday:
                noTrackersView.show()
                notFoundTrackersView.hide()
            case .search:
                noTrackersView.hide()
                notFoundTrackersView.show()
            }
            filtersButton.hide()
        } else {
            noTrackersView.hide()
            notFoundTrackersView.hide()
            filtersButton.show()
        }
    }
    
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        view.addSubview(noTrackersView)
        view.addSubview(notFoundTrackersView)
        
        // MARK: - Constraints
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        noTrackersView.translatesAutoresizingMaskIntoConstraints = false
        notFoundTrackersView.translatesAutoresizingMaskIntoConstraints = false
        
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
        title = "Трекеры"
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
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Date().onlyDate
        datePicker.addTarget(self, action: #selector(didChangeDateInDatePicker(_:)), for: .valueChanged)
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
        let isDoneButtonAvailable = viewModel.isFulfillmentAvailable
        let daysStreak = viewModel.completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isDoneToday = viewModel.completedTrackers.contains { trackerRecord in
            trackerRecord.date == viewModel.selectedDate &&
            trackerRecord.trackerId == tracker.id
        }
        cell.configure(withTracker: tracker,
                       isDoneToday: isDoneToday,
                       daysStreak: daysStreak,
                       isDoneButtonAvailable: isDoneButtonAvailable,
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
