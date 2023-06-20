import UIKit

final class DetailTodoItemViewController: UIViewController {
    
    private var currentText = String()
    private var currentImportance = Importance.normal
    private var currentDeadline: Date? = nil
    
    private var viewModel: TodoListViewModel
    
    var todoItem: TodoItem?
    
    weak var delegate: DetailTodoItemViewControllerDelegate?
    
    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let customView = DetailTodoItemView()
        customView.configureView(delegate: self, todoItem)
        self.delegate = customView
        view = customView
    }
    
    override func viewDidLoad() {
        configureNavBar()
        checkItem()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.setNeedsUpdateConstraints()
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
    
    private func checkItem() {
        if todoItem != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
            currentText = todoItem?.text ?? ""
            currentImportance = todoItem?.importance ?? Importance.normal
            currentDeadline = todoItem?.deadline ?? nil
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func save() {
        view.endEditing(true)
        
        if todoItem != nil {
            let oldItem = TodoItem(
                id: todoItem?.id ?? "",
                text: currentText,
                importance: currentImportance,
                deadline: currentDeadline
            )
            viewModel.addItem(oldItem)
        } else {
            let newItem = TodoItem(
                text: currentText,
                importance: currentImportance,
                deadline: currentDeadline
            )
            viewModel.addItem(newItem)
        }
        
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
        delegate?.setupStateDeleteButton(from: textView)
    }
}

extension DetailTodoItemViewController: DetailTodoItemViewDelegate {
    func didUpdateText(_ text: String) {
        currentText = text
    }
    
    func didUpdateImportance(_ importance: Importance) {
        currentImportance = importance
    }
    
    func didUpdateDeadline(_ deadline: Date?) {
        currentDeadline = deadline
    }
    
    func deleteItem() {
        if todoItem != nil {
            viewModel.deleteItem(with: todoItem?.id ?? "")
        }
        dismiss(animated: true)
    }
}
