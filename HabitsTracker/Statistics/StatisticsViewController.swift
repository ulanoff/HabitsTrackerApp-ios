//
//  StatisticsViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import UIKit

enum StatisticsState {
    case standart
    case empty
}

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: StatisticsViewModel
    private var isFirstApear = true
    
    // MARK: - UI Elements
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        let text = NSLocalizedString("statisticsScreen.emptyView", comment: "")
        view.configure(
            image: .statisticsEmptyView,
            text: text
        )
        view.isHidden = viewModel.state == .standart
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 12
        stack.addArrangedSubview(averageCompletionsView)
        stack.addArrangedSubview(trackersCompletedView)
        stack.addArrangedSubview(perfectDaysView)
        stack.addArrangedSubview(bestStreakView)
        stack.isHidden = viewModel.state == .empty
        return stack
    }()
    
    private lazy var bestStreakView: StatisticsView = {
        let view = StatisticsView()
        let name = NSLocalizedString("statisticsScreen.bestStreak", comment: "")
        view.configure(
            name: name,
            value: viewModel.statistics.bestStreak
        )
        return view
    }()
    
    private lazy var perfectDaysView: StatisticsView = {
        let view = StatisticsView()
        let name = NSLocalizedString("statisticsScreen.perfectDays", comment: "")
        view.configure(
            name: name,
            value: viewModel.statistics.perfectDays
        )
        return view
    }()
    
    private lazy var trackersCompletedView: StatisticsView = {
        let view = StatisticsView()
        let name = NSLocalizedString("statisticsScreen.trackersCompleted", comment: "")
        view.configure(
            name: name,
            value: viewModel.statistics.bestStreak
        )
        return view
    }()
    
    private lazy var averageCompletionsView: StatisticsView = {
        let view = StatisticsView()
        let name = NSLocalizedString("statisticsScreen.averageCompletions", comment: "")
        view.configure(
            name: name,
            value: viewModel.statistics.averageCompletions
        )
        return view
    }()
    
    // MARK: - Lifecycle
    init(viewModel: StatisticsViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstApear {
            viewModel.updateStatistics()
        } else {
            isFirstApear = false
        }
    }
}

// MARK: - Private Methods
private extension StatisticsViewController {
    func bind() {
        viewModel.$statistics.bind { [weak self] statistics in
            guard let self else { return }
            bestStreakView.updateValue(value: statistics.bestStreak)
            perfectDaysView.updateValue(value: statistics.perfectDays)
            trackersCompletedView.updateValue(value: statistics.trackersCompleted)
            averageCompletionsView.updateValue(value: statistics.averageCompletions)
        }
        
        viewModel.$state.bind { [weak self] state in
            guard let self else { return }
            emptyView.isHidden = state == .standart
            stackView.isHidden = state == .empty
        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(emptyView)
        view.addSubview(stackView)
        
        // MARK: - Constraints
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 77),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
        ])
        
        // MARK: - Views Configuring
        title = NSLocalizedString("statisticsScreen.title", comment: "")
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Protocols Conforming
