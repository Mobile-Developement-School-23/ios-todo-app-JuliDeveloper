import UIKit

final class PreviewViewController: UIViewController {
    
    // MARK: - Properties
    var todoItem: TodoItem?
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        let customView = PreviewView()
        customView.configure(from: todoItem)
        view = customView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
