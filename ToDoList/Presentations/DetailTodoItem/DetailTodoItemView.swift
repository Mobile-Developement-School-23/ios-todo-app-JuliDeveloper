import UIKit

final class DetailTodoItemView: UIView {
    
    //MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Что надо сделать?"
        textView.textColor = .tdLabelTertiaryColor
        textView.font = UIFont.tdBody
        textView.backgroundColor = .tdBackSecondaryColor
        textView.layer.cornerRadius = Constants.radius
        textView.textContainerInset = UIEdgeInsets(
            top: 17, left: 16, bottom: 12, right: 16
        )
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let detailView: UIView = {
        let view = UIView()
        view.backgroundColor = .tdBackSecondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.radius
        return view
    }()
    
    private let mainStackView = DetailMainStackView()
    
    private let bottomAnchorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.tintColor = .tdRedColor
        button.titleLabel?.font = UIFont.tdBody
        button.backgroundColor = .tdBackSecondaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.layer.cornerRadius = Constants.radius
        button.isEnabled = false
        button.addTarget(
            self,
            action: #selector(deleteItem),
            for: .touchUpInside
        )
        return button
    }()
    
    private let uiColorMarshallings = UIColorMarshallings()
    
    private var isSelectedDeadline = false
    private var containerViewLeading: NSLayoutConstraint?
    private var containerViewTrailing: NSLayoutConstraint?
    
    weak var delegate: DetailTodoItemViewDelegate?
    
    //MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraintForInterfaceOrientation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Method configure view
    func configureView(delegate: DetailTodoItemViewController, _ item: TodoItem?, colorButtonAction: @escaping ((CustomColorPickerViewController) -> Void)) {
        backgroundColor = .tdBackPrimaryColor
        
        self.delegate = delegate
        titleTextView.delegate = delegate
        mainStackView.delegate = self
        
        mainStackView.passAction(colorButtonAction)
        
        addElements()
        setupConstraints()
        setupObservers()
        
        scrollView.contentSize = containerView.bounds.size
        
        checkItem(item)
    }
}

//MARK: - Actions
extension DetailTodoItemView {
    @objc private func deleteItem() {
        delegate?.deleteItem()
    }
    
    @objc private func handleKeyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardSize.cgRectValue.height

        scrollView.contentInset = UIEdgeInsets(
            top: 0, left: 0, bottom: keyboardHeight, right: 0
        )
    }
    
    @objc private func handleKeyboardDidShow() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnScrollView))
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleKeyboardWillHide() {
        if let gestures = scrollView.gestureRecognizers {
            for gesture in gestures {
                if gesture is UITapGestureRecognizer {
                    scrollView.removeGestureRecognizer(gesture)
                }
            }
        }
        
        scrollView.contentInset = UIEdgeInsets.zero
    }

    @objc private func handleTapOnScrollView() {
        scrollView.endEditing(true)
    }
}

//MARK: - Private methods
extension DetailTodoItemView {
    private func addElements() {
        addSubview(scrollView)
        
        scrollView.addSubview(containerView)
        
        [titleTextView,
         detailView,
         deleteButton,
         bottomAnchorView
        ].forEach {
            containerView.addSubview($0)
        }
        
        detailView.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            scrollView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            
            containerView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            containerView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            
            titleTextView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            titleTextView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: 16
            ),
            titleTextView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            titleTextView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 120
            ),
            
            detailView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            detailView.topAnchor.constraint(
                equalTo: titleTextView.bottomAnchor,
                constant: 16
            ),
            detailView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            
            mainStackView.leadingAnchor.constraint(
                equalTo: detailView.leadingAnchor,
                constant: 16
            ),
            mainStackView.topAnchor.constraint(
                equalTo: detailView.topAnchor
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: detailView.trailingAnchor,
                constant: -16
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: detailView.bottomAnchor
            ),
            
            deleteButton.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            deleteButton.topAnchor.constraint(
                equalTo: detailView.bottomAnchor,
                constant: 16
            ),
            deleteButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            
            bottomAnchorView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            bottomAnchorView.topAnchor.constraint(
                equalTo: deleteButton.bottomAnchor
            ),
            bottomAnchorView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            bottomAnchorView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])
    }
    
    private func checkItem(_ item: TodoItem?) {
        if item != nil {
            titleTextView.text = item?.text
            titleTextView.textColor = uiColorMarshallings.fromHexString(hex: item?.hexColor ?? "")
            mainStackView.setUiIfItemNotNil(from: item)
            deleteButton.isEnabled = true
        } else {
            titleTextView.text = "Что надо сделать?"
            mainStackView.setUiIfItemNil()
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupConstraintForInterfaceOrientation() {
        containerViewLeading?.isActive = false
        containerViewTrailing?.isActive = false
        
        if let interfaceOrientation = UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .first?.interfaceOrientation {
            
            switch interfaceOrientation {
            case .portrait, .portraitUpsideDown:
                containerViewLeading = containerView.leadingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                    constant: 16
                )
                containerViewTrailing = containerView.trailingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                    constant: -16
                )
            case .landscapeLeft, .landscapeRight:
                containerViewLeading = containerView.leadingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                    constant: 50
                )
                containerViewTrailing = containerView.trailingAnchor.constraint(
                    equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                    constant: -50
                )
            default:
                break
            }
        }
        
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
    }
}

//MARK: - DetailTodoItemViewControllerDelegate
extension DetailTodoItemView: DetailTodoItemViewControllerDelegate {
    func setupStateDeleteButton(from state: Bool) {
        deleteButton.isEnabled = state
    }
    
    func setupColor(_ color: UIColor) {
        mainStackView.getColorButton(with: color)
        titleTextView.textColor = color
    }
}

//MARK: - DetailMainStackViewDelegate
extension DetailTodoItemView: DetailMainStackViewDelegate {
    func didUpdateImportance(_ importance: Importance) {
        delegate?.didUpdateImportance(importance)
    }
    
    func didUpdateDeadline(_ deadline: Date?) {
        delegate?.didUpdateDeadline(deadline)
    }
}
