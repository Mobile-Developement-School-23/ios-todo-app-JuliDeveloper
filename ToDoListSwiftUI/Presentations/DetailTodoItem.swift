import SwiftUI

struct DetailTodoItem: View {
    
    @StateObject var todoItem: ObservableTodoItem
    
    @State var showingDeadline = false
    @State var showingCalendar = false
    @State var selectDate = Date()
    @State private var buttonActive = false
        
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                createNavBar()
                createTextView()
                createStackForEdit()
                createDeleteButton()
            }
            .padding(.all, 16)
        }
        .background(Color.tdBackPrimaryColor)
    }
}

extension DetailTodoItem {
    private func createNavBar() -> some View {
        HStack {
            Button(action: {
                print("cancel")
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
                print("save")
            }) {
                Text("Сохранить")
                    .font(.tdBodyBold)
                    .foregroundColor(Color.tdBlueColor)
            }
        }
        .padding(.bottom, 33)
    }
    
    private func createTextView() -> some View {
        ZStack {
            TextEditor(text: $todoItem.item.text)
                .background(Color.tdWhiteColor)
                .cornerRadius(16)
                .frame(minHeight: 120)
            Text(todoItem.item.text)
                .opacity(0)
                .padding(.all, 16)
                .foregroundColor(Color.tdLabelPrimaryColor)
                .font(.tdBody)
        }
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
                    }
                }
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
    }
    
    private func setTitleDeadlineButton() -> Date? {
        let calendar = Calendar.current
        let selectedDate = Date()
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            return nextDay
        }
        return nil
    }
    
    private func createCalendarView() -> some View {
        HStack {
            DatePicker("Select date", selection: $selectDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
        }
        .padding(.all, 16)
    }
    
    private func createDeleteButton() -> some View {
        Button(action: {
            
        }) {
            Text("Удалить")
                .font(.tdBody)
                .foregroundColor(buttonActive ? Color.tdRedColor : Color.tdLabelTertiaryColor)
        }
        .frame(maxWidth: .infinity, idealHeight: 56)
        .background(Color.tdBackSecondaryColor)
        .cornerRadius(16)
        .disabled(!buttonActive)
    }
}

struct DetailTodoItem_Previews: PreviewProvider {
    static var previews: some View {
        DetailTodoItem(todoItem: ObservableTodoItem(item: TodoItem(id: UUID(), text: "Заплатить за интернет", importance: .unimportant, deadline: Date().addingTimeInterval(5*86400), isDone: true)))
    }
}
