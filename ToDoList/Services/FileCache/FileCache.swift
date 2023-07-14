import Foundation

protocol FileCacheJsonProtocol {
    var todoItemsList: [TodoItem] { get }
    func addItem(_ item: TodoItem) -> TodoItem?
    func deleteItem(with id: String) -> TodoItem?
    func saveToJson(to file: String) throws
    func loadFromJson(from file: String) throws
}

protocol FileCacheCsvProtocol {
    func saveToCsv(to file: String) throws
    func loadFromCsv(from file: String) throws
}

protocol FileCacheDatabaseProtocol {
    var todoListDB: [TodoItem] { get }
    func addItemDB(_ item: TodoItem)
    func updateItemDB(_ item: TodoItem)
    func deleteItemDB(_ item: TodoItem)
    func fetchTodoItemsDB()
    func updateDatabaseService(service: DatabaseService)
}

enum FileCacheError: Error {
    case failedConvertToJson
    case failedConvertToCsv
    case directoryNotFound
    case dataNotReceived
}

final class FileCache {
    // MARK: - Properties
    private(set) var todoItems: [TodoItem] = []

    private let logger: LoggerProtocol
    private var database: DatabaseService

    init(
        logger: LoggerProtocol = Logger.shared,
        database: DatabaseService
    ) {
        self.logger = logger
        self.database = database
    }

    // MARK: - Methods convert TodoItem
    func convertToJson(from items: [TodoItem]) throws -> Data? {
        let array = items.map { $0.json }.compactMap { $0 }

        do {
            let data = try JSONSerialization.data(withJSONObject: array)
            return data
        } catch {
            throw FileCacheError.failedConvertToJson
        }
    }

    func convertToCSV(from items: [TodoItem]) -> String? {
        var csvString = "id,text,importance,deadline,isDone,createdAt,changesAt\n"

        for (index, item) in items.enumerated() {
            if index < items.count - 1 {
                csvString += item.csv + "\n"
            } else {
                csvString += item.csv
            }
        }

        return csvString
    }

    // MARK: - Methods fetch TodoItems
    func fetchItemsFromJson(_ json: [Any]) -> [TodoItem]? {
        return json.compactMap { TodoItem.parse(json: $0) }
    }

    func fetchItemsFromCsv(_ csv: String) -> [TodoItem]? {
        var strings = csv.components(separatedBy: "\n")
        strings.remove(at: 0)
        return strings.compactMap { TodoItem.parse(csv: $0) }
    }

    // MARK: - Helpers
    func fetchFilePath(_ file: String, extensionPath: String) throws -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.directoryNotFound
        }

        let filePath = directory.appendingPathComponent("\(file).\(extensionPath)")
        return filePath
    }
}

extension FileCache: FileCacheJsonProtocol {
    var todoItemsList: [TodoItem] {
        return todoItems
    }

    func addItem(_ item: TodoItem) -> TodoItem? {
        if let indexOldItem = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[indexOldItem] = item
            return todoItems[indexOldItem]
        } else {
            todoItems.append(item)
            return item
        }
    }

    func deleteItem(with id: String) -> TodoItem? {
        if let index = todoItems.firstIndex(where: { $0.id == id }) {
            let removeItem = todoItems.remove(at: index)
            return removeItem
        }
        return nil
    }

    func saveToJson(to file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "json") else {
            logger.logError("Ошибка: Не удалось получить путь к файлу")
            throw FileCacheError.directoryNotFound
        }

        do {
            if let data = try convertToJson(from: todoItems) {
                try data.write(to: filePath)
                logger.logInfo("Успешно сохранено в JSON файл")
            }
        } catch {
            logger.logError("Ошибка: не удалось загрузить в JSON файла")
            throw FileCacheError.failedConvertToJson
        }
    }

    func loadFromJson(from file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "json") else {
            logger.logError("Ошибка: Не удалось получить путь к файлу")
            throw FileCacheError.directoryNotFound
        }

        do {
            let data = try Data(contentsOf: filePath)
            if let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                todoItems = fetchItemsFromJson(json) ?? []
                logger.logInfo("Успешно загружено из JSON файл")
            }
        } catch {
            logger.logError("Ошибка: не удалось загрузить из JSON файла")
            throw FileCacheError.dataNotReceived
        }
    }
}

// MARK: - Methods for .csv
extension FileCache: FileCacheCsvProtocol {
    func saveToCsv(to file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
            logger.logError("Ошибка: Не удалось получить путь к файлу")
            throw FileCacheError.directoryNotFound
        }

        do {
            let csvString = convertToCSV(from: todoItems)
            let data = csvString?.data(using: .utf8)
            try data?.write(to: filePath)
        } catch {
            logger.logError("Ошибка: Не удалось сохранить в CSV файл")
            throw FileCacheError.failedConvertToCsv
        }
    }

    func loadFromCsv(from file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
            logger.logError("Ошибка: Не удалось получить путь к файлу")
            throw FileCacheError.directoryNotFound
        }

        do {
            let data = try Data(contentsOf: filePath)
            if let csvString = String(data: data, encoding: .utf8) {
                todoItems = fetchItemsFromCsv(csvString) ?? []
                logger.logInfo("Успешно загружено из CSV файл")
            }
        } catch {
            logger.logError("Ошибка: Не удалось загрузить из CSV файла")
            throw FileCacheError.dataNotReceived
        }
    }
}

extension FileCache: FileCacheDatabaseProtocol {
    var todoListDB: [TodoItem] {
        todoItems
    }
    
    func addItemDB(_ item: TodoItem) {
        do {
            try database.addItem(item)
            logger.logInfo("Успешно: задача добавлена в базу данных")
        } catch {
            logger.logError("Ошибка: задача не добавлена в базу данных")
            print(error)
        }
    }
    
    func updateItemDB(_ item: TodoItem) {
        do {
            try database.updateItem(item)
            logger.logInfo("Успешно: задача изменена в базе данных")
        } catch {
            logger.logError("Ошибка: задача не изменена в базе данных")
            print(error)
        }
    }
    
    func deleteItemDB(_ item: TodoItem) {
        do {
            try database.deleteItem(item)
            logger.logInfo("Успешно: задача удалена из базы данных")
        } catch {
            logger.logError("Ошибка: задача не удалена из базы данных")
            print(error)
        }
    }
    
    func fetchTodoItemsDB() {
        do {
            try database.loadItems { result in
                switch result {
                case .success(let items):
                    todoItems = items
                    logger.logInfo("Успешно: данные получены из базы данных")
                case .failure(let error):
                    logger.logError("Ошибка: данные не получены из базы данных")
                    print(error)
                }
            }
        } catch {
            
        }
    }
    
    func updateDatabaseService(service: DatabaseService) {
        database = service
    }
}
