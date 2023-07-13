import UIKit

protocol SelectDatabaseViewControllerDelegate: AnyObject {
    func didUpdateDatabaseService(_ controller: SelectDataBaseViewController, service: DatabaseService)
}

class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    private let storageManager: StorageManager
    private var viewModel: TodoListViewModelProtocol
    
    var selectedCell: TodoTableViewCell?

    weak var delegate: TodoListViewDelegate?
    
    // MARK: - Lifecycle
    init(
        storageManager: StorageManager = StorageManager.shared,
        viewModel: TodoListViewModelProtocol
    ) {
        self.storageManager = storageManager
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
        configureNavBar()
        
        checDatabase()
        
        viewModel.bindTodoList({ [weak self] _ in
            self?.bindViewModel()
        })

        viewModel.bindCompletedTodoListCount({[weak self] _ in
            self?.delegate?.updateCompletedLabel(
                count: self?.viewModel.completedListCount ?? 0
            )
        })
        
        bindViewModel()
    }
    
    @objc private func footerTapped() {
        openDetailViewController(
            nil,
            transitioningDelegate: nil,
            presentationStyle: .automatic
        )
    }
    
    @objc private func selectDataBase() {
        let selectDatabase = SelectDataBaseViewController(viewModel: viewModel)
        selectDatabase.delegate = self
        let navVC = UINavigationController(rootViewController: selectDatabase)
        present(navVC, animated: true)
    }
    
    // MARK: - Private methods
    private func bindViewModel() {
        DispatchQueue.main.async {
            self.delegate?.reloadTableView()
        }
    }
    
    private func configureNavBar() {
        title = "Мои дела"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins.left = 32
        navigationController?.navigationBar.layoutMargins.right = 32
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "filter"),
            style: .done,
            target: self,
            action: #selector(selectDataBase)
        )
    }
    
    private func checDatabase() {
        if storageManager.useCoreData {
            viewModel = TodoListViewModel(database: CoreDataService())
        } else {
            viewModel = TodoListViewModel(database: SQLiteService())
        }
    }
    
    private func createIsDoneAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.tasksToShow[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            changeIsDone(for: todoItem)
            
            completion(true)
        }
        
        action.backgroundColor = .tdGreenColor
        action.image = UIImage(named: "isDoneAction")
        return action
    }
    
    private func createDeleteAction(tableView: UITableView, at indexPath: IndexPath) -> UIContextualAction {
        let todoItem = viewModel.tasksToShow[indexPath.row]
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            viewModel.deleteItem(todoItem)
            completion(true)
        }
        
        action.backgroundColor = .tdRedColor
        action.image = UIImage(named: "deleteAction")
        return action
    }
    
    private func changeIsDone(for item: TodoItem) {
        let updateTodoItem = viewModel.updateItemIsDone(from: item)
        viewModel.updateItem(updateTodoItem)
    }
}

// MARK: - UITableViewDataSource
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tasksToShow.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.tasksToShow.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newTodoCellIdentifier, for: indexPath) as? NewTodoItemTableViewCell else { return UITableViewCell() }
            
            cell.configure()
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.todoCellIdentifier, for: indexPath) as? TodoTableViewCell else { return UITableViewCell() }
            
            let todoItem = viewModel.tasksToShow[indexPath.row]
            let lastIndex = viewModel.tasksToShow.count - 1
            
            cell.delegate = self
            cell.configure(from: todoItem, at: indexPath, lastIndex)
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.tasksToShow.count {
            openDetailViewController(
                nil,
                transitioningDelegate: nil,
                presentationStyle: .automatic
            )
        } else {
            let todoItem = viewModel.tasksToShow[indexPath.row]
            selectedCell = tableView.cellForRow(at: indexPath) as? TodoTableViewCell

            openDetailViewController(
                todoItem,
                transitioningDelegate: self,
                presentationStyle: .custom
            )
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.tasksToShow.count {
            return nil
        }
        
        let idDoneAction = createIsDoneAction(tableView: tableView, at: indexPath)
        return UISwipeActionsConfiguration(actions: [idDoneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == viewModel.tasksToShow.count {
            return nil
        }
        
        let deleteAction = createDeleteAction(tableView: tableView, at: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let destinationViewController = animator.previewViewController else {
            return
        }
        
        animator.addAnimations {
            self.show(destinationViewController, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let todoItem = viewModel.tasksToShow[indexPath.row]
        
        let previewProvider: () -> UIViewController? = {
            let vc = PreviewViewController()
            vc.todoItem = todoItem
            return vc
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
            guard let self = self else { return UIMenu() }
            
            let isDoneAction = UIAction(
                title: "Выполнить",
                image: UIImage(systemName: "checkmark.circle.fill")
            ) { _ in
                self.changeIsDone(for: todoItem)
            }
            
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) {  _ in
                self.openDetailViewController(
                    todoItem,
                    transitioningDelegate: nil,
                    presentationStyle: .automatic
                )
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash.fill")
            ) {  _ in
                self.viewModel.deleteItem(todoItem)
            }
            
            return UIMenu(children: [
                isDoneAction,
                editAction,
                deleteAction
            ])
        }
    }
}

// MARK: - TodoListViewControllerDelegate
extension TodoListViewController: TodoListViewControllerDelegate {
    func openDetailViewController(_ todoItem: TodoItem?, transitioningDelegate: UIViewControllerTransitioningDelegate?, presentationStyle: UIModalPresentationStyle) {
        let detailVC = DetailTodoItemViewController(viewModel: viewModel)
        detailVC.todoItem = todoItem
        detailVC.loadDelegate = self
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = presentationStyle
        navController.transitioningDelegate = transitioningDelegate
        present(navController, animated: true)
    }
    
    func showCompletionItem() {
        viewModel.toggleShowCompletedList()
        bindViewModel()
    }
    
    func updateCompletedTasksLabel() -> Int {
        viewModel.completedListCount
    }
}

// MARK: - UpdateStateButtonCellDelegate
extension TodoListViewController: UpdateStateButtonCellDelegate {
    func cellDidTapButton(_ sender: RadioButton, in cell: TodoTableViewCell) {
        guard let indexPath = delegate?.getIndexPath(for: cell) else { return }
        
        let todoItem = viewModel.tasksToShow[indexPath.row]
        
        changeIsDone(for: todoItem)
        
        var imagePriority = UIImage()
        switch todoItem.importance {
        case .important: imagePriority = UIImage(named: "buttonHighPriority") ?? UIImage()
        default: imagePriority = UIImage(named: "buttonOff") ?? UIImage()
        }
        
        let image = todoItem.isDone ? UIImage(named: "buttonOn") : imagePriority
        sender.setImage(image, for: .normal)
        
        sender.isSelected.toggle()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension TodoListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        CustomTransition()
    }
}

extension TodoListViewController: SelectDatabaseViewControllerDelegate {
    func didUpdateDatabaseService(_ controller: SelectDataBaseViewController, service: DatabaseService) {
        viewModel.updateDatabaseService(service: service)
        viewModel.fetchTodoItems()
    }
}
