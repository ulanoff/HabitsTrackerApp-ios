//
//  FiltersViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 18.11.2023.
//

import UIKit

fileprivate struct TableSettings {
    static let tableRowHeight: CGFloat = 75
}

final class FiltersViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: FiltersViewModel
    
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
    // MARK: - Lifecycle
    init(viewModel: FiltersViewModel) {
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
    }
}

// MARK: - Private Methods
private extension FiltersViewController {
    func bind() {
        viewModel.$oldSelectedFilterIndex.bind { [weak self] index in
            guard let self else { return }
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
        }
        
        viewModel.$selectedFilterIndex.bind { [weak self] index in
            guard let self else { return }
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(tableView)
        
        // MARK: - Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24)
        ])
        
        // MARK: - Views Configuring
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("filtersScreen.title", comment: "")
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let filterState = viewModel.stateForFilterAt(index: indexPath.row)
        
        cell.textLabel?.text = viewModel.filters[indexPath.row].description
        cell.accessoryType = filterState == .selected ? .checkmark : .none
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
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectFilterAt(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
