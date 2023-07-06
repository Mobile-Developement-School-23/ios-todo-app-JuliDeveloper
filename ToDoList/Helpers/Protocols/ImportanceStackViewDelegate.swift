import Foundation

@MainActor
protocol ImportanceStackViewDelegate: AnyObject {
    func updateImportance(_ importance: Importance)
}
