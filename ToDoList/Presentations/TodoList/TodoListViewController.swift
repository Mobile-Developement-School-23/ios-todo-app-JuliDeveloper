import UIKit

protocol TodoListViewControllerDelegate: AnyObject {
    func openDetailViewController(_ todoItem: TodoItem?)
}

class TodoListViewController: UIViewController {
    
    private var isMoving = false
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
    
    // MARK: - Actions
    @objc private func edit() {
        isMoving.toggle()
        delegate?.setEditing(isMoving)
        
        navigationItem.rightBarButtonItem?.image = isMoving ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "gearshape.fill")
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
        
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(edit)
        )
        editButton.tintColor = .tdBlueColor
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func createIsDoneAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }

            _ = self.viewModel.updateIsDone(from: todoItem)
            completion(true)
        }
        
        action.backgroundColor = .tdGreenColor
        action.image = UIImage(named: "isDoneAction")
        return action
    }
    
    private func createInfoAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }

            print("info")
            
            completion(true)
        }
        
        action.backgroundColor = .tdGrayLightColor
        action.image = UIImage(named: "infoAction")
        return action
    }
    
    private func createDeleteAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.todoItems[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }

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
            
            cell.delegate = self
            cell.configure(from: todoItem, at: indexPath, lastIndex)
            
            return cell
        }
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.todoItems.count {
            openDetailViewController(nil)
        } else {
            let todoItem = viewModel.todoItems[indexPath.row]
            openDetailViewController(todoItem)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.todoItems.count {
            return nil
        }
        
        let idDoneAction = createIsDoneAction(tableView: tableView, at: indexPath)
        return UISwipeActionsConfiguration(actions: [idDoneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.todoItems.count {
            return nil
        }
        
        let infoAction = createInfoAction(tableView: tableView, at: indexPath)
        let deleteAction = createDeleteAction(tableView: tableView, at: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           if indexPath.row == viewModel.todoItems.count {
               return .none
           } else {
               return .delete
           }
       }
       
       func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
           isMoving && indexPath.row != viewModel.todoItems.count
       }
       
       
       func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
           if proposedDestinationIndexPath.row >= viewModel.todoItems.count {
               return sourceIndexPath
           }
           return proposedDestinationIndexPath
       }
       
       func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
           viewModel.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
           tableView.reloadData()
       }
}

extension TodoListViewController: TodoListViewControllerDelegate {
    func openDetailViewController(_ todoItem: TodoItem?) {
        let detailVC = DetailTodoItemViewController(viewModel: viewModel)
        detailVC.todoItem = todoItem
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

extension TodoListViewController: UpdateStateButtonCellDelegate {
    func cellDidTapButton(_ sender: RadioButton, in cell: TodoTableViewCell) {
        guard let indexPath = delegate?.getIndexPath(for: cell) else { return }
        
        let todoItem = viewModel.todoItems[indexPath.row]
        let updateTodoItem = viewModel.updateIsDone(from: todoItem)
        
        var imagePriority = UIImage()
        switch updateTodoItem.importance {
        case .important: imagePriority = UIImage(named: "buttonHighPriority") ?? UIImage()
        default: imagePriority = UIImage(named: "buttonOff") ?? UIImage()
        }
        
        let image = updateTodoItem.isDone ? UIImage(named: "buttonOn") : imagePriority
        sender.setImage(image, for: .normal)
        
        sender.isSelected.toggle()
    }
}
