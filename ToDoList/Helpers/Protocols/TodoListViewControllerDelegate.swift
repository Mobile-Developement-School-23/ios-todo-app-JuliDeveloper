import UIKit

protocol TodoListViewControllerDelegate: AnyObject {
    func openDetailViewController(_ todoItem: TodoItem?, transitioningDelegate: UIViewControllerTransitioningDelegate?, presentationStyle: UIModalPresentationStyle)
    func showCompletionItem()
    func updateCompletedTasksLabel() -> Int
}
