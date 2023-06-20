import UIKit

final class DetailTodoItemViewController: UIViewController {
    
    private var currentText = String()
    private var currentImportance = Importance.normal
    private var currentDeadline: Date? = nil
    
    private var viewModel: TodoListViewModel
    
    var todoItem: TodoItem?
    
    override func loadView() {
        let customView = DetailTodoItemView()
        customView.configureView(delegate: self, todoItem)
        view = customView
    }
    
    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = currentText
        textView.textColor = .tdLabelPrimaryColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = .tdLabelTertiaryColor
        } else {
            currentText = textView.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.text.isEmpty ? false : true
    }
}
