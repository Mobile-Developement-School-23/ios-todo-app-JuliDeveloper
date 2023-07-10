import XCTest
@testable import ToDoList

final class TodoItemTests: XCTestCase {
    // MARK: - Tests - Private properties
    private let id = "1111"
    private let text = "Полить цветы"
    private let isDone = false
    private let createdAt = Date()
    private let hexColor = "#000000"
    private let lastUpdatedBy = "1"
    
    private var importance = Importance.important
    private var deadline: Date? = Date(timeIntervalSince1970: TimeInterval(1688947200))
    private var changesAt: Date? = Date(timeIntervalSince1970: TimeInterval(1688947200))
    
    private var item: TodoItem!
    
    //MARK: - Tests - Initialization
    override func setUp() {
        super.setUp()
        item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            lastUpdatedBy: lastUpdatedBy
        )
    }
    //MARK: - Tests - Creation TodoItem
    func testCreateTodoItemWithValidValues() {
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importance, importance)
        XCTAssertEqual(item.deadline, deadline)
        XCTAssertEqual(item.isDone, isDone)
        XCTAssertEqual(item.createdAt, createdAt)
        XCTAssertEqual(item.changesAt, changesAt)
    }
    
    func testCreateTodoItemWithInvalidValues() {
        let item = TodoItem(
            id: "",
            text: "",
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            lastUpdatedBy: lastUpdatedBy
        )
        
        XCTAssertFalse(item.id == id)
        XCTAssertFalse(item.text == text)
        XCTAssertEqual(item.importance, importance)
        XCTAssertEqual(item.deadline, deadline)
        XCTAssertEqual(item.isDone, isDone)
        XCTAssertEqual(item.createdAt, createdAt)
        XCTAssertEqual(item.changesAt, changesAt)
    }
    
    func testCreateTodoItemWithNilDates() {
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: nil,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: nil,
            hexColor: hexColor,
            lastUpdatedBy: lastUpdatedBy
        )
        
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.changesAt)
    }
    
    //MARK: - Tests - Convert TodoItem to JSON
    func testTodoItemToJson() {
        let result = item.json as [String: Any]
        
        XCTAssertEqual(result["id"] as? String, id)
        XCTAssertEqual(result["text"] as? String, text)
        XCTAssertEqual(result["importance"] as? String, importance.rawValue)
        XCTAssertEqual(result["done"] as? Bool, isDone)
        XCTAssertEqual(result["deadline"] as? Int64, Int64(deadline?.dateIntValue ?? 0))
        XCTAssertEqual(result["created_at"] as? Int64, Int64(createdAt.dateIntValue ?? 0))
        XCTAssertEqual(result["changed_at"] as? Int64, Int64(changesAt?.dateIntValue ?? 0))
        XCTAssertEqual(result["color"] as? String, hexColor)
        XCTAssertEqual(result["last_updated_by"] as? String, lastUpdatedBy)
    }
    
    func testTodoItemToJsonWithDates() {
        let result = item.json as [String: Any]
        
        XCTAssertNotNil(result["deadline"])
        XCTAssertNotNil(result["changed_at"])
        XCTAssertEqual(result["deadline"] as? Int64, Int64(deadline?.dateIntValue ?? 0))
        XCTAssertEqual(result["changed_at"] as? Int64, Int64(changesAt?.dateIntValue ?? 0))
    }
    
    func testTodoItemToJsonWithNilDates() {
        deadline = nil
        changesAt = nil
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            lastUpdatedBy: lastUpdatedBy
        )
        
        let result = item.json as [String: Any]
        
        XCTAssertEqual(result["deadline"] as? Int, nil)
        XCTAssertEqual(result["changed_at"] as? Int, nil)
    }
    
    func testTodoItemToJsonWithImportanceNormal() {
        importance = Importance.normal
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: Date(),
            isDone: isDone,
            createdAt: createdAt,
            changesAt: Date(),
            lastUpdatedBy: lastUpdatedBy
        )
        
        let result = item.json as [String: Any]
        
        XCTAssertEqual(result["importance"] as? String, "basic")
    }
    
    func testTodoItemToJsonWithImportanceNotNormal() {
        let result = item.json as [String: Any]
        
        XCTAssertNotNil(result["importance"])
        XCTAssertEqual(result["importance"] as? String, importance.rawValue)
    }
    
    //MARK: - Tests - Convert TodoItem from JSON
    func testParseTodoItemFromJsonWithInvalidData() {
        let json: [String: Any] = [:]
        
        let item = TodoItem.parse(json: json)
        XCTAssertNil(item)
    }
    
    func testParseTodoItemFromJson() {
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": deadline?.dateIntValue ?? 0 as Any,
            "done": isDone,
            "created_at": createdAt.dateIntValue ?? 0,
            "changed_at": changesAt?.dateIntValue ?? 0 as Any,
            "hexColor": hexColor,
            "last_updated_by": lastUpdatedBy
        ]
        
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to convert TodoItem from JSON")
            return
        }
        
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importance, importance)
        XCTAssertEqual(item.isDone, isDone)
        XCTAssertEqual(item.deadline?.dateIntValue, deadline?.dateIntValue)
        XCTAssertEqual(item.createdAt.dateIntValue, createdAt.dateIntValue)
        XCTAssertEqual(item.changesAt?.dateIntValue, changesAt?.dateIntValue)
    }
    
    func testParseTodoItemFromJsonWithDates() {
        let deadline: Int? = 1686614400
        let changesAt: Int? = 1686614400
        
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": deadline as Any ,
            "done": isDone,
            "created_at": 1686614400,
            "changed_at": changesAt as Any,
            "hexColor": "#000000",
            "last_updated_by": lastUpdatedBy
        ]
        
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to convert TodoItem from JSON")
            return
        }
        
        XCTAssertNotNil(item.deadline)
        XCTAssertNotNil(item.changesAt)
        XCTAssertEqual(item.deadline, deadline?.dateValue)
        XCTAssertEqual(item.changesAt, changesAt?.dateValue)
    }
    
    func testParseTodoItemFromJsonWithNilDates() {
        let deadline: Int? = nil
        let changesAt: Int? = nil
        
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance,
            "deadline": deadline as Any,
            "done": isDone,
            "created_at": 1686614400,
            "changed_at": changesAt as Any,
            "hexColor": hexColor,
            "last_updated_by": lastUpdatedBy
        ]
        
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to convert TodoItem from JSON")
            return
        }
        
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.changesAt)
        XCTAssertEqual(item.deadline, deadline?.dateValue)
        XCTAssertEqual(item.changesAt, changesAt?.dateValue)
    }
    
    func testParseTodoItemFromJsonWithImportanceNormal() {
        importance = .normal
        
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": 1686614400,
            "done": isDone,
            "created_at": 1686614400,
            "changed_at": 1686614400,
            "hexColor": hexColor,
            "last_updated_by": lastUpdatedBy
        ]
        
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to convert TodoItem from JSON")
            return
        }
        
        XCTAssertNotNil(item.importance)
        XCTAssertEqual(item.importance.rawValue, importance.rawValue)
    }
    
    func testParseTodoItemFromJsonWithImportanceNotNormal() {
        importance = .important
        
        let json: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": 1686614400,
            "done": isDone,
            "created_at": 1686614400,
            "changed_at": 1686614400,
            "hexColor": hexColor,
            "last_updated_by": lastUpdatedBy
        ]
        
        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to convert TodoItem from JSON")
            return
        }
        
        XCTAssertNotNil(item.importance)
        XCTAssertEqual(item.importance.rawValue, importance.rawValue)
    }
    
    //MARK: - Tests - Convert TodoItem to CSV
    func testTodoItemToCsv() {
        let deadlineString = String(deadline?.dateIntValue ?? 0)
        let createdAtString = String(createdAt.dateIntValue ?? 0)
        let changesAtString = String(changesAt?.dateIntValue ?? 0)
        
        let sampleString = "\(id),\(text),\(importance.rawValue),\(deadlineString),\(isDone),\(createdAtString),\(changesAtString),\(hexColor)"
        let csvString = item.csv
        
        XCTAssertEqual(csvString, sampleString)
    }
    
    func testTodoItemToCsvString() {
        let csvString = item.csv
        XCTAssertTrue(csvString.contains(","))
    }
    
    func testTodoItemToCsvWithTextWithСommas() {
        let item = TodoItem(
            id: id,
            text: "Купить: молоко, хлеб, масло",
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            lastUpdatedBy: lastUpdatedBy
        )
        
        let csvString = item.csv
        
        XCTAssertTrue(csvString.contains("|"))
    }
    
    func testTodoItemToCsvWithDates() {
        let csvString = item.csv
        let parts = csvString.components(separatedBy: ",")
        
        XCTAssertNotNil(parts[3])
        XCTAssertNotNil(parts[6])
        XCTAssertEqual(parts[3], String(item.deadline?.dateIntValue ?? 0))
        XCTAssertEqual(parts[6], String(item.deadline?.dateIntValue ?? 0))
    }
    
    func testTodoItemToCsvWithNilDates() {
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: nil,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: nil,
            lastUpdatedBy: lastUpdatedBy
        )
        
        let csvString = item.csv
        let parts = csvString.components(separatedBy: ",")
        
        XCTAssertEqual(parts[3], "")
        XCTAssertEqual(parts[6], "")
    }
    
    func testTodoItemToCsvWithImportanceNormal() {
        importance = Importance.normal
        
        let item = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            lastUpdatedBy: lastUpdatedBy
        )
        
        let csvString = item.csv
        
        let parts = csvString.components(separatedBy: ",")
        
        XCTAssertEqual(parts[2], "")
    }
    
    func testTodoItemToCsvWithImportanceNotNormal() {
        let csvString = item.csv
        let parts = csvString.components(separatedBy: ",")
        
        XCTAssertEqual(parts[2], item.importance.rawValue)
    }
    
    //MARK: - Tests - Convert TodoItem from CSV
    func testParseTodoItemFromCsvWithInvalidData() {
        let invalidString = "invalid string"
        let item = TodoItem.parse(csv: invalidString)
        
        XCTAssertNil(item)
    }
    
    func testParseTodoItemFromCsv() {
        let deadline = "1686614400"
        let createdAt = "1686614400"
        let changesAt = "1686614400"
        
        let sampleString = "\(id),\(text),\(importance.rawValue),\(deadline),\(isDone),\(createdAt),\(changesAt)"
        
        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        let parts = sampleString.components(separatedBy: ",")
        
        XCTAssertEqual(item.id, parts[0])
        XCTAssertEqual(item.text, parts[1])
        XCTAssertEqual(item.importance, Importance(rawValue: parts[2]))
        XCTAssertEqual(item.deadline, Int(parts[3])?.dateValue)
        XCTAssertEqual(item.isDone, Bool(parts[4]))
        XCTAssertEqual(item.createdAt, Int(parts[5])?.dateValue)
        XCTAssertEqual(item.changesAt, Int(parts[6])?.dateValue)
    }
    
    func testParseTodoItemFromCsvWithTextWithSeparator() {
        let textWithSeparator = "Купить: молоко| хлеб| масло"
        let deadline = "1686614400"
        let createdAt = "1686614400"
        let changesAt = "1686614400"
        
        let sampleString = "\(id),\(textWithSeparator),\(importance),\(deadline),\(isDone),\(createdAt),\(changesAt)"

        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        XCTAssertTrue(item.text.contains(","))
    }
    
    func testParseTodoItemFromCsvWithDates() {
        let deadline = "1686614400"
        let createdAt = "1686614400"
        let changesAt = "1686614400"
        
        let sampleString = "\(id),\(text),\(importance),\(deadline),\(isDone),\(createdAt),\(changesAt)"
        
        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        let parts = sampleString.components(separatedBy: ",")
        
        XCTAssertEqual(item.deadline, Int(parts[3])?.dateValue)
        XCTAssertEqual(item.changesAt, Int(parts[6])?.dateValue)
    }
    
    func testParseTodoItemFromCsvWithNilDates() {
        let createdAt = "1686614400"
        
        let sampleString = "\(id),\(text),\(importance),,\(isDone),\(createdAt),"
        
        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.changesAt)
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.importance, importance)
        XCTAssertEqual(item.isDone, isDone)
        XCTAssertEqual(item.createdAt, Int(createdAt)?.dateValue)
    }
    
    func testParseTodoItemFromCsvWithImportanceNormal() {
        let importance = Importance.normal
        let deadline = "1686614400"
        let createdAt = "1686614400"
        let changesAt = "1686614400"
        
        let sampleString = "\(id),\(text),,\(deadline),\(isDone),\(createdAt),\(changesAt)"
        
        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        XCTAssertEqual(item.importance.rawValue, importance.rawValue)
    }
    
    func testParseTodoItemFromCsvWithImportanceNotNormal() {
        let deadline = "1686614400"
        let createdAt = "1686614400"
        let changesAt = "1686614400"
        
        let sampleString = "\(id),\(text),\(importance.rawValue),\(deadline),\(isDone),\(createdAt),\(changesAt)"
        
        guard let item = TodoItem.parse(csv: sampleString) else {
            return
        }
        
        XCTAssertEqual(item.importance.rawValue, importance.rawValue)
    }
}
