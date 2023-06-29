import Foundation

protocol TodoListViewDelegate: AnyObject {
    func reloadTableView()
    func setEditing(_ state: Bool)
    func getIndexPath(for cell: TodoTableViewCell) -> IndexPath?
    func updateCompletedLabel(count: Int)
}
