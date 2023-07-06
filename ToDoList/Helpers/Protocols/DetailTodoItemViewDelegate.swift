import UIKit

@MainActor
protocol DetailTodoItemViewDelegate: AnyObject {
    func didUpdateText(_ text: String)
    func didUpdateImportance(_ importance: Importance)
    func didUpdateDeadline(_ deadline: Date?)
    func didUpdateColor(_ color: UIColor)
    func deleteItem()
}
