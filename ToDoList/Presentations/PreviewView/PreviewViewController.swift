import UIKit

final class PreviewViewController: UIViewController {
    
    //MARK: - Properties
    var todoItem: TodoItem?
    
    //MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        let customView = PreviewView()
        customView.configure(from: todoItem)
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
