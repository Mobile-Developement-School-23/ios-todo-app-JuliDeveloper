import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let useCoreDataKey = "useCoreData"
    
    var useCoreData: Bool {
        get {
            userDefaults.bool(forKey: useCoreDataKey)
        }
        set {
            userDefaults.set(newValue, forKey: useCoreDataKey)
        }
    }
 
    private init() {}
}
