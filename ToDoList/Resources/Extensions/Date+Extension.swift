import Foundation

private let dateTimeDefaultFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = .withFullDate
    return dateFormatter
}()

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "Ru_ru")
    dateFormatter.dateFormat = "dd MMMM yyyy"
    return dateFormatter
}()

private let dateFormatterWithoutYear: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "Ru_ru")
    dateFormatter.dateFormat = "dd MMMM"
    return dateFormatter
}()

extension Date {
    var dateForLabel: String { dateFormatter.string(from: self) }
    var dateForLabelWithoutYear: String { dateFormatterWithoutYear.string(from: self) }
    var dateTimeString: String { dateTimeDefaultFormatter.string(from: self) }
    
    var dateIntValue: Int? {
        if let date = dateTimeDefaultFormatter.date(from: self.dateTimeString) {
            return Int(date.timeIntervalSince1970)
        }
        return nil
    }
}
