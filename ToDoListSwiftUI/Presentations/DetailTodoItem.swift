import SwiftUI

struct DetailTodoItem: View {
    
    @StateObject var todoItem: ObservableTodoItem
    
    @State var showingDeadline = false
    @State var showingCalendar = false
    @State var selectDate = Date()
    
    @Environment(\.dismiss) var dismiss
    
    var onSave: ((ObservableTodoItem) -> Void)?
    var onDelete: ((ObservableTodoItem) -> Void)?

    init(
        todoItem: ObservableTodoItem,
        onSave: @escaping ((ObservableTodoItem) -> Void),
        onDelete: @escaping ((ObservableTodoItem) -> Void)
    ) {
        self._todoItem = StateObject(wrappedValue: todoItem)
        self.onSave = onSave
        self.onDelete = onDelete
        
        if todoItem.item.deadline != nil {
            self._showingDeadline = State(initialValue: true)
            self._selectDate = State(initialValue: todoItem.item.deadline ?? Date())
        } else {
            self._showingDeadline = State(initialValue: false)
            self._selectDate = State(initialValue: Date())
        }
        
        self._showingCalendar = State(initialValue: false)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                createNavBar()
                createTextView()
                createStackForEdit()
                createDeleteButton()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.tdBackPrimaryColor)
    }
}

extension DetailTodoItem {
    private func createNavBar() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Text("Отменить")
                    .font(.tdBody)
                    .foregroundColor(Color.tdBlueColor)
            }
            Spacer()
            Text("Дeло")
                .font(.tdHeadline)
            Spacer()
            Button(action: {
                onSave?(todoItem)
                dismiss()
            }) {
                Text("Сохранить")
                    .font(.tdBodyBold)
                    .foregroundColor(!todoItem.item.text.isEmpty ? Color.tdBlueColor : Color.tdLabelTertiaryColor)
            }
            .disabled(todoItem.item.text.isEmpty)
        }
        .padding(.top, 16)
        .padding(.bottom, 33)
    }
    
    private func createTextView() -> some View {
            TextEditor(text: $todoItem.item.text)
                .background(Color.tdWhiteColor)
                .frame(minHeight: 120)
                .cornerRadius(16)
                .padding(.bottom, 16)
    }
    
    private func createStackForEdit() -> some View {
        VStack {
            createImportanceStack()
            Divider()
                .padding(.horizontal, 16)
            createDeadlineStack()
            if showingCalendar == true {
                Divider()
                    .padding(.horizontal, 16)
                createCalendarView()
            }
        }
        .background(Color.tdBackSecondaryColor)
        .cornerRadius(16)
        .padding(.bottom, 16)
    }
    
    private func createImportanceStack() -> some View {
        HStack {
            Text("Важность")
            Spacer()
            Picker("1", selection: $todoItem.item.importance) {
                ForEach(Importance.allCases) { importance in
                    viewForImportance(importance)
                }
            }
            .frame(width: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
    }
    
    private func viewForImportance(_ importance: Importance) -> some View {
        switch importance {
        case .unimportant:
            return AnyView(Image("unimportant"))
        case .normal:
            return AnyView(Text("нет")
                .foregroundColor(.tdLabelPrimaryColor)
                .font(.tdSubheadline))
        case .important:
            return AnyView(Image("importance"))
        }
    }
    
    private func createDeadlineStack() -> some View {
        HStack {
            VStack(alignment: .leading) {
                if showingDeadline == false {
                    Text("Сделать до")
                } else {
                    Text("Сделать до")
                    Button(action: {
                        withAnimation {
                            showingCalendar.toggle()
                        }
                    }) {
                        Text(setTitleDeadlineButton()?.dateForLabel ?? "")
                            .foregroundColor(Color.tdBlueColor)
                            .font(.tdFootnote)
                    }
                }
            }
            Spacer()
            Toggle("", isOn: $showingDeadline)
                .onChange(of: showingDeadline) { newValue in
                    if !newValue {
                        showingCalendar = false
                        todoItem.item.deadline = nil
                    } else {
                        todoItem.item.deadline = selectDate
                    }
                }
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
    }
    
    private func setTitleDeadlineButton() -> Date? {
        let calendar = Calendar.current
        let selectedDate = selectDate
        
        if todoItem.item.deadline != nil {
            return todoItem.item.deadline
        } else if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            return nextDay
        }
        
        return nil
    }
    
    private func createCalendarView() -> some View {
        HStack {
            DatePicker("Select date", selection: $selectDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .environment(\.locale, .init(identifier: "ru"))
                .onChange(of: selectDate) { newValue in
                    todoItem.item.deadline = newValue
                }
        }
        .padding(.all, 16)
    }
    
    private func createDeleteButton() -> some View {
        Button(action: {
            onDelete?(todoItem)
            dismiss()
        }) {
            Text("Удалить")
                .font(.tdBody)
                .foregroundColor(!todoItem.item.text.isEmpty ? Color.tdRedColor : Color.tdLabelTertiaryColor)
        }
        .frame(maxWidth: .infinity, idealHeight: 56)
        .background(Color.tdBackSecondaryColor)
        .cornerRadius(16)
        .disabled(todoItem.item.text.isEmpty)
    }
}

struct DetailTodoItem_Previews: PreviewProvider {
    static var previews: some View {
        DetailTodoItem(todoItem: ObservableTodoItem(item: TodoItem(id: UUID(), text: "Заплатить за интернет", importance: .unimportant, deadline: Date().addingTimeInterval(5*86400), isDone: true)), onSave: { _ in }, onDelete: { _ in })
    }
}
