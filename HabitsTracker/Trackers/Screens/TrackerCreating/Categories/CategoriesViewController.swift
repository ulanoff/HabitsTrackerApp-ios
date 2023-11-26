//
//  CategoryViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 06.11.2023.
//

import UIKit

fileprivate struct TableSettings {
    static let tableRowHeight: CGFloat = 75
}

final class CategoriesViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: CategoriesViewModel
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = TableSettings.tableRowHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.tableHeaderView = UIView()
        return tableView
    }()
    
    private lazy var createButton: Button = {
        let button = Button()
        let title = NSLocalizedString("categoriesScreen.createButton", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var noCategoriesView: EmptyView = {
        let view = EmptyView()
        let text = NSLocalizedString("categoriesScreen.emptyState", comment: "")
        view.configure(image: .noTrackers, text: text)
        view.hide()
        return view
    }()
    
    // MARK: - Lifecycle
    init(viewModel: CategoriesViewModel) {
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
    
    // MARK: - Event Handlers
    @objc private func didTapCreateButton() {
        AnalyticsService.sendClickEvent(screen: .categories, item: "add_category")
        let viewModel = CategoryNameViewModel()
        let controller = CategoryNameViewController(type: .creating, categoryName: nil, viewModel: viewModel)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Public Methods
}

// MARK: - Private Methods
private extension CategoriesViewController {
    func bind() {
        viewModel.$categories.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.$state.bind { [weak self] state in
            switch state {
            case .standart:
                self?.noCategoriesView.hide()
            case .empty:
                self?.noCategoriesView.show()
            }
        }
        
        viewModel.$selectedCategoryIndex.bind { [weak self] selectedCategoryIndex in
            guard
                let self,
                let selectedCategoryIndex
            else {
                return
            }
            let indexPath = IndexPath(row: selectedCategoryIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.$oldSelectedCategoryIndex.bind { [weak self] oldSelectedCategoryIndex in
            guard
                let self,
                let oldSelectedCategoryIndex
            else {
                return
            }
            let indexPath = IndexPath(row: oldSelectedCategoryIndex, section: 0)
            self.tableView.delegate?.tableView?(self.tableView, didDeselectRowAt: indexPath)
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(tableView)
        view.addSubview(createButton)
        view.addSubview(noCategoriesView)
        
        // MARK: - Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        noCategoriesView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            
            createButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            createButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            noCategoriesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noCategoriesView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // MARK: - Views Configuring
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("categoriesScreen.title", comment: "")
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let categoryState = viewModel.stateForCategoryAtIndex(index: indexPath.row)
        cell.textLabel?.text = viewModel.categories[indexPath.row]
        cell.accessoryType = categoryState == .selected ? .checkmark : .none
        cell.backgroundColor = .ypBackground
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        if indexPath.row == 0 && tableView.numberOfRows(inSection: 0) == 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.size.width)
        } else if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.size.width)
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCategoryAt(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint) -> UIContextMenuConfiguration? {
            let configuration = UIContextMenuConfiguration(actionProvider: { [weak self] suggestedActions in
                guard let self else { return UIMenu() }
                let editButtonTitle = NSLocalizedString("contextMenu.edit", comment: "")
                let deleteButtonTitle = NSLocalizedString("contextMenu.delete", comment: "")
                return UIMenu(children: [
                    UIAction(title: editButtonTitle) { [weak self] action in
                        AnalyticsService.sendClickEvent(screen: .categories, item: "edit")
                        guard let self else { return }
                        let categoryName = self.viewModel.categories[indexPath.row]
                        let viewModel = CategoryNameViewModel()
                        let controller = CategoryNameViewController(type: .editing, categoryName: categoryName, viewModel: viewModel)
                        controller.delegate = self
                        navigationController?.pushViewController(controller, animated: true)
                    },
                    UIAction(title: deleteButtonTitle, attributes: .destructive) { [weak self] action in
                        AnalyticsService.sendClickEvent(screen: .categories, item: "delete")
                        guard let self else { return }
                        let categoryName = self.viewModel.categories[indexPath.row]
                        let category = TrackerCategory(name: categoryName, trackers: [])
                        self.viewModel.didDeleteCategory(category)
                        self.tableView.reloadData()
                    },
                ])
            })
            return configuration
    }
}

// MARK: - NewCategoryViewControllerDelegate
extension CategoriesViewController: CategoryNameViewControllerDelegate {
    func newCategoryViewController(
        _ viewController: CategoryNameViewController, 
        didEditedCategory trackerCategory: TrackerCategory,
        to newTrackerCategory: TrackerCategory
    ) {
        viewModel.didUpdateCategory(trackerCategory, newCategory: newTrackerCategory)
        tableView.reloadData()
    }
    
    func newCategoryViewController(
        _ viewController: CategoryNameViewController,
        didSetupNewCategory trackerCategory: TrackerCategory
    ) {
        viewModel.didAddCategory(trackerCategory)
        tableView.reloadData()
    }
}
