import UIKit

final class CompletionTasksStackView: UIStackView {
    private let completionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.tdSubhead
        label.textColor = .tdLabelTertiaryColor
        return label
    }()
    
    private lazy var showButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.tdBlueColor, for: .normal)
        button.setTitle("Показать", for: .normal)
        button.titleLabel?.font = .tdSubheadline
        button.addTarget(
            self,
            action: #selector(showCompletedTasks),
            for: .touchUpInside
        )
        return button
    }()
    
    private var isShowCompletedTasks = false
    
    weak var delegate: TodoListViewControllerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        [completionLabel, showButton].forEach { addArrangedSubview($0) }
        
        setAmountTasks()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAmountTasks() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let count = self.delegate?.updateCompletedTasksLabel() ?? 0
            self.completionLabel.text = "Выполнено — \(count)"
        }
    }
        
    @objc private func showCompletedTasks() {
        isShowCompletedTasks.toggle()
        let title = isShowCompletedTasks ? "Cкрыть" : "Показать"
        showButton.setTitle(title, for: .normal)
        
        delegate?.showCompletionItem()
    }
}
