import XCTest
import FileCachePackage
@testable import ToDoList

final class FileCacheTests: XCTestCase {
    
    //MARK: - Tests - Private properties
    private let fileCache = FileCache<TodoItem>()
    private let filename = "testToDo"
    
    private var item: TodoItem!
    
    //MARK: - Tests - Initialization
    override func setUp() {
        super.setUp()
        item = TodoItem(
            text: "Test",
            importance: Importance.important,
            lastUpdatedBy: "1"
        )
    }
    
    //MARK: - Tests - Add TodoItem
    func testAddItem() {
        _ = fileCache.addItem(item)
        
        XCTAssertTrue(fileCache.todoItemsList.contains { $0.id == item.id })
        XCTAssertTrue(fileCache.todoItemsList.count == 1)
    }
    
    func testUpdateItem() {
        item = TodoItem(
            id: "111",
            text: "Hi",
            importance: Importance.important,
            lastUpdatedBy: "1"
        )
        _ = fileCache.addItem(item)
        
        let newItem = TodoItem(
            id: "111",
            text: "Bye",
            importance: Importance.important,
            lastUpdatedBy: "1"
        )
        _ = fileCache.addItem(newItem)
        
        XCTAssertTrue(fileCache.todoItemsList.contains { $0.text == "Bye" })
        XCTAssertTrue(fileCache.todoItemsList.count == 1)
    }
    
    //MARK: - Tests - Delete TodoItem
    func testDeleteItemWithValidId() {
        _ = fileCache.addItem(item)
        _ = fileCache.deleteItem(with: item.id)
        
        print(fileCache.todoItemsList)
        
        XCTAssertFalse(fileCache.todoItemsList.contains { $0.id == item.id })
        XCTAssertTrue(fileCache.todoItemsList.count == 0)
    }
    
    func testDeleteItemWithInvalidId() {
        _ = fileCache.addItem(item)
        _ = fileCache.deleteItem(with: "1111")
        
        XCTAssertTrue(fileCache.todoItemsList.contains { $0.id == item.id })
        XCTAssertTrue(fileCache.todoItemsList.count == 1)
    }
    
    //MARK: - Tests - Convert TodoItem
//    func testConvertToJson() {
//        _ = fileCache.addItem(item)
//
//        let result = try? fileCache.convertToJson(from: fileCache.todoItemsList)
//
//        XCTAssertNotNil(result)
//    }
//
//    func testConvertToCsv() {
//        _ = fileCache.addItem(item)
//
//        let result = fileCache.convertToCSV(from: fileCache.todoItemsList)
//
//        XCTAssertNotNil(result)
//    }
    
    //MARK: - Tests - Fetch TodoItem
    func testFetchItemsFromJson() {
        if let data = try? fileCache.convertToJson(from: [item]),
           let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
            let items = fileCache.fetchItemsFromJson(json)
            
            XCTAssertEqual(items?[0].id, item.id)
            XCTAssertEqual(items?[0].text, item.text)
            XCTAssertEqual(items?[0].importance, item.importance)
            XCTAssertEqual(items?[0].createdAt, item.createdAt.dateIntValue?.dateValue ?? Date())
        }
    }
    
//    func testFetchItemsFromCsv() {
//        if let csvString = fileCache.convertToCSV(from: [item]) {
//            let items = fileCache.fetchItemsFromCsv(csvString) ?? []
//
//            XCTAssertEqual(items[0].id, item.id)
//            XCTAssertEqual(items[0].text, item.text)
//            XCTAssertEqual(items[0].importance, item.importance)
//            XCTAssertEqual(items[0].createdAt, item.createdAt.dateIntValue?.dateValue ?? Date())
//        }
//    }
    
    //MARK: - Tests - Save TodoItem to file
    func testSaveToJson() {
        _ = fileCache.addItem(item)
                
        do {
            try fileCache.saveToJson(to: filename)
            
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                XCTFail("\(FileCacheError.directoryNotFound)")
                return
            }
            
            let filePath = directory.appendingPathComponent("\(filename).json")
            XCTAssertTrue(FileManager.default.fileExists(atPath: filePath.path))
        } catch {
            XCTFail("\(FileCacheError.failedConvertToJson), \(error)")
        }
    }
    
    func testSaveToCsv() {
        _ = fileCache.addItem(item)
                
        do {
            try fileCache.saveToCsv(to: filename)
            
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                XCTFail("\(FileCacheError.directoryNotFound)")
                return
            }
            
            let filePath = directory.appendingPathComponent("\(filename).csv")
            XCTAssertTrue(FileManager.default.fileExists(atPath: filePath.path))
        } catch {
            XCTFail("\(FileCacheError.failedConvertToJson), \(error)")
        }
    }
    
    //MARK: - Tests - Load TodoItem from file
    func testLoadFromJson() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }

            do {
                try self.fileCache.loadFromJson(from: self.filename)
                
                XCTAssertTrue(!self.fileCache.todoItemsList.isEmpty)
                XCTAssertTrue(self.fileCache.todoItemsList.count == 1)
            } catch {
                XCTFail("\(FileCacheError.dataNotReceived), \(error)")
            }
        }
    }
    
    func testLoadFromCsv() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.fileCache.loadFromCsv(from: self.filename)
                
                XCTAssertTrue(!self.fileCache.todoItemsList.isEmpty)
                XCTAssertTrue(self.fileCache.todoItemsList.count == 1)
            } catch {
                XCTFail("\(FileCacheError.dataNotReceived), \(error)")
            }
        }
    }
}

