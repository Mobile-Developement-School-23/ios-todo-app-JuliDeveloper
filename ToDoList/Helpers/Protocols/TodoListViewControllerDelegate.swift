import UIKit

@MainActor
protocol TodoListViewControllerDelegate: AnyObject {
    func openDetailViewController(_ todoItem: TodoItem?, transitioningDelegate: UIViewControllerTransitioningDelegate?, presentationStyle: UIModalPresentationStyle)
    func showCompletionItem()
    func updateCompletedTasksLabel() -> Int
    func startLargeIndicatorAnimation()
    func finishLargeIndicatorAnimation()
}
