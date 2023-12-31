import UIKit

final class SelectColorStackView: CustomStackView {
    
    // MARK: - Properties
    private let titleLabelColor = CustomLabel(text: "Цвет текста")
    
    private lazy var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: Constants.heightRoundButton).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.tdSupportOverlayColor.withAlphaComponent(0.1).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = Constants.heightRoundButton / 2
        button.addTarget(
            self,
            action: #selector(openColorPicker),
            for: .touchUpInside
        )
        return button
    }()
    
    var buttonAction: ((CustomColorPickerViewController) -> Void)?
        
    // MARK: - Initialization
    override init() {
        super.init()
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func openColorPicker() {
        let colorPickerVC = CustomColorPickerViewController()

        if let sheet = colorPickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        buttonAction?(colorPickerVC)
    }
    
    // MARK: - Private methods
    private func addElements() {
        [titleLabelColor, colorButton].forEach {
            addArrangedSubview($0)
        }
    }
}
