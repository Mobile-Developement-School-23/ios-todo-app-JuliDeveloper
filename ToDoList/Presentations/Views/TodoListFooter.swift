import UIKit

final class TodoListFooter: UITableViewHeaderFooterView {
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let plusImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "addItem")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: CustomLabel = {
        let label = CustomLabel(text: "Новое")
        label.textColor = .tdBlueColor
        return label
    }()
    
    func configure() {
        contentView.backgroundColor = .tdBackSecondaryColor
        contentView.layer.cornerRadius = Constants.radius
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        isUserInteractionEnabled = true

        addElements()
        setupConstraints()
    }
    
    private func addElements() {
        contentView.addSubview(mainStackView)
        [
            plusImageView,
            titleLabel
        ].forEach { mainStackView.addArrangedSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
       
            mainStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            mainStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),
            
            plusImageView.widthAnchor.constraint(
                equalToConstant: 24
            )
        ])
    }
}
