import Foundation
import FileCachePackage

protocol TodoListViewModelNetwork {
    func fetchTodoItems()
    func addNewTodoItem(_ item: TodoItem)
}

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
    
    private var uncompletedTodoItems: [TodoItem] = []
    
    private let fileCache: FileCache<TodoItem>
    private let networkingService: NetworkingServiceProtocol
    
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : uncompletedTodoItems
    }
    
    // MARK: - Initialization
    init(
        fileCache: FileCache<TodoItem> = FileCache<TodoItem>(),
        networkingService: NetworkingServiceProtocol = DefaultNetworkingService.shared
    ) {
        self.fileCache = fileCache
        self.networkingService = networkingService
        //loadItems()
        fetchTodoItems()
    }
    
    // MARK: - Methods
    func toggleShowCompletedTasks() {
        showCompletedTasks.toggle()
        loadItems()
    }
    
    func addItem(_ item: TodoItem) {
        if let newItem = fileCache.addItem(item) {
            todoItems.append(newItem)
            saveItems()
            loadItems()
        }
    }
    
    func deleteItem(with id: String) {
        if let _ = fileCache.deleteItem(with: id) {
            todoItems.removeAll { $0.id == id }
            uncompletedTodoItems = todoItems.filter { !$0.isDone }
            saveItems()
            loadItems()
        }
    }
    
    func updateIsDone(from todoItem: TodoItem) -> TodoItem {
        let updateTodoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance,
            deadline: todoItem.deadline,
            isDone: !todoItem.isDone,
            hexColor: todoItem.hexColor
        )
        addItem(updateTodoItem)
        loadItems()
        return updateTodoItem
    }
    
    func saveItems() {
        do {
            try fileCache.saveToJson(to: "todoItems")
        } catch {
            print("Failed to save to JSON")
        }
    }
    
    func loadItems() {
        do {
            try fileCache.loadFromJson(from: "todoItems")
            todoItems = fileCache.todoItemsList
            uncompletedTodoItems = todoItems.filter { !$0.isDone }
            completedTasksCount = todoItems.filter { $0.isDone }.count
        } catch {
            print("Failed to load to JSON")
        }
    }
}

extension TodoListViewModel: TodoListViewModelNetwork {
    func fetchTodoItems() {
        do {
            networkingService.getTodoItemList { [weak self] result in
                switch result {
                case .success(let todoItems):
                    DispatchQueue.main.async {
                        self?.todoItems = todoItems
                        self?.uncompletedTodoItems = todoItems.filter { !$0.isDone }
                        self?.completedTasksCount = todoItems.filter { $0.isDone }.count
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateTodoItemList(from list: [TodoItem]) {
        do {
            networkingService.updateTodoItemList(list) { result in
                switch result {
                case .success(_):
                    print("Success")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addNewTodoItem(_ item: TodoItem) {
        do {
            networkingService.putTodoItemList(item) { result in
                switch result {
                case .success(_):
                    print("Success")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        updateTodoItemList(from: [item])        
    }
}
