import Foundation

@MainActor
protocol DetailMainStackViewDelegate: AnyObject {
    func didUpdateDeadline(_ deadline: Date?)
    func didUpdateImportance(_ importance: Importance)
}
