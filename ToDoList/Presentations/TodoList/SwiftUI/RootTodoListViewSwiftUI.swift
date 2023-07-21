import UIKit
import SwiftUI

class RootTodoListViewSwiftUI: UIViewController {
    
    // MARK: - Properties
    private let storageManager: StorageManager
    private var viewModel: TodoListViewModel
    
    var selectedCell: TodoTableViewCell?
    
    // MARK: - Lifecycle
    init(
        storageManager: StorageManager = StorageManager.shared,
        viewModel: TodoListViewModel
    ) {
        self.storageManager = storageManager
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let childView = UIHostingController(rootView: ListTodoItems(viewModel: viewModel))
        addChild(childView)
        childView.view?.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
}
