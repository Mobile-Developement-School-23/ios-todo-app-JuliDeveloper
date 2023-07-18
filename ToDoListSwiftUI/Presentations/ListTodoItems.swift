import SwiftUI

struct ListTodoItems: View {
    
    @ObservedObject var todoList: TodoItemList
    
    @State private var isPresented = false

    var body: some View {
        ZStack {
            ScrollView {
                createTitle()
                createStackCompletedItems()
                createListItems()
            }
            .background(Color.tdBackPrimaryColor)
            .scrollIndicators(.never)
            
            createAddButton()
        }
    }
}

extension ListTodoItems {
    
    // Заголовок для кнопки показа нужного массива
    private var completedButtonTitle: String {
        if todoList.isShowCompletedItems {
            return "Скрыть"
        } else {
            return "Показать"
        }
    }
    
    // Заголовок - аля navBar
    private func createTitle() -> some View {
        HStack {
            Text("Мои дела")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.tdLabelPrimaryColor)
            Spacer()
        }
        .padding(.top, 42)
        .padding(.bottom, 18)
        .padding(.horizontal, 32)
    }
    
    // Стек с выполненными задачами
    private func createStackCompletedItems() -> some View {
        HStack {
            Text("Выполнено — \(todoList.completedItemsCount)")
                .foregroundColor(Color.tdLabelTertiaryColor)
            Spacer()
            Button(completedButtonTitle, action: { todoList.isShowCompletedItems.toggle() })
                .foregroundColor(Color.tdBlueColor)
                .font(.tdSubheadline)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 12)
    }
    
    // Таблицу с ячейка
    private func createListItems() -> some View {
        VStack {
            VStack(alignment: .leading) {
                ForEach(todoList.showItems) { observableTodoItem in
                    TodoItemRow(todoItem: observableTodoItem)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button {
                                observableTodoItem.item.isDone.toggle()
                            } label: {
                                Label("Выполнить", systemImage: "checkmark.circle.fill")
                            }
                            
                            Button {
                                todoList.selectedItem = observableTodoItem
                            } label: {
                                Label("Редактировать", systemImage: "pencil")
                            }
                            .sheet(item: $todoList.selectedItem) { selectedItem in
                                DetailTodoItem(
                                    todoItem: selectedItem,
                                    onSave: { _ in },
                                    onDelete: { deletedItem in
                                        deleteItem(deletedItem.item)
                                    }
                                )
                            }
                            
                            Button {
                                if let index = todoList.items.firstIndex(where: { $0.item.id == observableTodoItem.item.id }) {
                                    todoList.items.remove(at: index)
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash.fill")
                            }
                        }
                        .onTapGesture {
                            todoList.selectedItem = observableTodoItem
                        }
                    
                    Divider()
                        .padding(.leading, 52)
                }
                
                createAddRow()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 16)
            .background(Color.tdBackSecondaryColor)
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .sheet(item: $todoList.selectedItem) { selectedItem in
            DetailTodoItem(
                todoItem: selectedItem,
                onSave: { _ in },
                onDelete: { deletedItem in
                    deleteItem(deletedItem.item)
                }
            )
        }
    }
    
    // Ячейка для добавления новой задачи
    private func createAddRow() -> some View {
        HStack {
            Image("addItem")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.leading, 16)
                .padding(.trailing, 12)
            Text("Новое")
                .font(.tdBody)
                .foregroundColor(Color.tdBlueColor)
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.top, 12)
        .onTapGesture {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            DetailTodoItem(
                todoItem: ObservableTodoItem(item: TodoItem(id: UUID(), text: "", importance: .normal, deadline: nil, isDone: false)),
                onSave: { newItem in
                    addNewItem(newItem.item)
                },
                onDelete: { _ in }
            )
        }
    }
    
    // Кнопка для добавления новой задачи
    private func createAddButton() -> some View {
        GeometryReader { geometry in
            Button(action: {
                isPresented = true
            }) {
                Image("addItem")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height - 54)
            .sheet(isPresented: $isPresented) {
                DetailTodoItem(
                    todoItem: ObservableTodoItem(item: TodoItem(id: UUID(), text: "", importance: .normal, deadline: nil, isDone: false)),
                    onSave: { newItem in
                        addNewItem(newItem.item)
                    },
                    onDelete: { _ in }
                )
            }
        }
    }
    
    private func addNewItem(_ item: TodoItem) {
        if todoList.items.contains(where: { $0.item.id != item.id }) {
            todoList.items.append(ObservableTodoItem(item: item))
        }
    }
    
    private func deleteItem(_ item: TodoItem) {
        if let index = todoList.items.firstIndex(where: { $0.item.id == item.id }) {
            todoList.items.remove(at: index)
        }
    }
}

struct ListTodoItems_Previews: PreviewProvider {
    static var previews: some View {
        ListTodoItems(todoList: TodoItemList(items: TodoItem.getList().map { ObservableTodoItem(item: $0) }))
    }
}
