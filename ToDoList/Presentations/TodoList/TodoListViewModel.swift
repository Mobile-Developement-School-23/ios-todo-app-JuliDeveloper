import Foundation
import FileCachePackage

protocol TodoListViewModelNetworkingProtocol {
    func fetchTodoItems() async throws
    func addNewTodoItem(_ item: TodoItem) async throws
    func editTodoItem(_ item: TodoItem) async throws
    func deleteTodoItem(_ item: TodoItem) async throws
    func fetchTodoItem(_ item: TodoItem)
    func syncDataWithServer() async throws
    func toggleShowCompletedTasks()
}

protocol TodoListViewModelDataBaseProtocol {
    func loadData()
    func saveData()
}

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
    @Observable var isLoading: Bool = false
    
    private var uncompletedTodoItems: [TodoItem] = []
    private var isDirty = false
    
    private let fileCache: FileCacheJsonProtocol
    private let networkingService: NetworkingService
        
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : uncompletedTodoItems
    }
    
    var errorHandler: ((APIError) -> Void)?
        
    // MARK: - Initialization
    init(
        fileCache: FileCacheJsonProtocol = FileCache(),
        dataProvider: NetworkingService = DefaultNetworkingService.shared
    ) {
        self.fileCache = fileCache
        self.networkingService = dataProvider
        
        Task.detached { [weak self] in
            do {
                try await self?.fetchTodoItems()
            } catch {
                print("Error load data", error)
            }
        }
    }
    
    // MARK: - Private methods
    private func addItem(_ item: TodoItem) {
        if let newItem = fileCache.addItem(item) {
            todoItems.append(newItem)
            saveItems()
            loadItems()
        }
    }
    
    private func deleteItem(with id: String) {
        if let _ = fileCache.deleteItem(with: id) {
            todoItems.removeAll { $0.id == id }
            uncompletedTodoItems = todoItems.filter { !$0.isDone }
            saveItems()
            loadItems()
        }
    }
    
    private func saveItems() {
        do {
            try fileCache.saveToJson(to: "todoItems")
        } catch {
            print("Failed to save to JSON")
        }
    }
    
    private func loadItems() {
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

// MARK: - Helper methods for Networking
extension TodoListViewModel: @unchecked Sendable, TodoListViewModelNetworkingProtocol {
    func fetchTodoItems() async throws {
        Task.detached { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let items = try await self.networkingService.fetchTodoItems()
                
                DispatchQueue.main.async {
                    items.forEach { self.addItem($0) }
                    self.todoItems = items
                    self.uncompletedTodoItems = self.todoItems.filter { !$0.isDone }
                    self.completedTasksCount = self.todoItems.filter { $0.isDone }.count
                    self.isLoading = false
                }
                
            } catch let error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error as? APIError {
                        self.loadItems()
                        self.errorHandler?(error)
                    } else {
                        self.loadItems()
                    }
                }
            }
        }
    }
    
    func addNewTodoItem(_ item: TodoItem) async throws {
        Task.detached { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let addedItem = try await self.networkingService.addTodoItem(item)
                DispatchQueue.main.async {
                    self.addItem(addedItem)
                    self.isLoading = false
                }
                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isDirty = true
                    self.addItem(item)
                }
            }
        }
    }
    
    func editTodoItem(_ item: TodoItem) async throws {
        Task.detached { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let editedItem = try await self.networkingService.editTodoItem(item)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.addItem(editedItem)
                }
                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isDirty = true
                    self.addItem(item)
                }
            }
        }
    }
    
    func deleteTodoItem(_ item: TodoItem) async throws {
        Task.detached { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let deleteItem = try await self.networkingService.deleteTodoItem(item)
                DispatchQueue.main.async {
                    self.deleteItem(with: deleteItem.id)
                    self.isLoading = false
                }
                                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isDirty = true
                    self.deleteItem(with: item.id)
                }
            }
        }
    }
    
    // этот метод работает, но нигде не используется, он просто реализует метод из NetworkService
    func fetchTodoItem(_ item: TodoItem) {
        Task.detached { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let currentItem = try await self.networkingService.fetchTodoItem(item)
                DispatchQueue.main.async {
                    print(currentItem)
                    self.isLoading = false
                }
                                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                isLoading = false
                isDirty = true
            }
        }
    }
    
    func syncDataWithServer() async throws {
        guard isDirty else { return }
        isLoading = true
        do {
            let networkItems = try await networkingService.fetchTodoItems()
            let todoList = try await networkingService.syncTodoItems(networkItems)
            
            DispatchQueue.main.async { [weak self] in
                self?.todoItems = todoList
                self?.isDirty = false
                self?.isLoading = false
            }
            
        } catch {
            print("Failed to sync data with server")
        }
    }
    
    func updateIsDone(from todoItem: TodoItem) -> TodoItem {
        let updateTodoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance,
            deadline: todoItem.deadline,
            isDone: !todoItem.isDone,
            hexColor: todoItem.hexColor,
            lastUpdatedBy: todoItem.lastUpdatedBy
        )
        return updateTodoItem
    }
    
    func toggleShowCompletedTasks() {
        self.showCompletedTasks.toggle()
        Task.detached { [weak self] in
            do {
                try await self?.fetchTodoItems()
            } catch {
                print("Error load data", error)
            }
        }
    }
}

// Methods for work with SQLite3
extension TodoListViewModel: TodoListViewModelDataBaseProtocol {
    func loadData() {
        
    }
    
    func saveData() {
        
    }
}
