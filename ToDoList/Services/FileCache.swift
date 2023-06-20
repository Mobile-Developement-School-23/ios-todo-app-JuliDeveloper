import Foundation

enum FileCacheError: Error {
    case failedConvertToJson
    case failedConvertToCsv
    case directoryNotFound
    case dataNotReceived
}

final class FileCache {
    
    //MARK: - Properties
    private(set) var todoItems: [TodoItem] = []
    
    //MARK: - Methods for .csv
    func saveToCsv(to file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
            throw FileCacheError.directoryNotFound
        }
        
        do {
            let csvString = convertToCSV(from: todoItems)
            let data = csvString?.data(using: .utf8)
            try data?.write(to: filePath)
        } catch {
            throw FileCacheError.failedConvertToCsv
        }
    }
    
    func loadFromCsv(from file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "csv") else {
            throw FileCacheError.directoryNotFound
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            if let csvString = String(data: data, encoding: .utf8) {
                todoItems = fetchItemsFromCsv(csvString) ?? []
            }
        } catch {
            throw FileCacheError.dataNotReceived
        }
    }
    
    //MARK: - Helpers
    private func convertToJson(from items: [TodoItem]) throws -> Data? {
        let array = items.map { $0.json as? [String: Any] }.compactMap { $0 }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array)
            return data
        } catch {
            throw FileCacheError.failedConvertToJson
        }
    }
    
    private func convertToCSV(from items: [TodoItem]) -> String? {
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
    
    private func fetchItemsFromJson(_ json: [Any]) -> [TodoItem]? {
        return json.compactMap { TodoItem.parse(json: $0) }
    }
    
    private func fetchItemsFromCsv(_ csv: String) -> [TodoItem]? {
        var strings = csv.components(separatedBy: "\n")
        strings.remove(at: 0)
        return strings.compactMap { TodoItem.parse(csv: $0) }
    }
    
    private func fetchFilePath(_ file: String, extensionPath: String) throws -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.directoryNotFound
        }
        
        let filePath = directory.appendingPathComponent("\(file).\(extensionPath)")
        return filePath
    }
}

extension FileCache: FileCacheProtocol {
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
            throw FileCacheError.directoryNotFound
        }
        
        do {
            if let data = try convertToJson(from: todoItems) {
                try data.write(to: filePath)
            }
        } catch {
            throw FileCacheError.failedConvertToJson
        }
    }
    
    func loadFromJson(from file: String) throws {
        guard let filePath = try? fetchFilePath(file, extensionPath: "json") else {
            throw FileCacheError.directoryNotFound
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            if let json = try JSONSerialization.jsonObject(with: data) as? [Any] {
                todoItems.removeAll()
                todoItems = fetchItemsFromJson(json) ?? []
            }
        } catch {
            throw FileCacheError.dataNotReceived
        }
    }
}
