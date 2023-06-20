import UIKit

final class DetailTodoItemViewController: UIViewController {
    
    override func loadView() {
        let customView = DetailTodoItemView()
        customView.configureView(delegate: self)
        view = customView
    }
    
    override func viewDidLoad() {
        configureNavBar()
    }
    
    private func configureNavBar() {
        title = "Дело"
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(save)
        )
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func save() {
        view.endEditing(true)
        
        dismiss(animated: true)
    }
}

extension DetailTodoItemViewController: UITextViewDelegate {
    
}
