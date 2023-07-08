import Foundation

public protocol JSONConvertible {
    associatedtype TypeItem: JSONConvertible & CSVConvertible
    init?(json: [String: Any])
    var json: [String: Any] { get }
    static func parse(json: Any) -> TypeItem?
}

public protocol CSVConvertible {
    associatedtype TypeItem: JSONConvertible & CSVConvertible
    init?(csv: String)
    var csv: String { get }
    static func parse(csv: String) -> TypeItem?
}

public protocol IdentifiableType {
    var id: String { get }
}

public protocol FileCacheProtocol {
    associatedtype TypeItem: JSONConvertible & CSVConvertible & IdentifiableType
    var todoItemsList: [TypeItem] { get }
    func addItem(_ item: TypeItem) -> TypeItem?
    func deleteItem(with id: String) -> TypeItem?
    func saveToJson(to file: String) throws
    func loadFromJson(from file: String) throws
}

public enum FileCacheError: Error {
    case failedConvertToJson
    case failedConvertToCsv
    case directoryNotFound
    case dataNotReceived
}

public class FileCache<TypeItem: JSONConvertible & CSVConvertible & IdentifiableType> {

    // MARK: - Properties
    public var todoItems: [TypeItem] = []

    private let logger: LoggerProtocol
    
    public init(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    public convenience init() {
        self.init(logger: Logger.shared)
    }

    // MARK: - Methods for .csv
    public func saveToCsv(to file: String) throws {
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

    public func loadFromCsv(from file: String) throws {
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

    // MARK: - Helpers
    public func convertToJson(from items: [TypeItem]) throws -> Data? {
        let array = items.map { $0.json }.compactMap { $0 }

        do {
            let data = try JSONSerialization.data(withJSONObject: array)
            logger.logInfo("Успешно cконвертированно в JSON")
            return data
        } catch {
            logger.logError(" Не удалось конвертировать в JSON")
            throw FileCacheError.failedConvertToJson
        }
    }

    private func convertToCSV(from items: [TypeItem]) -> String? {
        var csvString = "id,text,importance,deadline,isDone,createdAt,changesAt\n"

        for (index, item) in items.enumerated() {
            if index < items.count - 1 {
                csvString += item.csv + "\n"
            } else {
                csvString += item.csv
            }
        }

        logger.logInfo("Успешно cконвертированно в СSV")

        return csvString
    }

    public func fetchItemsFromJson(_ json: [Any]) -> [TypeItem]? {
        return json.compactMap { TypeItem.parse(json: $0) as? TypeItem }
    }

    private func fetchItemsFromCsv(_ csv: String) -> [TypeItem]? {
        var strings = csv.components(separatedBy: "\n")
        strings.remove(at: 0)
        return strings.compactMap { TypeItem.parse(csv: $0) as? TypeItem }
    }

    private func fetchFilePath(_ file: String, extensionPath: String) throws -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.logError("Ошибка: Не удалось получить путь к директории")
            throw FileCacheError.directoryNotFound
        }

        let filePath = directory.appendingPathComponent("\(file).\(extensionPath)")
        return filePath
    }
}

extension FileCache: FileCacheProtocol {
    public var todoItemsList: [TypeItem] {
        return todoItems
    }
    
    public func addItem(_ item: TypeItem) -> TypeItem? {
        if let indexOldItem = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[indexOldItem] = item
            return todoItems[indexOldItem]
        } else {
            todoItems.append(item)
            return item
        }
    }

    public func deleteItem(with id: String) -> TypeItem? {
        if let index = todoItems.firstIndex(where: { $0.id == id }) {
            let removeItem = todoItems.remove(at: index)
            return removeItem
        }
        return nil
    }

    public func saveToJson(to file: String) throws {
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

    public func loadFromJson(from file: String) throws {
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
