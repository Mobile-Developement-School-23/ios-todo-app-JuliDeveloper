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
    
    private let titleLabelImportance = CustomLabel(text: "Важность")
    private let titleLabelDate = CustomLabel(text: "Сделать до")
    
    private let detailView: UIView = {
        let view = UIView()
        view.backgroundColor = .tdBackSecondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.radius
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.backgroundColor = .tdBackSecondaryColor
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let importanceStackView = CustomStackView()
    private let dateStackView = CustomStackView()
    
    private let deadlineStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.alignment = .leading
        return stack
    }()
    
    private let firstSeparatorView = SeparatorView()
    private let secondSeparatorView = SeparatorView()
    
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
    
    private lazy var importanceSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["", "нет", ""])
        control.setImage(UIImage(named: "unimportant"), forSegmentAt: 0)
        control.setImage(UIImage(named: "importance"), forSegmentAt: 2)
        control.selectedSegmentIndex = 1
        control.backgroundColor = .tdSupportOverlayColor
        control.tintColor = .tdBackElevatedColor
        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(equalToConstant: 150).isActive = true
        control.addTarget(
            self,
            action: #selector(selectedImportance),
            for: .valueChanged
        )
        return control
    }()
    
    private lazy var selectDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 0
        )
        button.setTitle("2 июня 2021", for: .normal)
        button.tintColor = .tdBlueColor
        button.titleLabel?.font = .tdFootnote
        button.addTarget(
            self,
            action: #selector(selectDate),
            for: .touchUpInside
        )
        button.isHidden = true
        button.alpha = 0
        return button
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
    
    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(
            self,
            action: #selector(switchDeadline),
            for: .touchUpInside
        )
        return control
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = .current
        picker.calendar.firstWeekday = 2
        picker.isHidden = true
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        return picker
    }()
    
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
    func configureView(delegate: DetailTodoItemViewController, _ item: TodoItem?) {
        backgroundColor = .tdBackPrimaryColor
        
        self.delegate = delegate
        titleTextView.delegate = delegate
        
        addElements()
        setupConstraints()
        setupObservers()
        
        scrollView.contentSize = containerView.bounds.size
        secondSeparatorView.isHidden = true
        
        checkItem(item)
    }
}

//MARK: - Actions
extension DetailTodoItemView {
    @objc private func selectDate() {
        isSelectedDeadline.toggle()
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            
            self.secondSeparatorView.isHidden = !self.isSelectedDeadline
            self.datePicker.isHidden = !self.isSelectedDeadline
            
            self.layoutIfNeeded()
        })
    }
    
    @objc private func switchDeadline() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            
            self.selectDateButton.alpha = switchControl.isOn ? 1 : 0
            self.selectDateButton.isHidden = switchControl.isOn ? false : true
            
            self.layoutIfNeeded()
        })
        
        if isSelectedDeadline {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let self = self else { return }
                
                self.isSelectedDeadline = false
                self.secondSeparatorView.isHidden = true
                self.datePicker.isHidden = true
                self.datePicker.date = Date()
                
                self.layoutIfNeeded()
            })
        }
        
        if switchControl.isOn == false {
            datePicker.date = Date()
            selectDateButton.setTitle(datePicker.date.dateForLabel, for: .normal)
            delegate?.didUpdateDeadline(nil)
        } else {
            defaultConfigureDatePicker()
        }
    }
    
    @objc private func datePickerValueChanged() {
        selectDateButton.setTitle(datePicker.date.dateForLabel, for: .normal)
        delegate?.didUpdateDeadline(datePicker.date)
    }
    
    @objc private func selectedImportance() {
        var importance = Importance.normal
        
        switch importanceSegmentedControl.selectedSegmentIndex {
        case 0: importance = .unimportant
        case 2: importance = .important
        default: importance = .normal
        }
        
        delegate?.didUpdateImportance(importance)
    }
    
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
        
        [titleTextView, detailView, deleteButton, bottomAnchorView].forEach {
            containerView.addSubview($0)
        }
        
        detailView.addSubview(mainStackView)
        
        [importanceStackView, firstSeparatorView, dateStackView, secondSeparatorView, datePicker].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        [titleLabelImportance, importanceSegmentedControl].forEach {
            importanceStackView.addArrangedSubview($0)
        }
        
        [deadlineStackView, switchControl].forEach {
            dateStackView.addArrangedSubview($0)
        }
        
        [titleLabelDate, selectDateButton].forEach {
            deadlineStackView.addArrangedSubview($0)
        }
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
    
    private func defaultConfigureDatePicker() {
        let calendar = Calendar.current
        datePicker.minimumDate = calendar.startOfDay(for: Date())
        let selectedDate = datePicker.date
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            datePicker.date = nextDay
            selectDateButton.setTitle(nextDay.dateForLabel, for: .normal)
            delegate?.didUpdateDeadline(nextDay)
        }
    }
    
    private func checkItem(_ item: TodoItem?) {
        if item != nil {
            titleTextView.text = item?.text
            titleTextView.textColor = .tdLabelPrimaryColor
            
            switch item?.importance {
            case .important: importanceSegmentedControl.selectedSegmentIndex = 2
            case .unimportant: importanceSegmentedControl.selectedSegmentIndex = 0
            default: importanceSegmentedControl.selectedSegmentIndex = 1
            }
            
            if item?.deadline != nil {
                switchControl.isOn = true
                selectDateButton.setTitle(
                    item?.deadline?.dateForLabel,
                    for: .normal
                )
                selectDateButton.isHidden = false
                selectDateButton.alpha = 1
                datePicker.date = item?.deadline ?? Date()
            }
            
            deleteButton.isEnabled = true
        } else {
            titleTextView.text = "Что надо сделать?"
            importanceSegmentedControl.selectedSegmentIndex = 1
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

extension DetailTodoItemView: DetailTodoItemViewControllerDelegate {
    func setupStateDeleteButton(from textView: UITextView) {
        deleteButton.isEnabled = textView.text.isEmpty ? false : true
    }
}
