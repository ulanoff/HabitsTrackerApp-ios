//
//  TrackersViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.10.2023.
//

import UIKit

fileprivate enum FilterOperation {
    case search
    case byWeekday
}

final class TrackersViewController: UIViewController {
    // MARK: - Properties
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    private lazy var trackerCategoryStore = TrackerCategoryStore()
    private lazy var trackerRecordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            showNeededViews()
            collectionView.reloadData()
        }
    }
    private var completedTrackers: [TrackerRecord] = []
    private var lastFilterOperation: FilterOperation = .byWeekday
    private var currentDate = Date().onlyDate
    private var currentWeekDay: WeekDay {
        WeekDay(numberFromSunday: currentDate.weekday)!
    }
    private var isTrackersArrayEmpty: Bool {
        get {
            var count = 0
            for category in visibleCategories {
                count += category.trackers.count
            }
            return count > 0 ? false : true
        }
    }
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        try! getAllCategories()
        try! getAllRecords()
        updateVisibleCategoriesByDate()
        setupUI()
        setupNavigationBar()
        showNeededViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.borderStyle = .roundedRect
    }
    
    // MARK: - Event Handlers
    @objc private func didTapAddButton(_ sender: UIButton) {
        let controller = SelectTypeViewController()
        controller.newTrackerDelegate = self
        present(controller.wrappedInNavigationController(), animated: true)
    }
    
    @objc private func didTapFiltersButton(_ sender: UIButton) {
        
    }
    
    @objc private func didChangeDateInDatePicker(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategoriesByDate()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - Private Methods
private extension TrackersViewController {
    func getAllCategories() throws {
        do {
            categories = try trackerCategoryStore.getAllCategories()
        } catch {
            throw error
        }
    }
    
    func getAllRecords() throws {
        do {
            completedTrackers = try trackerRecordStore.allRecords()
        } catch {
            throw error
        }
    }
    
    func createTracker(settings: TrackerSettings) {
        guard
            let name = settings.name,
            let color = settings.color,
            let emoji = settings.emoji,
            let schedule = settings.schedule,
            let settingsCategoryName = settings.categoryName
        else {
            assertionFailure("Failed to create Tracker")
            return
        }
                
        let tracker = Tracker(id: settings.id, name: name, color: color, emoji: emoji, schedule: schedule)
        let category = TrackerCategory(name: settingsCategoryName, trackers: [])
        _ = trackerStore.createTracker(tracker, category: category)
    }
    
    func showCancelButton() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func showNeededViews() {
        if isTrackersArrayEmpty {
            switch lastFilterOperation {
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
    
    func updateVisibleCategoriesByDate() {
        lastFilterOperation = .byWeekday
        visibleCategories = categories.filter { category in
            for tracker in category.trackers {
                if tracker.schedule.contains(currentWeekDay) { return true }
            }
            return false
        }.map { catetegory in
            let name = catetegory.name
            let trackers = catetegory.trackers.filter { $0.schedule.contains(currentWeekDay) }
            return TrackerCategory(name: name, trackers: trackers)
        }
    }
    
    func updateVisibleCategoriesBySearch(text: String) {
        lastFilterOperation = .search
        visibleCategories = visibleCategories.map { category in
            let foundTrackers = category.trackers.filter { $0.name.lowercased().contains(text.lowercased()) }
            return TrackerCategory(name: category.name, trackers: foundTrackers)
        }.filter { !$0.trackers.isEmpty }
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
        visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            assertionFailure("Couldn't deque reusable cell of type TrackerCell")
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isDoneButtonAvailable = !currentDate.isInFuture
        let daysStreak = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isDoneToday = completedTrackers.contains { trackerRecord in
            trackerRecord.date == currentDate &&
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
        view.configure(withTitle: visibleCategories[indexPath.section].name)
        return view
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {

}

// MARK: - UISearchTextFieldDelegate
extension TrackersViewController: UISearchTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text,
              text.lowercased() != string
        else { return true }
        
        if string.isEmpty {
            if text.count == 1 || range.length > 1 {
                updateVisibleCategoriesByDate()
            } else {
                updateVisibleCategoriesByDate()
                updateVisibleCategoriesBySearch(text: "\(text.removeLast())")
            }
            return true
        }
        
        updateVisibleCategoriesByDate()
        updateVisibleCategoriesBySearch(text: "\(text)\(string)")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        updateVisibleCategoriesByDate()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCell(_ trackerCell: TrackerCell, didTapDoneButton button: UIButton, trackerState: TrackerState, trackerId: UUID, indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerId: trackerId, date: currentDate)
        switch trackerState {
        case .done:
            completedTrackers.removeAll { trackerRecord in
                trackerRecord.trackerId == trackerId &&
                trackerRecord.date == currentDate
            }
            trackerRecordStore.deleteRecord(trackerRecord)
        case .notDone:
            completedTrackers.append(trackerRecord)
            _ = trackerRecordStore.createRecord(trackerRecord)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - NewTrackerViewControllerDelegate
extension TrackersViewController: NewTrackerViewControllerDelegate {
    func newTrackerViewController(_ newTrackerViewController: NewTrackerViewController, didBuildTrackerWith settings: TrackerSettings) {
        createTracker(settings: settings)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdate(_ store: TrackerStore) {
        try? getAllCategories()
        updateVisibleCategoriesByDate()
    }
}
