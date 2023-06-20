import Foundation

protocol DetailTodoItemViewDelegate: AnyObject {
    func didUpdateText(_ text: String)
    func didUpdateImportance(_ importance: Importance)
    func didUpdateDeadline(_ deadline: Date?)
}
