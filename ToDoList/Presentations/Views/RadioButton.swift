import UIKit

@MainActor
protocol UpdateStateRadioButtonDelegate: AnyObject {
    func buttonDidTap(_ sender: RadioButton)
}

class RadioButton: UIButton {
    
    // MARK: - Properties
    weak var delegate: UpdateStateRadioButtonDelegate?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Helpers
    func setup(from todoItem: TodoItem) {
        var imagePriority = UIImage()
        switch todoItem.importance {
        case .important: imagePriority = UIImage(named: "buttonHighPriority") ?? UIImage()
        default:
            let image = UIImage(named: "buttonOff") ?? UIImage()
            let tintedColor = UIColor.tdSupportSeparatorColor.withAlphaComponent(1)
            imagePriority = image.withTintColor(tintedColor)
        }

        let image = todoItem.isDone ? UIImage(named: "buttonOn") : imagePriority
        
        setImage(image, for: .normal)
        isSelected = todoItem.isDone
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        delegate?.buttonDidTap(self)
    }

    // MARK: - Private methods
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
    }
}
