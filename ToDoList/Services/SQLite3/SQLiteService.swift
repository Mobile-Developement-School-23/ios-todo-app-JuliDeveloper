import Foundation
import SQLite3

enum DataBaseManagerError: Error {
    case directoryNotFound
    case errorOpeningDataBase
    case tableNotBeCreated
    case errorInsertRow
    case errorLoadFromDB
    case errorUpdateRow
    case errorDeleteRow
}

final class SQLiteService {
    
    let dataBasePath: String = "todoList.sqlite"
    var dataBase: OpaquePointer?
    
    init() {
        try? dataBase = openDataBase()
        try? createTable()
    }
    
    func openDataBase() throws -> OpaquePointer? {
        var dataBase: OpaquePointer?
        
        guard
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw DataBaseManagerError.directoryNotFound
        }
        
        let filePathUrl = directory.appendingPathComponent("\(dataBasePath)")
        
        if sqlite3_open(filePathUrl.path, &dataBase) != SQLITE_OK {
            throw DataBaseManagerError.errorOpeningDataBase
        } else {
            return dataBase
        }
    }
    
    func createTable() throws {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TodoItem(
        id TEXT PRIMARY KEY,
        text TEXT,
        importance TEXT,
        deadline TEXT,
        isDone INTEGER,
        createdAt TEXT,
        changeAt TEXT,
        hexColor TEXT,
        lastUpdatedBy TEXT);
        """
        
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dataBase, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) != SQLITE_DONE {
                throw DataBaseManagerError.tableNotBeCreated
            }
        } else {
            throw DataBaseManagerError.tableNotBeCreated
        }
        
        sqlite3_finalize(createTableStatement)
    }
}

extension SQLiteService: DatabaseService {
    func addItem(_ item: TodoItem) throws {
        let saveStatementString = item.sqlReplaceStatement
        var saveStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dataBase, saveStatementString, -1, &saveStatement, nil) == SQLITE_OK {
            if sqlite3_step(saveStatement) != SQLITE_DONE {
                throw DataBaseManagerError.errorInsertRow
            }
        } else {
            throw DataBaseManagerError.errorInsertRow
        }
        
        sqlite3_finalize(saveStatement)
    }
    
    func updateItem(_ item: TodoItem) throws {
        let updateStatementString = """
        UPDATE TodoItem SET
        text = ?,
        importance = ?,
        deadline = ?,
        isDone = ?,
        createdAt = ?,
        changeAt = ?,
        hexColor = ?,
        lastUpdatedBy = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dataBase, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            let text = item.text as NSString
            let importance = item.importance.rawValue as NSString
            let isDone = item.isDone ? 1 : 0
            let createdAt = String(item.createdAt.dateIntValue ?? 0)
            let hexColor = item.hexColor as NSString
            let lastUpdatedBy = item.lastUpdatedBy as NSString
            let id = item.id as NSString
            
            if let deadline = item.deadline, let deadlineIntValue = deadline.dateIntValue {
                sqlite3_bind_int64(updateStatement, 3, Int64(deadlineIntValue))
            } else {
                sqlite3_bind_null(updateStatement, 3)
            }
            
            if let changesAt = item.changesAt, let changesAtIntValue = changesAt.dateIntValue {
                sqlite3_bind_int64(updateStatement, 6, Int64(changesAtIntValue))
            } else {
                sqlite3_bind_null(updateStatement, 6)
            }
            
            sqlite3_bind_text(updateStatement, 1, text.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, importance.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 4, Int32(isDone))
            sqlite3_bind_text(updateStatement, 5, createdAt, -1, nil)
            sqlite3_bind_text(updateStatement, 7, hexColor.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 8, lastUpdatedBy.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 9, id.utf8String, -1, nil)
            
            if sqlite3_step(updateStatement) != SQLITE_DONE {
                throw DataBaseManagerError.errorUpdateRow
            }
        } else {
            throw DataBaseManagerError.errorUpdateRow
        }
        
        sqlite3_finalize(updateStatement)
    }
    
    func deleteItem(_ item: TodoItem) throws {
        let deleteStatementString = "DELETE FROM TodoItem WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dataBase, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, item.id, -1, nil)
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                throw DataBaseManagerError.errorDeleteRow
            }
        } else {
            throw DataBaseManagerError.errorDeleteRow
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func loadItems(_ completion: (Result<[TodoItem], Error>) -> Void) throws {
        let queryStatementString = "SELECT * FROM TodoItem;"
        var queryStatement: OpaquePointer? = nil
        var todoItemList: [TodoItem] = []
        
        if sqlite3_prepare_v2(dataBase, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let text = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let importance = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let isDoneString = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let createdAt = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let hexColor = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                let lastUpdatedBy = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                
                let deadline: String?
                if let columnText = sqlite3_column_text(queryStatement, 3) {
                    deadline = String(cString: columnText)
                } else {
                    deadline = nil
                }
                
                let changesAt: String?
                if let columnText = sqlite3_column_text(queryStatement, 6) {
                    changesAt = String(cString: columnText)
                } else {
                    changesAt = nil
                }
                
                let isDone = isDoneString == "1"
                let deadlineDate = !(deadline?.isEmpty ?? false) ? Int(deadline ?? "")?.dateValue : nil
                let createdAtDate = Int(createdAt)?.dateValue ?? Date()
                let changesAtDate = !(changesAt?.isEmpty ?? false) ? Int(changesAt ?? "")?.dateValue : nil
                
                let todoItem = TodoItem(
                    id: id,
                    text: text,
                    importance: Importance(rawValue: importance) ?? Importance.normal,
                    deadline: deadlineDate,
                    isDone: isDone,
                    createdAt: createdAtDate,
                    changesAt: changesAtDate,
                    hexColor: hexColor,
                    lastUpdatedBy: lastUpdatedBy
                )
                
                todoItemList.append(todoItem)
            }
            completion(.success(todoItemList))
        } else {
            completion(.failure(DataBaseManagerError.errorLoadFromDB))
        }
        
        sqlite3_finalize(queryStatement)
        
    }
}
