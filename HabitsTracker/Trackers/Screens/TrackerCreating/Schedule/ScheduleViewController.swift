//
//  ScheduleViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import UIKit

fileprivate struct TableSettings {
    static let scheduleTableRowHeight: CGFloat = 75
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ scheduleViewController: ScheduleViewController, didSelectWeekDays weekDays: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: ScheduleViewControllerDelegate?
    private let weekDaysStrings: [String] = [
        NSLocalizedString("weekDay.monday.full", comment: ""),
        NSLocalizedString("weekDay.tuesday.full", comment: ""),
        NSLocalizedString("weekDay.wednesday.full", comment: ""),
        NSLocalizedString("weekDay.thursday.full", comment: ""),
        NSLocalizedString("weekDay.friday.full", comment: ""),
        NSLocalizedString("weekDay.saturday.full", comment: ""),
        NSLocalizedString("weekDay.sunday.full", comment: ""),
    ]
    private var selectedWeekDays: Set<WeekDay> = []
    private var scheduleTableHeight: CGFloat {
        TableSettings.scheduleTableRowHeight * CGFloat(weekDaysStrings.count)
    }
    
    
    // MARK: - UI Elements
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = TableSettings.scheduleTableRowHeight
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView()
        return tableView
    }()
    
    private lazy var continueButton: Button = {
        let button = Button()
        let title = NSLocalizedString("scheduleScreen.confirmButton", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapContinueButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(currentSchedule: [WeekDay]) {
        selectedWeekDays = Set(currentSchedule)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Event Handlers
    @objc func didChangeValueInSwitch(_ switcher: UISwitch) {
        guard let weekDay = WeekDay(numberFromMonday: switcher.tag + 1) else {
            assertionFailure("Failed to create WeekDay object")
            return
        }
        if switcher.isOn {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
    
    @objc func didTapContinueButton(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
        delegate?.scheduleViewController(self, didSelectWeekDays: Array(selectedWeekDays))
    }
}

// MARK: - Private Methods
private extension ScheduleViewController {
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(scheduleTableView)
        view.addSubview(continueButton)
        
        // MARK: - Constraints
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            scheduleTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: scheduleTableHeight),
            
            continueButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // MARK: - Views Configuring
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("scheduleScreen.title", comment: "")
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDaysStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let weekDay = WeekDay(numberFromMonday: indexPath.row + 1) else {
            assertionFailure("Failed to create WeekDay object")
            return UITableViewCell()
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let switcher = UISwitch()
        switcher.tag = indexPath.row
        switcher.isOn = selectedWeekDays.contains(weekDay)
        switcher.addTarget(self, action: #selector(didChangeValueInSwitch(_:)), for: .valueChanged)
        switcher.onTintColor = .ypBlue
        
        cell.textLabel?.text = weekDaysStrings[indexPath.row]
        cell.accessoryView = switcher
        cell.backgroundColor = .ypBackground
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: scheduleTableView.frame.size.width)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    
}
