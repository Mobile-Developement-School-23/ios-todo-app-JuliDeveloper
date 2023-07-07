import Foundation
import FileCachePackage

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
    @Observable var isLoading: Bool = false
    
    private var uncompletedTodoItems: [TodoItem] = []
    private var isDirty = false
    
    private let fileCache: FileCache<TodoItem>
    private let networkingService: NetworkingService
        
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : uncompletedTodoItems
    }
    
    // MARK: - Initialization
    init(
        fileCache: FileCache<TodoItem> = FileCache<TodoItem>(),
        dataProvider: NetworkingService = DefaultNetworkingService.shared
    ) {
        self.fileCache = fileCache
        self.networkingService = dataProvider
        
        fetchTodoItems()
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
extension TodoListViewModel: @unchecked Sendable {
    func fetchTodoItems() {
        Task { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let items = try await self.networkingService.fetchTodoItems()
                items.forEach { self.addItem($0) }
                
                DispatchQueue.main.async {
                    self.todoItems = items
                    self.uncompletedTodoItems = self.todoItems.filter { !$0.isDone }
                    self.completedTasksCount = self.todoItems.filter { $0.isDone }.count
                }
                
                isLoading = false
            } catch {
                isLoading = false
                loadItems()
            }
        }
    }
    
    func addNewTodoItem(_ item: TodoItem) {
        Task { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let addedItem = try await self.networkingService.addTodoItem(item)
                DispatchQueue.main.async {
                    self.addItem(addedItem)
                }
                
                isLoading = false
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                isLoading = false
                isDirty = true
                addItem(item)
            }
        }
    }
    
    func editTodoItem(_ item: TodoItem) {
        Task { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let editedItem = try await self.networkingService.editTodoItem(item)
                DispatchQueue.main.async {
                    self.addItem(editedItem)
                }
                
                isLoading = false
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                isLoading = false
                isDirty = true
                let updatedItem = updateIsDone(from: item)
                addItem(updatedItem)
            }
        }
    }
    
    func deleteTodoItem(_ item: TodoItem) {
        Task { [weak self] in
            guard let self = self else { return }
            isLoading = true
            do {
                let deleteItem = try await self.networkingService.deleteTodoItem(item)
                DispatchQueue.main.async {
                    self.deleteItem(with: deleteItem.id)
                }
                
                isLoading = false
                
                if isDirty {
                    try await syncDataWithServer()
                }
            } catch {
                isLoading = false
                isDirty = true
                deleteItem(with: item.id)
            }
        }
    }
    
    private func syncDataWithServer() async throws {
        guard isDirty else { return }
        isLoading = true
        do {
            let todoList = try await networkingService.syncTodoItems(fileCache.todoItemsList)
            todoList.forEach { addItem($0) }
            
            DispatchQueue.main.async { [weak self] in
                self?.todoItems = todoList
                self?.isDirty = false
            }
            
            isLoading = false
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
        fetchTodoItems()
    }
}
