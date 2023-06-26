import UIKit

final class TodoListView: UIView {
    
    //MARK: - Properties
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
        table.allowsSelection = false
        
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        return table
    }()
    
    //    private lazy var openButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.backgroundColor = .systemBlue
    //        button.setTitle("Go", for: .normal)
    //        button.titleLabel?.font = UIFont.tdLargeTitle
    //        button.tintColor = .white
    //        button.layer.cornerRadius = Constants.radius
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        button.addTarget(self, action: #selector(openDetailVC), for: .touchUpInside)
    //        return button
    //    }()
    
    init() {
        super.init(frame: .zero)
        addElements()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(delegate: TodoListViewController) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
    }
    
//    @objc private func openDetailVC() {
//        let detailVC = DetailTodoItemViewController(viewModel: viewModel)
//        if !viewModel.todoItems.isEmpty {
//            detailVC.todoItem = viewModel.todoItems[0]
//        }
//        let navController = UINavigationController(rootViewController: detailVC)
//        present(navController, animated: true)
//    }
}

extension TodoListView {
    private func addElements() {
        addSubview(completionTasksStackView)
        addSubview(tableView)
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
            )
        ])
    }
}
