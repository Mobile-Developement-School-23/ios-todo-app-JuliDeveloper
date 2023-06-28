import UIKit

protocol UpdateStateButtonStackViewDelegate: AnyObject {
    func stackDidTapButton(_ sender: RadioButton)
}

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
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }()
    
    private let dateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 3.5
        return stack
    }()
    
    private let importanceImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.contentMode = .center
        return view
    }()
    
    private let titleLabel = CustomLabel(text: "")
    
    private let calendarImageView: UIImageView = {
        let сonfigImage = UIImage.SymbolConfiguration(pointSize: 13)
        let image = UIImage(systemName: "calendar",
                            withConfiguration: сonfigImage)
        
        let view = UIImageView()
        view.image = image
        view.tintColor = .tdSupportSeparatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 13).isActive = true
        view.contentMode = .center
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.tdSubhead
        label.textColor = .tdLabelTertiaryColor
        return label
    }()
    
    private lazy var radioButton = RadioButton(type: .custom)
    
    private let uiMarshallingsColor: UIColorMarshallings
    
    weak var delegate: UpdateStateButtonStackViewDelegate?
    
    init(uiMarshallingsColor: UIColorMarshallings = UIColorMarshallings()) {
        self.uiMarshallingsColor = uiMarshallingsColor
        super.init(frame: .zero)
        
        axis = .horizontal
        distribution = .fill
        spacing = 12
        translatesAutoresizingMaskIntoConstraints = false
        
        radioButton.delegate = self
        
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(todoItem: TodoItem) {
        titleLabel.numberOfLines = 3
        titleLabel.text = todoItem.text
        titleLabel.textColor = uiMarshallingsColor.fromHexString(hex: todoItem.hexColor)
        
        if todoItem.isDone {
            titleLabel.attributedText = strikeText(
                strike: todoItem.text, color: .tdLabelTertiaryColor
            )
        } else {
            titleLabel.textColor = uiMarshallingsColor.fromHexString(hex: todoItem.hexColor)
            titleLabel.attributedText = NSAttributedString(string: todoItem.text)
        }
        
        radioButton.setup(from: todoItem)
        
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
    
    func resetRadioButton() {
        radioButton.isSelected = false
        radioButton.setImage(UIImage(named: "defaultImage"), for: .normal)
        titleLabel.attributedText = nil
        titleLabel.text = ""
        importanceImageView.isHidden = false
        dateStackView.isHidden = false
    }
    
    private func addElements() {
        [radioButton, titleStackView].forEach { addArrangedSubview($0) }
        
        [importanceStackView, dateStackView].forEach { titleStackView.addArrangedSubview($0) }

        [importanceImageView, titleLabel].forEach { importanceStackView.addArrangedSubview($0) }
        [calendarImageView, subtitleLabel].forEach { dateStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            
        ])
    }
    
    private func strikeText(strike: String, color: UIColor) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: strike)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSMakeRange(0, attributeString.length)
        )
        attributeString.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: color,
            range: NSMakeRange(0, attributeString.length)
        )
        return attributeString
    }
}

extension TodoStackView: UpdateStateRadioButtonDelegate {
    func buttonDidTap(_ sender: RadioButton) {
        delegate?.stackDidTapButton(sender)
    }
}
