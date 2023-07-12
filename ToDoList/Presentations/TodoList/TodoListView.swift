import UIKit

final class TodoListView: UIView {
    
    // MARK: - Properties
    private let completionTasksStackView = CompletionTasksStackView()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(
            TodoTableViewCell.self,
            forCellReuseIdentifier: Constants.todoCellIdentifier
        )
        table.register(
            NewTodoItemTableViewCell.self,
            forCellReuseIdentifier: Constants.newTodoCellIdentifier
        )
        
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = Constants.radius
        table.showsVerticalScrollIndicator = false
        table.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        return table
    }()
    
    private lazy var openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "addItem"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.zPosition = 5
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowColor = UIColor.tdShadowColor.cgColor
        button.layer.shadowRadius = 10
        
        button.addTarget(self, action: #selector(openDetailVC), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: TodoListViewControllerDelegate?
    
    // MARK: - Initialization
    init(delegate: TodoListViewControllerDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = .tdBackPrimaryColor
        addElements()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configure(delegate: TodoListViewController) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
        completionTasksStackView.delegate = delegate
    }
    
    // MARK: - Actions
    @objc private func openDetailVC() {
        delegate?.openDetailViewController(
            nil,
            transitioningDelegate: nil,
            presentationStyle: .automatic
        )
    }
}

// MARK: - Private methods
extension TodoListView {
    private func addElements() {
        addSubview(completionTasksStackView)
        addSubview(tableView)
        addSubview(openButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completionTasksStackView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor, constant: 8
            ),
            completionTasksStackView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32
            ),
            completionTasksStackView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32
            ),
            
            tableView.topAnchor.constraint(
                equalTo: completionTasksStackView.bottomAnchor,
                constant: 12
            ),
            tableView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            tableView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            
            openButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
            openButton.centerXAnchor.constraint(
                equalTo: centerXAnchor
            )
        ])
    }
}

// MARK: - Private methods
extension TodoListView: TodoListViewDelegate {    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func setEditing(_ state: Bool) {
        tableView.isEditing = state
    }
    
    func getIndexPath(for cell: TodoTableViewCell) -> IndexPath? {
        tableView.indexPath(for: cell)
    }
    
    func updateCompletedLabel(count: Int) {
        DispatchQueue.main.async {
            if let label = self.completionTasksStackView.subviews.first as? UILabel {
                label.text = "Выполнено — \(count)"
            }
        }
    }
}
