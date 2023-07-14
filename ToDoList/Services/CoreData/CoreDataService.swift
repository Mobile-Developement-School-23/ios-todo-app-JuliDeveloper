import Foundation
import CoreData

final class CoreDataService: NSObject {
    
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    private func convert(from todoItemCoreData: TodoItemCoreData?) -> TodoItem? {
        guard
            let id = todoItemCoreData?.itemId?.uuidString,
            let text = todoItemCoreData?.text,
            let isDone = todoItemCoreData?.done,
            let createdAt = todoItemCoreData?.createdAt,
            let hexColor = todoItemCoreData?.hexColor,
            let lastUpdatedBy = todoItemCoreData?.lastUpdatedBy
        else {
            return nil
        }
        
        let deadline = todoItemCoreData?.deadline
        let changesAt = todoItemCoreData?.changesAt
        
        var priority = Importance.normal
        if todoItemCoreData?.importance == Importance.important.rawValue {
            priority = Importance.important
        } else if todoItemCoreData?.importance == Importance.unimportant.rawValue {
            priority = Importance.unimportant
        }
        
        return TodoItem(
            id: id,
            text: text,
            importance: priority,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            hexColor: hexColor,
            lastUpdatedBy: lastUpdatedBy
        )
    }
    
    private func fetchTodoItem(from todoItem: TodoItem) throws -> TodoItemCoreData {
        let request = TodoItemCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "itemId == %@", todoItem.id as CVarArg)

        let items = try context.fetch(request)
        return items.first ?? TodoItemCoreData()
    }
}

extension CoreDataService: DatabaseService {
    func addItem(_ item: TodoItem) throws {
        let todoItemCoreData = TodoItemCoreData(context: context)
        
        todoItemCoreData.itemId = UUID(uuidString: item.id)
        todoItemCoreData.text = item.text
        todoItemCoreData.importance = item.importance.rawValue
        todoItemCoreData.deadline = item.deadline
        todoItemCoreData.done = item.isDone
        todoItemCoreData.createdAt = item.createdAt
        todoItemCoreData.changesAt = item.changesAt
        todoItemCoreData.hexColor = item.hexColor
        todoItemCoreData.lastUpdatedBy = item.lastUpdatedBy
        
        try context.save()
    }
    
    func updateItem(_ item: TodoItem) throws {
        let todoItemCoreData = try fetchTodoItem(from: item)
        
        todoItemCoreData.itemId = UUID(uuidString: item.id)
        todoItemCoreData.text = item.text
        todoItemCoreData.importance = item.importance.rawValue
        todoItemCoreData.deadline = item.deadline
        todoItemCoreData.done = item.isDone
        todoItemCoreData.createdAt = item.createdAt
        todoItemCoreData.changesAt = item.changesAt
        todoItemCoreData.hexColor = item.hexColor
        todoItemCoreData.lastUpdatedBy = item.lastUpdatedBy
        
        try context.save()
    }
    
    func deleteItem(_ item: TodoItem) throws {
        let todoItemCoreData = try fetchTodoItem(from: item)
        context.delete(todoItemCoreData)
        
        try context.save()
    }
    
    func loadItems(_ completion: (Result<[TodoItem], Error>) -> Void) throws {
        let request = TodoItemCoreData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            let items = result.compactMap { convert(from: $0) }
            completion(.success(items))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // Не использую этот метод
    func saveItems(_ items: [TodoItem]) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TodoItemCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            throw DataBaseManagerError.errorDeleteRow
        }
        
        for item in items {
            let todoItemCoreData = TodoItemCoreData(context: context)
            
            todoItemCoreData.itemId = UUID(uuidString: item.id)
            todoItemCoreData.text = item.text
            todoItemCoreData.importance = item.importance.rawValue
            todoItemCoreData.deadline = item.deadline
            todoItemCoreData.done = item.isDone
            todoItemCoreData.createdAt = item.createdAt
            todoItemCoreData.changesAt = item.changesAt
            todoItemCoreData.hexColor = item.hexColor
            todoItemCoreData.lastUpdatedBy = item.lastUpdatedBy
        }
        
        do {
            try context.save()
        } catch {
            throw DataBaseManagerError.errorUpdateRow
        }
    }
    
}
