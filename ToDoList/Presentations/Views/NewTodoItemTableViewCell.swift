import UIKit

final class NewTodoItemTableViewCell: UITableViewCell {
    
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
        backgroundColor = .tdBackSecondaryColor
        
        contentView.addSubview(mainStackView)
        [plusImageView, titleLabel].forEach { mainStackView.addArrangedSubview($0) }
        
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
        
        separatorInset = UIEdgeInsets(
            top: 0, left: bounds.size.width + 100, bottom: 0, right: 0
        )
        
        layer.cornerRadius = Constants.radius
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
