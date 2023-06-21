import UIKit

protocol DetailTodoItemViewControllerDelegate: AnyObject {
    func setupStateDeleteButton(from textView: UITextView)
    func setupColor(_ color: UIColor)
}
