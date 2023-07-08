import Foundation

final class TodoItemManager {
    func addTodoItem(_ item: TodoItem, viewModel: TodoListViewModel) {
        Task {
            do {
                try await viewModel.addNewTodoItem(item)
            } catch {
                print("Error added item", error)
            }
        }
    }
    
    func updateTodoItem(_ item: TodoItem, viewModel: TodoListViewModel) {
        Task {
            do {
                try await viewModel.editTodoItem(item)
            } catch {
                print("Error updated item", error)
            }
        }
    }
    
    func deleteTodoItem(_ item: TodoItem, viewModel: TodoListViewModel) {
        Task {
            do {
                try await viewModel.deleteTodoItem(item)
            } catch {
                print("Error deleted item", error)
            }
        }
    }
}
