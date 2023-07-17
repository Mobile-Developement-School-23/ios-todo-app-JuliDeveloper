import SwiftUI

struct TodoItemRow: View {
    
    @ObservedObject var todoItem: ObservableTodoItem
        
    var body: some View {
        HStack {
            createIconButton()
            
            VStack(alignment: .leading) {
                createTextContent(todoItem.item.importance)
                
                if let deadline = todoItem.item.deadline {
                    createDeadlineContent(deadline)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 38.95)
    }
}

extension TodoItemRow {
    private var buttonImageName: String {
        var priorityImage = ""
        if todoItem.item.importance == .important {
            priorityImage = "buttonHighPriority"
        } else {
            priorityImage = "buttonOff"
        }
        
        return todoItem.item.isDone ? "buttonOn" : priorityImage
    }
    
    private var importantImageName: String {
        if todoItem.item.importance == .important {
            return "importance"
        } else if todoItem.item.importance == .unimportant {
            return "unimportant"
        }
        
        return ""
    }
    
    private func createIconButton() -> some View {
        Button(action: {
            todoItem.item.isDone.toggle()
        }) {
            Image(buttonImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
    }

    private func createDeadlineContent(_ deadline: Date) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
                .foregroundColor(Color.gray)
            Text(deadline.dateForLabelWithoutYear)
                .foregroundColor(Color.tdLabelTertiaryColor)
                .font(.system(size: 15))
        }
    }
    
    private func createTextContent(_ importance: Importance) -> some View {
        Group {
            if importance == .important || importance == .unimportant {
                HStack {
                    Image(importantImageName)
                        .padding(.trailing, 0)
                    Text(todoItem.item.text)
                        .lineLimit(3)
                        .foregroundColor(!todoItem.item.isDone ? Color.tdLabelPrimaryColor : Color.tdLabelTertiaryColor)
                        .font(.system(size: 17))
                        .strikethrough(todoItem.item.isDone, color: Color.tdLabelTertiaryColor)
                }
            } else {
                Text(todoItem.item.text)
                    .lineLimit(3)
                    .foregroundColor(!todoItem.item.isDone ? Color.tdLabelPrimaryColor : Color.tdLabelTertiaryColor)
                    .font(.system(size: 17))
                    .strikethrough(todoItem.item.isDone, color: Color.tdLabelTertiaryColor)
            }
        }
    }
}

struct TodoItemRow_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemRow(todoItem: ObservableTodoItem(item: TodoItem(id: UUID(), text: "Поливать цветы", importance: .normal, deadline: Date(), isDone: false)))
        
    }
}
