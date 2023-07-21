import SwiftUI

struct ContentView: View {
    
    private let todoItems = TodoItem.getList()
    
    var body: some View {
        ListTodoItems(todoList: TodoItemList(items: TodoItem.getList().map { ObservableTodoItem(item: $0) }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
