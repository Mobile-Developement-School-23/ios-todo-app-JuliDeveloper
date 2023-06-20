import UIKit

class ViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tdBackPrimaryColor
        setupButton()
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
        let detailVC = DetailTodoItemViewController()
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}
