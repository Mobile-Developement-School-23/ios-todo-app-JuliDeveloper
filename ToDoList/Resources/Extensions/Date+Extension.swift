import Foundation

private let dateTimeDefaultFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = .withFullDate
    return dateFormatter
}()

extension Date {
    var dateTimeString: String { dateTimeDefaultFormatter.string(from: self) }
    
    var dateIntValue: Int? {
        if let date = dateTimeDefaultFormatter.date(from: self.dateTimeString) {
            return Int(date.timeIntervalSince1970)
        }
        return nil
    }
}
