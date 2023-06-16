import Foundation

extension Int {
    var dateValue: Date? {
        return Date(timeIntervalSince1970: Double(self))
    }
}
