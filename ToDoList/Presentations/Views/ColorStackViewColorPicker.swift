import UIKit

final class ColorStackViewColorPicker: UIStackView {
    
    //MARK: - Properties
    private let hexCurrentColorLabel = CustomLabel(text: "")
    
    private let currentColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 34).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.tdSupportOverlayColor.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 34 / 2
        return view
    }()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func setColor(_ color: UIColor, hexColor: String) {
        currentColorView.backgroundColor = color
        hexCurrentColorLabel.text = hexColor
    }
    
    //MARK: - Private methods
    private func configure() {
        axis = .horizontal
        distribution = .fill
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addElements() {
        [
            currentColorView,
            hexCurrentColorLabel
        ].forEach {
            addArrangedSubview($0)
        }
    }
}
