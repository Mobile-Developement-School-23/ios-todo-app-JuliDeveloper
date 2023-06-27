import UIKit

final class TodoTableViewCell: UITableViewCell {
    
    private let mainStackView = TodoStackView()
    
    func configure(from todoItem: TodoItem, at indexPath: IndexPath, _ lastIndex: Int) {
        backgroundColor = .tdBackSecondaryColor
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        addElements()
        setupConstraints()
        
        mainStackView.setupData(todoItem: todoItem)
    }
    
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
