import Foundation

final class RevisionStorage {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case versionRevision
    }
    
    var latestKnownRevision: Int {
        get {
            return userDefaults.integer(forKey: Keys.versionRevision.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.versionRevision.rawValue)
        }
    }
}
