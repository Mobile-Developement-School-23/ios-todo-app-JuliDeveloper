import SwiftUI

struct ListTodoItems: View {
    
    @ObservedObject var todoList: TodoItemList
    
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            NavigationView {
                createListItems()
            }
            createAddButton()
        }
    }
}

extension ListTodoItems {
    
    // Заголовок для кнопки показа нужного массива
    private var completedButtonTitle: String {
        if todoList.isShowCompletedItems {
            return "Скрыть "
        } else {
            return "Показать "
        }
    }
    
    // Таблица с ячейка
    private func createListItems() -> some View {
        List {
            Section {
                ForEach(todoList.showItems) { observableTodoItem in
                    TodoItemRow(todoItem: observableTodoItem)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .leading, content: {
                            Button {
                                observableTodoItem.item.isDone.toggle()
                            } label: {
                                Label("", systemImage: "checkmark.circle.fill")
                            }
                            .background(Color.tdGreenColor)
                            .tint(.tdGreenColor)
                        })
                    
                        .swipeActions(edge: .trailing, content: {
                            Button {
                                if let index = todoList.items.firstIndex(where: { $0.item.id == observableTodoItem.item.id }) {
                                    todoList.items.remove(at: index)
                                }
                            } label: {
                                Label("", systemImage: "trash.fill")
                            }
                            .tint(.tdRedColor)
                        })
                        .onTapGesture {
                            todoList.selectedItem = observableTodoItem
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
                }
                
                createAddRow()
                    .padding(.bottom, 12)
                
            }
        header: {
                HStack {
                    Text(" Выполнено — \(todoList.completedItemsCount)")
                        .font(.system(.body))
                        .foregroundColor(Color.tdLabelTertiaryColor)
                    Spacer()
                    Button(action: {
                        todoList.isShowCompletedItems.toggle()
                    }) {
                        Text(completedButtonTitle)
                            .foregroundColor(Color.tdBlueColor)
                            .font(.system(.headline))
                    }
                }
            }
            .headerProminence(.increased)
        }
        .scrollIndicators(.never)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, -4)
        .background(Color.tdBackPrimaryColor)
        .navigationTitle("ᅠ   Мои дела")
        .navigationBarTitleDisplayMode(.large)
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
