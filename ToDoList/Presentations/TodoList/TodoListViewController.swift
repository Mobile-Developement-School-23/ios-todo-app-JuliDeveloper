import UIKit

protocol TodoListViewControllerDelegate: AnyObject {
    func openDetailViewController()
}

class TodoListViewController: UIViewController {
    
    private var viewModel: TodoListViewModel
    
    weak var delegate: TodoListViewDelegate?

    //MARK: - Lifecycle
    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let customView = TodoListView(delegate: self)
        customView.configure(delegate: self)
        delegate = customView
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tdBackPrimaryColor
        configureNavBar()
        
        viewModel.$todoItems.bind { [weak self] _ in
            self?.bindViewModel()
        }
        
        bindViewModel()
    }
    
    //MARK: - Private methods
    private func bindViewModel() {
        delegate?.reloadTableView()
    }
    
    private func configureNavBar() {
        title = "Мои дела"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.navigationBar.layoutMargins.right = 32
    }
    
    private func createIsDoneAction(at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            
            let updateTodoItem = TodoItem(id: todoItem.id,text: todoItem.text, importance: todoItem.importance, isDone: !todoItem.isDone)
            
            self.viewModel.addItem(updateTodoItem)
            completion(true)
        }
        
        action.backgroundColor = .tdGreenColor
        action.image = UIImage(named: "isDoneAction")
        return action
    }
    
    private func createInfoAction(at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            
            print("Info")
            completion(true)
        }
        
        action.backgroundColor = .tdGrayLightColor
        action.image = UIImage(named: "infoAction")
        return action
    }
    
    private func createDeleteAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            self.viewModel.deleteItem(with: todoItem.id)
            completion(true)
        }
        
        action.backgroundColor = .tdRedColor
        action.image = UIImage(named: "deleteAction")
        return action
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.todoItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.todoItems.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newTodoCellIdentifier, for: indexPath) as? NewTodoItemTableViewCell else { return UITableViewCell() }
            cell.configure()
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.todoCellIdentifier, for: indexPath) as? TodoTableViewCell else { return UITableViewCell() }
            
            let todoItem = viewModel.todoItems[indexPath.row]
            let lastIndex = viewModel.todoItems.count - 1
            
            cell.configure(from: todoItem, at: indexPath, lastIndex)
            
            return cell
        }
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.todoItems.count {
            return nil
        }
        
        let idDoneAction = createIsDoneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [idDoneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.todoItems.count {
            return nil
        }
        
        let infoAction = createInfoAction(at: indexPath)
        let deleteAction = createDeleteAction(tableView: tableView, at: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
    }
}

extension TodoListViewController: TodoListViewControllerDelegate {
    func openDetailViewController() {
        let detailVC = DetailTodoItemViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}
