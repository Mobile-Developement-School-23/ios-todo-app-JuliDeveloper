import UIKit

final class DetailTodoItemViewController: UIViewController {
    
    // MARK: - Properties
    private let uiColorMarshallings: ColorMarshallingsProtocol
    
    private var currentText = String()
    private var currentImportance = Importance.normal
    private var currentDeadline: Date? = nil
    private var currentColor: UIColor = .tdLabelPrimaryColor
    
    private var viewModel: TodoListViewModelSQLiteProtocol
    
    var todoItem: TodoItem?
    
    weak var delegate: DetailTodoItemViewControllerDelegate?
    weak var loadDelegate: TodoListViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(
        viewModel: TodoListViewModelSQLiteProtocol,
        uiColorMarshallings: ColorMarshallingsProtocol = UIColorMarshallings()
    ) {
        self.viewModel = viewModel
        self.uiColorMarshallings = uiColorMarshallings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let customView = DetailTodoItemView()
        customView.configureView(delegate: self, todoItem) { [weak self] viewController in
            guard let self = self else { return }
            viewController.delegate = self
            viewController.currentHexColor = self.todoItem?.hexColor ?? ""
            self.present(viewController, animated: true)
        }
        
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
    
    // MARK: - Actions
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func save() {
        view.endEditing(true)
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        if todoItem != nil {
            let oldItem = TodoItem(
                id: todoItem?.id ?? "",
                text: currentText,
                importance: currentImportance,
                deadline: currentDeadline,
                hexColor: uiColorMarshallings.toHexString(color: currentColor),
                lastUpdatedBy: deviceId
            )
            viewModel.updateItem(oldItem)
        } else {
            let newItem = TodoItem(
                text: currentText,
                importance: currentImportance,
                deadline: currentDeadline,
                isDone: false,
                hexColor: uiColorMarshallings.toHexString(color: currentColor),
                lastUpdatedBy: deviceId
            )
            viewModel.addItem(newItem)
        }
        
        dismiss(animated: true)
    }
}

// MARK: - Private methods
extension DetailTodoItemViewController {
    private func configureNavBar() {
        title = "Дело"
        
        let leftButton = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        let rightButton = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(save)
        )
        
        leftButton.tintColor = .tdBlueColor
        rightButton.tintColor = .tdBlueColor
    
        navigationItem.leftBarButtonItem = leftButton
        
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func checkItem() {
        if todoItem != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
            currentText = todoItem?.text ?? ""
            currentImportance = todoItem?.importance ?? Importance.normal
            currentDeadline = todoItem?.deadline ?? nil
            currentColor = uiColorMarshallings.fromHexString(
                hex: todoItem?.hexColor ?? ""
            )
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: - UITextViewDelegate
extension DetailTodoItemViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = currentText

        if todoItem != nil {
            textView.textColor = uiColorMarshallings.fromHexString(
                hex: todoItem?.hexColor ?? ""
            )
        } else {
            textView.textColor = .tdLabelPrimaryColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let inputText = textView.text

        if inputText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            textView.text = "Что надо сделать?"
            textView.textColor = .tdLabelTertiaryColor
        } else {
            let trimmedText = inputText?.trimmingCharacters(in: .whitespacesAndNewlines)
            currentText = trimmedText ?? ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let inputText = textView.text

        let isOnlySpaces = inputText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        navigationItem.rightBarButtonItem?.isEnabled = !isOnlySpaces
                
        delegate?.setupStateDeleteButton(from: !isOnlySpaces)
    }
}

// MARK: - DetailTodoItemViewDelegate
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
    
    func didUpdateColor(_ color: UIColor) {
        currentColor = color
        delegate?.setupColor(color)
    }
    
    func deleteItem() {
        showAlert { [weak self] _ in
            guard let self = self else { return }
            if self.todoItem != nil {
                guard let item = todoItem else { return }
                print(item)

            }
            dismiss(animated: true)
        }
    }
}
