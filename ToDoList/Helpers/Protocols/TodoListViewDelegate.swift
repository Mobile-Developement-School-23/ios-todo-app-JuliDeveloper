import Foundation

@MainActor
protocol TodoListViewDelegate: AnyObject {
    func startLoading()
    func finishLoading()
    func reloadTableView()
    func setEditing(_ state: Bool)
    func getIndexPath(for cell: TodoTableViewCell) -> IndexPath?
    func updateCompletedLabel(count: Int)
}
