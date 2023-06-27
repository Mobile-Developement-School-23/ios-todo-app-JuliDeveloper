import UIKit

final class TodoStackView: UIStackView {
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    private let importanceStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    private let dateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    private let importanceImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        return view
    }()
    
    private let titleLabel = CustomLabel(text: "")
    
    private let calendarImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "calendar")
        view.tintColor = .tdLabelTertiaryColor
        view.contentMode = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "11 июня"
        label.font = UIFont.tdSubhead
        label.textColor = .tdLabelTertiaryColor
        return label
    }()
    
    private lazy var radioButton = RadioButton(type: .custom)
    
    init() {
        super.init(frame: .zero)
        
        axis = .horizontal
        distribution = .fill
        spacing = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(todoItem: TodoItem) {
        titleLabel.numberOfLines = 3
        
        titleLabel.text = todoItem.text
        radioButton.setupImage(from: todoItem)
        
        switch todoItem.importance {
        case .important:
            importanceImageView.isHidden = false
            importanceImageView.image = UIImage(named: "importance")
        case .normal:
            importanceImageView.isHidden = true
        case .unimportant:
            importanceImageView.isHidden = false
            importanceImageView.image = UIImage(named: "unimportant")
        }
        
        if todoItem.deadline != nil {
            dateStackView.isHidden = false
            subtitleLabel.text = todoItem.deadline?.dateForLabel
        } else {
            dateStackView.isHidden = true
        }
    }
    
    private func addElements() {
        [radioButton, titleStackView].forEach { addArrangedSubview($0) }
        
        [importanceStackView, dateStackView].forEach { titleStackView.addArrangedSubview($0) }

        [importanceImageView, titleLabel].forEach { importanceStackView.addArrangedSubview($0) }
        [calendarImageView, subtitleLabel].forEach { dateStackView.addArrangedSubview($0) }
    }
    
}