import SwiftUI

struct ListTodoItems: View {
    
    @ObservedObject var viewModel: TodoListViewModel
    
    @State private var isPresented = false
    @State private var selectedItem: TodoItem?
    
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
        if viewModel.showCompletedTasks {
            return "Скрыть "
        } else {
            return "Показать "
        }
    }
    
    // Таблица с ячейка
    private func createListItems() -> some View {
        List {
            Section {
                ForEach(viewModel.tasksToShow) { todoItem in
                    TodoItemRow(todoItem: todoItem)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .leading, content: {
                            Button {
                                let updateItem = viewModel.updateItemIsDone(from: todoItem)
                                viewModel.updateItem(updateItem)
                            } label: {
                                Label("", systemImage: "checkmark.circle.fill")
                            }
                            .background(Color.tdGreenColor)
                            .tint(.tdGreenColor)
                        })
                    
                        .swipeActions(edge: .trailing, content: {
                            Button {
                                viewModel.deleteItem(todoItem)
                            } label: {
                                Label("", systemImage: "trash.fill")
                            }
                            .tint(.tdRedColor)
                        })
                        .onTapGesture {
                            selectedItem = todoItem
                        }
                        .sheet(item: $selectedItem) { item in
                            DetailViewControllerWrapper(viewModel: viewModel, item: item)
                        }
                }
                
                createAddRow()
            } header: {
                HStack {
                    Text(" Выполнено — \(viewModel.completedListCount)")
                        .font(.system(.body))
                        .foregroundColor(Color.tdLabelTertiaryColor)
                    Spacer()
                    Button(action: {
                        viewModel.toggleShowCompletedList()
                    }) {
                        Text(completedButtonTitle)
                            .foregroundColor(Color.tdBlueColor)
                            .font(.system(.headline))
                    }
                }
                .textCase(.none)
                .padding(.bottom, 10)
            }
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
                .padding(.trailing, 12)
            Text("Новое")
                .font(.tdBody)
                .foregroundColor(Color.tdBlueColor)
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 10)
        .onTapGesture {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            DetailViewControllerWrapper(viewModel: viewModel, item: nil)
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
            .shadow(color: Color.tdShadowColor.opacity(0.6), radius: 20, x: 0, y: 8)
            .sheet(isPresented: $isPresented) {
                DetailViewControllerWrapper(viewModel: viewModel, item: nil)
            }
        }
    }
}

struct ListTodoItems_Previews: PreviewProvider {
    static var previews: some View {
        ListTodoItems(viewModel: TodoListViewModel(fileCache: FileCache(database: CoreDataService())))
    }
}
