import UIKit

final class DateStackView: CustomStackView {
    
    //MARK: - Properties
    private let titleLabelDate = CustomLabel(text: "Сделать до")
    
    private let deadlineStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalCentering
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.subviews[0].subviews[0].backgroundColor = .tdSupportOverlayColorForSwitch
        control.addTarget(
            self,
            action: #selector(switchDeadline),
            for: .touchUpInside
        )
        return control
    }()
    
    private lazy var selectDateButton: UIButton = {
        let button = UIButton(type: .system)
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
    
    private var isSelectedDeadline = false
    
    weak var delegate: DateStackViewDelegate?
    
    //MARK: - Initialization
    override init() {
        super.init()
        addElements()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func checkItemDeadline(from item: TodoItem?, _ datePicker: UIDatePicker) {
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
    }
    
    func setDateButtonTitle(_ title: String) {
        selectDateButton.setTitle(title, for: .normal)
    }
    
    //MARK: - Actions
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
                self.delegate?.updateSeparatorView(hidden: true)
                self.delegate?.updateDatePicker(opacity: 1, hidden: true)
                self.delegate?.updateDatePicker(date: Date())
                
                self.layoutIfNeeded()
            })
        }
        
        if switchControl.isOn == false {
            delegate?.updateDatePicker(date: Date())
            self.delegate?.updateDatePicker(opacity: 0, hidden: true)
            let currentDate = delegate?.getDateFromDatePicker()
            selectDateButton.setTitle(currentDate?.dateForLabel, for: .normal)
            delegate?.updateDeadline(nil)
        } else {
            delegate?.setDefaultConfigurationDatePicker()
        }
    }
    
    @objc private func selectDate() {
        isSelectedDeadline.toggle()
        let currentOpacity = isSelectedDeadline ? 1 : 0
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.updateSeparatorView(hidden: !self.isSelectedDeadline)
            self.delegate?.updateDatePicker(opacity: Float(currentOpacity), hidden: !self.isSelectedDeadline)
            
            self.layoutIfNeeded()
        })
    }
    
    //MARK: - Private methods
    private func addElements() {
        [
            deadlineStackView,
            switchControl
        ].forEach {
            addArrangedSubview($0)
        }
        
        [
            titleLabelDate,
            selectDateButton
        ].forEach {
            deadlineStackView.addArrangedSubview($0)
        }
    }
}
