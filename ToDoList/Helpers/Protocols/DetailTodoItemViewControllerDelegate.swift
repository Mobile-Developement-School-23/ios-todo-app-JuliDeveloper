import UIKit

@MainActor
protocol DetailTodoItemViewControllerDelegate: AnyObject {
    func setupStateDeleteButton(from state: Bool)
    func setupColor(_ color: UIColor)
}
