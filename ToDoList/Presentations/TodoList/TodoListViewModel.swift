import Foundation
import FileCachePackage

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
    
    private var uncompletedTodoItems: [TodoItem] = []
    private var isDirty = false
    
    private let fileCache: FileCache<TodoItem>
    private let dataProvider: NetworkingService
    
    weak var updateDelegate: TodoListViewModelDelegate?
    
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : uncompletedTodoItems
    }
    
    // MARK: - Initialization
    init(
        fileCache: FileCache<TodoItem> = FileCache<TodoItem>(),
        dataProvider: NetworkingService = DefaultNetworkingService.shared
    ) {
        self.fileCache = fileCache
        self.dataProvider = dataProvider
        
        Task.init { [weak self] in
            do {
                try await self?.fetchTodoItems()
            } catch {
                print("Error loaded data")
            }
        }
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

extension TodoListViewModel {
    func fetchTodoItems() async throws {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let items = try await self.dataProvider.fetchTodoItems()
                DispatchQueue.main.async {
                    self.todoItems = items
                    self.uncompletedTodoItems = self.todoItems.filter { !$0.isDone }
                    self.completedTasksCount = self.todoItems.filter { $0.isDone }.count
                    self.updateDelegate?.didUpdateTodoItems()
                }
            } catch {
                loadItems()
            }
        }
    }
    
    func addNewTodoItem(_ item: TodoItem) async throws {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let addedItem = try await self.dataProvider.addTodoItem(item)
                DispatchQueue.main.async {
                    self.todoItems.append(addedItem)
                    self.updateDelegate?.didUpdateTodoItems()
                }
                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                isDirty = true
                addItem(item)
            }
        }
    }
    
    private func syncDataWithServer() async throws {
        guard isDirty else { return }
        
        do {
            let todoList = try await dataProvider.syncTodoItems(todoItems)
            DispatchQueue.main.async { [weak self] in
                self?.todoItems = todoList
                self?.isDirty = false
                self?.updateDelegate?.didUpdateTodoItems()
            }
        } catch {
            print("Failed to sync data with server")
        }
    }
}
