import SwiftUI

struct TodoItemRow: View {
    
    var todoItem: TodoItem
        
    var body: some View {
        HStack {
            createIconIsDone()
            
            VStack(alignment: .leading, spacing: 5) {
                createTextContent(todoItem.importance)
                
                if let deadline = todoItem.deadline {
                    createDeadlineContent(deadline)
                }
            }
            Spacer()
            Image("navArrow")
                .padding(.trailing, 12)
                .aspectRatio(contentMode: .fit)
        }
        .background(Color.tdBackSecondaryColor)
        .padding(.vertical, 10)
    }
}

extension TodoItemRow {
    private var buttonImageName: String {
        var priorityImage = ""
        if todoItem.importance == .important {
            priorityImage = "buttonHighPriority"
        } else {
            priorityImage = "buttonOff"
        }
        
        return todoItem.isDone ? "buttonOn" : priorityImage
    }
    
    private var importantImageName: String {
        if todoItem.importance == .important {
            return "importance"
        } else if todoItem.importance == .unimportant {
            return "unimportant"
        }
        
        return ""
    }
    
    private func createIconIsDone() -> some View {
        Image(buttonImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .padding(.trailing, 12)
    }

    private func createDeadlineContent(_ deadline: Date) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar")
                .frame(width: 12)
                .foregroundColor(Color.gray)
            Text(deadline.dateForLabelWithoutYear)
                .foregroundColor(Color.tdLabelTertiaryColor)
                .font(.system(size: 15))
        }
    }
    
    private func createTextContent(_ importance: Importance) -> some View {
        Group {
            if importance == .important || importance == .unimportant {
                HStack(spacing: 0) {
                    Text("")
                    Image(importantImageName)
                        .padding(.trailing, 5)
                    Text(todoItem.text)
                        .lineLimit(3)
                        .foregroundColor(!todoItem.isDone ? Color(hex: todoItem.hexColor) : Color.tdLabelTertiaryColor)
                        .font(.system(size: 17))
                        .strikethrough(todoItem.isDone, color: Color.tdLabelTertiaryColor)
                }
            } else {
                Text(todoItem.text)
                    .lineLimit(3)
                    .foregroundColor(!todoItem.isDone ? Color(hex: todoItem.hexColor) : Color.tdLabelTertiaryColor)
                    .font(.system(size: 17))
                    .strikethrough(todoItem.isDone, color: Color.tdLabelTertiaryColor)
            }
        }
    }
}

struct TodoItemRow_Previews: PreviewProvider {
    static var previews: some View {
        TodoItemRow(todoItem: TodoItem(id: UUID().uuidString, text: "Поливать цветы", importance: .important, deadline: Date(), isDone: false, lastUpdatedBy: "1"))
        
    }
}
