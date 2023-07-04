import UIKit

@MainActor
protocol UpdateStateButtonCellDelegate: AnyObject {
    func cellDidTapButton(_ sender: RadioButton, in cell: TodoTableViewCell)
}

final class TodoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private let mainStackView = TodoStackView()
    
    weak var delegate: UpdateStateButtonCellDelegate?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        mainStackView.resetRadioButton()
    }
    
    // MARK: Helpers
    func configure(from todoItem: TodoItem, at indexPath: IndexPath, _ lastIndex: Int) {
        backgroundColor = .tdBackSecondaryColor
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        addElements()
        setupConstraints()
        
        mainStackView.setupData(todoItem: todoItem)
        mainStackView.delegate = self
    }
    
    // MARK: - Private methods
    private func addElements() {
        contentView.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -38.95
            ),
            mainStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            )
        ])
    }
}

// MARK: - UpdateStateButtonStackViewDelegate
extension TodoTableViewCell: UpdateStateButtonStackViewDelegate {
    func stackDidTapButton(_ sender: RadioButton) {
        delegate?.cellDidTapButton(sender, in: self)
    }
}
