import UIKit

protocol UpdateStateRadioButtonDelegate: AnyObject {
    func buttonDidTap(_ sender: RadioButton)
}

class RadioButton: UIButton {
    
    weak var delegate: UpdateStateRadioButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(from todoItem: TodoItem) {
        
        var imagePriority = UIImage()
        switch todoItem.importance {
        case .important: imagePriority = UIImage(named: "buttonHighPriority") ?? UIImage()
        default: imagePriority = UIImage(named: "buttonOff") ?? UIImage()
        }

        let image = todoItem.isDone ? UIImage(named: "buttonOn") : imagePriority
        
        setImage(image, for: .normal)
        isSelected = todoItem.isDone
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        self.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
    }

    @objc private func buttonTapped() {
        delegate?.buttonDidTap(self)
    }
}
