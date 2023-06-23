import UIKit

final class DetailMainStackView: UIStackView {
    
    //MARK: - Properties
    private let importanceStackView = ImportanceStackView()
    private let selectColorStackView = SelectColorStackView()
    private let dateStackView = DateStackView()
    
    private let firstSeparatorView = SeparatorView()
    private let secondSeparatorView = SeparatorView()
    private let theirSeparatorView = SeparatorView()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "Ru_ru")
        picker.calendar.firstWeekday = 2
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged),
            for: .valueChanged
        )
        return picker
    }()
    
    private let uiColorMarshallings: ColorMarshallingsProtocol
    
    weak var delegate: DetailMainStackViewDelegate?
    
    //MARK: - Initialization
    init(uiColorMarshallings: ColorMarshallingsProtocol = UIColorMarshallings()) {
        self.uiColorMarshallings = uiColorMarshallings
        super.init(frame: .zero)
        configure()
        addElements()
        
        DispatchQueue.main.async() {
            self.datePicker.isHidden = true
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func passAction(_ action: @escaping (CustomColorPickerViewController) -> Void) {
        selectColorStackView.buttonAction = action
    }
    
    func setUiIfItemNotNil(from item: TodoItem?) {
        selectColorStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = uiColorMarshallings.fromHexString(hex: item?.hexColor ?? "")
            }
        }
        
        importanceStackView.setSelectedSegmentIndex(from: item?.importance ?? Importance.normal)
        dateStackView.checkItemDeadline(from: item, datePicker)
    }
    
    func setUiIfItemNil() {
        importanceStackView.setDefaultSelectedSegmentIndex()
        getColorButton(with: .tdLabelPrimaryColor)
    }
    
    func getColorButton(with color: UIColor) {
        selectColorStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = color
            }
        }
    }
 
    //MARK: - Actions
    @objc private func datePickerValueChanged() {
        dateStackView.setDateButtonTitle(datePicker.date.dateForLabel)
        delegate?.didUpdateDeadline(datePicker.date)
    }
    
    //MARK: - Private methods
    private func configure() {
        axis = .vertical
        distribution = .fill
        backgroundColor = .tdBackSecondaryColor
        translatesAutoresizingMaskIntoConstraints = false
        
        dateStackView.delegate = self
        importanceStackView.delegate = self
        
        theirSeparatorView.isHidden = true
    }
    
    private func addElements() {
        [
            importanceStackView,
            firstSeparatorView,
            selectColorStackView,
            secondSeparatorView,
            dateStackView,
            theirSeparatorView,
            datePicker
        ].forEach {
            addArrangedSubview($0)
        }
    }
    
    private func defaultConfigureDatePicker() {
        let calendar = Calendar.current
        datePicker.minimumDate = calendar.startOfDay(for: Date())
        let selectedDate = datePicker.date
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
            datePicker.date = nextDay
            dateStackView.setDateButtonTitle(nextDay.dateForLabel)
            delegate?.didUpdateDeadline(nextDay)
        }
    }
}

extension DetailMainStackView: DateStackViewDelegate {
    func updateDeadline(_ deadline: Date?) {
        delegate?.didUpdateDeadline(deadline)
    }
    
    func updateDatePicker(opacity: Float, hidden: Bool) {
        datePicker.layer.opacity = opacity
        datePicker.isHidden = hidden
    }
    
    func updateDatePicker(date: Date) {
        datePicker.date = date
    }
    
    func updateSeparatorView(hidden: Bool) {
        theirSeparatorView.isHidden = hidden
    }
    
    func getDateFromDatePicker() -> Date? {
        datePicker.date
    }
    
    func setDefaultConfigurationDatePicker() {
        defaultConfigureDatePicker()
    }
}

extension DetailMainStackView: ImportanceStackViewDelegate {
    func updateImportance(_ importance: Importance) {
        delegate?.didUpdateImportance(importance)
    }
}
