import UIKit

final class PreviewViewController: UIViewController {
    
    var todoItem: TodoItem?
    
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
