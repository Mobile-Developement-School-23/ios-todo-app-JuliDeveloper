import UIKit

protocol DatabaseStackViewDelegate: AnyObject {
    func sqliteSwitchDidChange(_ sender: UISwitch)
    func coreDataSwitchDidChange(_ sender: UISwitch)
}

final class DatabaseStackView: UIStackView {
    
    // MARK: - Properties
    private let separator = SeparatorView()
    
    private let sqliteStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    private let coreDataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        return stack
    }()
    
    private let switchSqlite = UISwitch()
    private let switchCoreData = UISwitch()
    
    private let sqliteLabel: UILabel = {
        let label = UILabel()
        label.text = "SQLite"
        label.font = UIFont.tdBody
        label.textColor = .tdLabelPrimaryColor
        return label
    }()
    
    private let coreDataLabel: UILabel = {
        let label = UILabel()
        label.text = "CoreData"
        label.font = UIFont.tdBody
        label.textColor = .tdLabelPrimaryColor
        return label
    }()
    
    private let storageManager: StorageManager

    weak var delegate: DatabaseStackViewDelegate?
    
    // MARK: - Lifecycle
    init(storageManager: StorageManager = StorageManager.shared) {
        self.storageManager = storageManager
        super.init(frame: .zero)
        
        axis = .vertical
        distribution = .fill
        spacing = 15
        translatesAutoresizingMaskIntoConstraints = false
        
        addElements()
        
        switchSqlite.addTarget(
            self,
            action: #selector(selectSqlite),
            for: .valueChanged
        )
        
        switchCoreData.addTarget(
            self,
            action: #selector(selectCoreData),
            for: .valueChanged
        )
        
        if storageManager.useCoreData {
            switchCoreData.isOn = true
        } else {
            switchSqlite.isOn = true
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Actions
    @objc private func selectSqlite() {
        switchCoreData.isOn = false
        
        if switchSqlite.isOn == false {
            switchCoreData.isOn = true
        }
        
        delegate?.sqliteSwitchDidChange(switchSqlite)
    }
    
    @objc private func selectCoreData() {
        switchSqlite.isOn = false
        
        if switchCoreData.isOn == false {
            switchSqlite.isOn = true
        }
        
        delegate?.coreDataSwitchDidChange(switchCoreData)
    }
    
    // MARK: - Private methods
    private func addElements() {        
        [
            sqliteStackView,
            separator,
            coreDataStackView
        ].forEach { addArrangedSubview($0) }
        
        [
            sqliteLabel,
            switchSqlite
        ].forEach { sqliteStackView.addArrangedSubview($0) }
        
        [
            coreDataLabel,
            switchCoreData
        ].forEach { coreDataStackView.addArrangedSubview($0) }
    }
}
