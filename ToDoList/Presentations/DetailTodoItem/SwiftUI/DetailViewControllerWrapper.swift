import SwiftUI

struct DetailViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = DetailTodoItemViewController
    
    let viewModel: TodoListViewModel
    var item: TodoItem?
    
    init(viewModel: TodoListViewModel, item: TodoItem?) {
        self.viewModel = viewModel
        self.item = item
    }

    func makeUIViewController(context: Context) -> DetailTodoItemViewController {
        let vc = DetailTodoItemViewController(viewModel: viewModel)
        vc.todoItem = item
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DetailTodoItemViewController, context: Context) {
        // этот метод просто обязательный для протокола UIViewControllerRepresentable
    }
}
