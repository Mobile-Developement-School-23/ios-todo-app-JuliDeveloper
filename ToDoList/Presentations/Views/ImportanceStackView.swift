import UIKit

final class ImportanceStackView: CustomStackView {
    
    // MARK: - Properties
    private let titleLabelImportance = CustomLabel(text: "Важность")
    
    private lazy var importanceSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["", "нет", ""])
        control.setImage(UIImage(named: "unimportant"), forSegmentAt: 0)
        control.setImage(UIImage(named: "importance"), forSegmentAt: 2)
        control.selectedSegmentIndex = 1
        control.backgroundColor = .tdSupportOverlayColor
        control.tintColor = .tdBackElevatedColor
        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(equalToConstant: Constants.widthSegmentedControl).isActive = true
        control.addTarget(
            self,
            action: #selector(selectedImportance),
            for: .valueChanged
        )
        return control
    }()
    
    weak var delegate: ImportanceStackViewDelegate?

    // MARK: - Initialization
    override init() {
        super.init()
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func selectedImportance() {
        var importance = Importance.normal
        
        switch importanceSegmentedControl.selectedSegmentIndex {
        case 0: importance = .unimportant
        case 2: importance = .important
        default: importance = .normal
        }
        
        delegate?.updateImportance(importance)
    }
    
    // MARK: - Helpers
    func setSelectedSegmentIndex(from importance: Importance) {
        switch importance {
        case .important: importanceSegmentedControl.selectedSegmentIndex = 2
        case .unimportant: importanceSegmentedControl.selectedSegmentIndex = 0
        default: importanceSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    func setDefaultSelectedSegmentIndex() {
        importanceSegmentedControl.selectedSegmentIndex = 1

    }
    
    // MARK: - Private methods
    private func addElements() {
        [
            titleLabelImportance,
            importanceSegmentedControl
        ].forEach {
            addArrangedSubview($0)
        }
    }
}
