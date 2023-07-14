import UIKit

protocol SelectDatabaseViewDelegate: AnyObject {
    func sqliteSwitchDidChange(_ sender: UISwitch)
    func coreDataSwitchDidChange(_ sender: UISwitch)
    func closeViewController()
}

final class SelectDatabaseView: UIView {
    
    // MARK: - Properties
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .tdBackSecondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.radius
        return view
    }()
    
    let databaseStackView = DatabaseStackView()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.tintColor = .tdBlueColor
        button.titleLabel?.font = UIFont.tdBody
        button.backgroundColor = .tdBackSecondaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = Constants.radius
        button.addTarget(
            self,
            action: #selector(save),
            for: .touchUpInside
        )
        return button
    }()
    
    weak var delegate: SelectDatabaseViewDelegate?
    
    // MARK: - Helpers
    func config() {
        backgroundColor = .tdBackPrimaryColor
        
        databaseStackView.delegate = self
        
        addElements()
        setupConstraints()
    }
    
    // MARK: - Actions
    @objc private func save() {
        delegate?.closeViewController()
    }
    
    // MARK: - Private methods
    private func addElements() {
        [
            mainView,
            saveButton
        ].forEach { addSubview($0) }
        
        mainView.addSubview(databaseStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            mainView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            databaseStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            databaseStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            databaseStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            databaseStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - DatabaseStackViewDelegate
extension SelectDatabaseView: DatabaseStackViewDelegate {
    func sqliteSwitchDidChange(_ sender: UISwitch) {
        delegate?.sqliteSwitchDidChange(sender)
    }
    
    func coreDataSwitchDidChange(_ sender: UISwitch) {
        delegate?.coreDataSwitchDidChange(sender)
    }
}
