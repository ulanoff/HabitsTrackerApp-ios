//
//  TrackerCell.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

enum TrackerState {
    case done
    case notDone
}

struct TrackerViewConfiguration {
    let isDoneToday: Bool
    let isDoneButtonAvailable: Bool
    let daysCount: Int
}

protocol TrackerCellDelegate: AnyObject {
    func trackerCell(_ trackerCell: TrackerCell,
                     didTapDoneButton button: UIButton,
                     trackerState: TrackerState,
                     trackerId: UUID,
                     indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    // MARK: - Properties
    weak var delegate: TrackerCellDelegate?
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private var trackerState: TrackerState = .notDone
    
    var contextMenuPreview: UIView { cardView }
    
    // MARK: - UI Elements
    private lazy var cardView: UIView = {
        let cardView = UIView()
        cardView.backgroundColor = .ypSelection3
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        return cardView
    }()
    
    private lazy var quantityManagementView: UIView = {
        let quantityManagementView = UIView()
        return quantityManagementView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "❤️"
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.backgroundColor = .ypEmojiBackground
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        return emojiLabel
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = """
        Text
        Text
        """
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    private lazy var daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.text = "1 день"
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .ypBlack
        return daysLabel
    }()
    
    private lazy var isPinnedImageView: UIImageView = {
        let isPinnedImageView = UIImageView()
        isPinnedImageView.tintColor = .white
        isPinnedImageView.image = .pinnedIcon
        return isPinnedImageView
    }()
    
    private lazy var trackerButton: UIButton = {
        let trackerButton = UIButton(type: .system)
        trackerButton.setImage(.notDoneButtonIcon, for: .normal)
        trackerButton.backgroundColor = .ypSelection3
        trackerButton.tintColor = .white
        trackerButton.layer.cornerRadius = 17
        trackerButton.addTarget(self, action: #selector(didTapDoneButton(_:)), for: .touchUpInside)
        return trackerButton
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event Handlers
    @objc private func didTapDoneButton(_ sender: UIButton) {
        guard let trackerId,
              let indexPath
        else {
            assertionFailure("No trackerId or indexPath")
            return
        }
        
        delegate?.trackerCell(self, didTapDoneButton: trackerButton, trackerState: trackerState, trackerId: trackerId, indexPath: indexPath)
    }
    
    // MARK: - Public Methods
    func configure(withTracker tracker: Tracker, configuration: TrackerViewConfiguration, indexPath: IndexPath) {
        let color = tracker.color
        let buttonColor = configuration.isDoneButtonAvailable ? tracker.color : tracker.color.withAlphaComponent(0.5)
        self.indexPath = indexPath
        trackerId = tracker.id
        trackerState = configuration.isDoneToday ? .done : .notDone
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        daysLabel.text = pluralizeDay(configuration.daysCount)
        cardView.backgroundColor = color
        trackerButton.setImage(configuration.isDoneToday ? .doneButtonIcon : .notDoneButtonIcon, for: .normal)
        trackerButton.isUserInteractionEnabled = configuration.isDoneButtonAvailable
        trackerButton.backgroundColor = buttonColor
        isPinnedImageView.isHidden = !tracker.isPinned
    }
}

// MARK: - Private Methods
private extension TrackerCell {
    func pluralizeDay(_ number: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("days", comment: ""),
            number
        )
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        contentView.addSubview(cardView)
        contentView.addSubview(quantityManagementView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(isPinnedImageView)
        quantityManagementView.addSubview(daysLabel)
        quantityManagementView.addSubview(trackerButton)
        
        // MARK: - Constraints
        [cardView, quantityManagementView, emojiLabel, titleLabel, daysLabel, isPinnedImageView, trackerButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            quantityManagementView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityManagementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            isPinnedImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            isPinnedImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            
            daysLabel.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: quantityManagementView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: trackerButton.leadingAnchor, constant: -8),
            daysLabel.heightAnchor.constraint(equalToConstant: 18),
            
            trackerButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 8),
            trackerButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -12),
            trackerButton.heightAnchor.constraint(equalToConstant: 34),
            trackerButton.widthAnchor.constraint(equalToConstant: 34)
        ])
        
        // MARK: - Views Configuring
    }
}
