//import Foundation
//
//protocol FileCacheJsonProtocol {
//    var todoItemsList: [TodoItem] { get }
//    func addItem(_ item: TodoItem) -> TodoItem?
//    func deleteItem(with id: String) -> TodoItem?
//    func saveToJson(to file: String) throws
//    func loadFromJson(from file: String) throws
//}
//
//protocol FileCacheCsvProtocol {
//    func saveToCsv(to file: String) throws
//    func loadFromCsv(from file: String) throws
//}
//
//protocol FileCacheSQLiteProtocol {
//    var todoItemsDb: [TodoItem] { get }
//    func insertItemDb(_ item: TodoItem)
//    func updateItemDb(_ item: TodoItem)
//    func deleteItemDb(todoItem: TodoItem)
//    func saveToDb(items: [TodoItem])
//    func loadFromDb()
//}
//
//enum FileCacheError: Error {
//    case failedConvertToJson
//    case failedConvertToCsv
//    case directoryNotFound
//    case dataNotReceived
//}
//
//final class FileCache {
//    // MARK: - Properties
//    private(set) var todoItems: [TodoItem] = []
//
//    private let logger: LoggerProtocol
//    private let dataBase: DataBaseManagerProtocol
//
//    init(
//        logger: LoggerProtocol = Logger.shared,
//        dataBase: DataBaseManagerProtocol = DataBaseManager()
//    ) {
//        self.logger = logger
//        self.dataBase = dataBase
//    }
//
//    // MARK: - Methods convert TodoItem
//    func convertToJson(from items: [TodoItem]) throws -> Data? {
//        let array = items.map { $0.json }.compactMap { $0 }
//
//        do {
//            let data = try JSONSerialization.data(withJSONObject: array)
//            return data
//        } catch {
//            throw FileCacheError.failedConvertToJson
//        }
//    }
//
//    func convertToCSV(from items: [TodoItem]) -> String? {
//        var csvString = "id,text,importance,deadline,isDone,createdAt,changesAt\n"
//
//        for (index, item) in items.enumerated() {
//            if index < items.count - 1 {
//                csvString += item.csv + "\n"
//            } else {
//                csvString += item.csv
//            }
//        }
//
//        return csvString
//    }
//
//    // MARK: - Methods fetch TodoItems
//    func fetchItemsFromJson(_ json: [Any]) -> [TodoItem]? {
//        return json.compactMap { TodoItem.parse(json: $0) }
//    }
//
//    func fetchItemsFromCsv(_ csv: String) -> [TodoItem]? {
//        var strings = csv.components(separatedBy: "\n")
//        strings.remove(at: 0)
//        return strings.compactMap { TodoItem.parse(csv: $0) }
//    }
//
//    // MARK: - Helpers
//    func fetchFilePath(_ file: String, extensionPath: String) throws -> URL? {
//        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            throw FileCacheError.directoryNotFound
//        }
//
//        let filePath = directory.appendingPathComponent("\(file).\(extensionPath)")
//        return filePath
//    }
//}
//
//extension FileCache: FileCacheJsonProtocol {
//    var todoItemsList: [TodoItem] {
//        return todoItems
//    }
//
//    func addItem(_ item: TodoItem) -> TodoItem? {
//        if let indexOldItem = todoItems.firstIndex(where: { $0.id == item.id }) {
//            todoItems[indexOldItem] = item
//            return todoItems[indexOldItem]
//        } else {
//            todoItems.append(item)
//            return item
//        }
//    }
//
//    func deleteItem(with id: String) -> TodoItem? {
//        if let index = todoItems.firstIndex(where: { $0.id == id }) {
//            let removeItem = todoItems.remove(at: index)
//            return removeItem
//        }
//        return nil
//    }
//
//    func saveToJson(to file: String) throws {
//        guard let filePath = try? fetchFilePath(file, extensionPath: "json") else {
//            logger.logError("Ошибка: Не удалось получить путь к файлу")
//            throw FileCacheError.directoryNotFound
//        }
//
//        do {
//            if let data = try convertToJson(from: todoItems) {
//                try data.write(to: filePath)
//                logger.logInfo("Успешно сохранено в JSON файл")
//            }
//        } catch {
//            logger.logError("Ошибка: не удалось загрузить в JSON файла")
//            throw FileCacheError.failedConvertToJson
//        }
//    }
//
//    func loadFromJson(from file: String) throws {
//        guard let filePath = try? fetchFilePath(file, extensionPath: "json") else {
//            logger.logError("Ошибка: Не удалось получить путь к файлу")
//            throw FileCacheError.directoryNotFound
//        }
//
//        do {
//            let data = try Data(contentsOf: filePath)
//            if let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
//                todoItems = fetchItemsFromJson(json) ?? []
//                logger.logInfo("Успешно загружено из JSON файл")
//            }
//        } catch {
//            logger.logError("Ошибка: не удалось загрузить из JSON файла")
//            throw FileCacheError.dataNotReceived
//        }
//    }
//}
//
//// MARK: - Methods for .csv
//extension FileCache: FileCacheCsvProtocol {
//    func saveToCsv(to file: String) throws {
//        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
//            logger.logError("Ошибка: Не удалось получить путь к файлу")
//            throw FileCacheError.directoryNotFound
//        }
//
//        do {
//            let csvString = convertToCSV(from: todoItems)
//            let data = csvString?.data(using: .utf8)
//            try data?.write(to: filePath)
//        } catch {
//            logger.logError("Ошибка: Не удалось сохранить в CSV файл")
//            throw FileCacheError.failedConvertToCsv
//        }
//    }
//
//    func loadFromCsv(from file: String) throws {
//        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
//            logger.logError("Ошибка: Не удалось получить путь к файлу")
//            throw FileCacheError.directoryNotFound
//        }
//
//        do {
//            let data = try Data(contentsOf: filePath)
//            if let csvString = String(data: data, encoding: .utf8) {
//                todoItems = fetchItemsFromCsv(csvString) ?? []
//                logger.logInfo("Успешно загружено из CSV файл")
//            }
//        } catch {
//            logger.logError("Ошибка: Не удалось загрузить из CSV файла")
//            throw FileCacheError.dataNotReceived
//        }
//    }
//}
//
//extension FileCache: FileCacheSQLiteProtocol {
//    var todoItemsDb: [TodoItem] {
//        todoItems
//    }
//
//    func insertItemDb(_ item: TodoItem) {
//        if let addedItem = addItem(item) {
//            do {
//                try dataBase.insert(todoItem: addedItem)
//                logger.logInfo("Задача успешно добавлена")
//            } catch {
//                logger.logError("Ошибка добавления задачи")
//            }
//        }
//    }
//
//    func updateItemDb(_ item: TodoItem) {
//        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
//            todoItems[index] = item
//            do {
//                try dataBase.update(todoItem: item)
//                logger.logInfo("Задача успешно обновлена")
//            } catch {
//                logger.logError("Ошибка обновления задачи")
//            }
//        }
//    }
//
//    func deleteItemDb(todoItem: TodoItem) {
//        if let deletedItem = deleteItem(with: todoItem.id) {
//            do {
//                try dataBase.delete(todoItem: todoItem)
//                logger.logInfo("Задача успешно удалена")
//            } catch {
//                logger.logError("Ошибка удаления задачи")
//            }
//        }
//    }
//
//    func saveToDb(items: [TodoItem]) {
//        do {
//            try dataBase.save(todoItems: items)
//            logger.logInfo("Задачи успешно сохранены")
//        } catch {
//            logger.logError("Ошибка сохранения задач")
//        }
//    }
//
//    func loadFromDb() {
//        do {
//            try todoItems = dataBase.loadDb()
//            logger.logInfo("Задачи успешно загружены")
//        } catch {
//            logger.logError("Ошибка загрузки задач")
//        }
//    }
//}
