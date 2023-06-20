import UIKit

final class SelectColorStackView: CustomStackView {
    
    //MARK: - Properties
    private let titleLabelColor = CustomLabel(text: "Цвет текста")
    
    private let colorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()
    
    private let hexColorLabel = CustomLabel(text: "#000000")
    
    private lazy var colorButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.tdSupportOverlayColor.withAlphaComponent(0.5).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 34 / 2
        button.addTarget(
            self,
            action: #selector(openColorPicker),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    override init() {
        super.init()
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Heplers
    private func addElements() {
        [titleLabelColor, colorStackView].forEach {
            addArrangedSubview($0)
        }
        
        [hexColorLabel, colorButton].forEach {
            colorStackView.addArrangedSubview($0)
        }
    }
    
    @objc private func openColorPicker() {
        print("open colorPicker")
    }
}

