import UIKit

class RadioButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setupImage(from todoItem: TodoItem) {
        if todoItem.importance == .important {
            setImage(UIImage(named: "buttonHighPriority"), for: .normal)
        } else {
            setImage(UIImage(named: "buttonOff"), for: .normal)
        }
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        isSelected = false
        self.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
    }

    @objc private func buttonTapped() {
        isSelected.toggle()
        setImage(UIImage(
            named: "buttonOn"),
                 for: .selected
        )
        
    }
}
