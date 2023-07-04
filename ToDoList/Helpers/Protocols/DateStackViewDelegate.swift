import Foundation

@MainActor
protocol DateStackViewDelegate: AnyObject {
    func updateDeadline(_ deadline: Date?)
    func updateDatePicker(opacity: Float, hidden: Bool)
    func updateDatePicker(date: Date)
    func updateSeparatorView(hidden: Bool)
    func getDateFromDatePicker() -> Date?
    func setDefaultConfigurationDatePicker()
}
