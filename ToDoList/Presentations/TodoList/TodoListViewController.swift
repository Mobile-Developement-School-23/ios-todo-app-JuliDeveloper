import UIKit

class TodoListViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: TodoListViewModel
    
    private lazy var openButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Go", for: .normal)
        button.titleLabel?.font = UIFont.tdLargeTitle
        button.tintColor = .white
        button.layer.cornerRadius = Constants.radius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openDetailVC), for: .touchUpInside)
        return button
    }()

    //MARK: - Lifecycle
    init(viewModel: TodoListViewModel = TodoListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tdBackPrimaryColor
        
        viewModel.$todoItems.bind { [weak self] _ in
            self?.bindViewModel()
        }
        
        setupButton()
        bindViewModel()
    }
    
    //MARK: - Helpers
    private func bindViewModel() {
        print(viewModel.todoItems) // это временная функциональность
    }
    
    private func setupButton() {
        view.addSubview(openButton)
        
        NSLayoutConstraint.activate([
            openButton.widthAnchor.constraint(equalToConstant: 200),
            openButton.heightAnchor.constraint(equalToConstant: 50),
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func openDetailVC() {
        let detailVC = DetailTodoItemViewController(viewModel: viewModel)
        if !viewModel.todoItems.isEmpty {
            detailVC.todoItem = viewModel.todoItems[0]
        }
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}
