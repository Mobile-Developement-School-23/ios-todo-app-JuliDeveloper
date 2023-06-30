import UIKit

final class CustomColorPickerViewController: UIViewController {
    
    // MARK: - Properties
    private let currentColorStackView = ColorStackViewColorPicker()
    private let gradientView = GradientView()
    
    private let indicator: UIView = {
        let indicator = UIView()
        indicator.frame = CGRect(x: 0, y: 0, width: Constants.sizeIndicator, height: Constants.sizeIndicator)
        indicator.layer.cornerRadius = CGFloat(Constants.sizeIndicator / 2)
        indicator.layer.borderWidth = 2
        indicator.layer.borderColor = UIColor.tdBackPrimaryColor.cgColor
        return indicator
    }()
    
    private lazy var opacitySlider = OpacitySliderColorPicker()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .tdSupportOverlayColor
        button.setImage(UIImage(named: "close"), for: .normal)
        button.tintColor = .tdLabelTertiaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: Constants.heightRoundButton).isActive = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.layer.cornerRadius = Constants.heightRoundButton / 2
        button.addTarget(
            self,
            action: #selector(close),
            for: .touchUpInside
        )
        return button
    }()
    
    private let uiColorMarshallings: ColorMarshallingsProtocol
    
    private var currentColor = UIColor()
    private var alpha = Float()

    var currentHexColor = ""
    
    weak var delegate: DetailTodoItemViewDelegate?
    
    // MARK: - Lifecycle
    init(uiColorMarshallings: ColorMarshallingsProtocol = UIColorMarshallings()) {
        self.uiColorMarshallings = uiColorMarshallings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .tdBackPrimaryColor
        addElements()
        setupConstraints()
        
        if currentHexColor.isEmpty {
            currentColor = .tdLabelPrimaryColor
            currentHexColor = uiColorMarshallings.toHexString(color: currentColor)
        } else {
            currentColor = uiColorMarshallings.fromHexString(hex: currentHexColor)
        }
        
        currentColorStackView.setColor(currentColor, hexColor: currentHexColor)
        opacitySlider.setupColorsGradient(
            color: uiColorMarshallings.fromHexString(hex: currentHexColor)
        )
        
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        gradientView.addGestureRecognizer(panRecognizer)
        
        opacitySlider.addTarget(
            self,
            action: #selector(changeValue),
            for: .valueChanged
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passColor()
    }
    
    // MARK: - Actions
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        var point = gestureRecognizer.location(in: gradientView)
        let color = gradientView.getColor(from: point)
        
        if point.x < 0 {
             point.x = 0
         } else if point.x > gradientView.bounds.width {
             point.x = gradientView.bounds.width
         }

         if point.y < 0 {
             point.y = 0
         } else if point.y > gradientView.bounds.height {
             point.y = gradientView.bounds.height
         }
        
        indicator.center = point
        indicator.backgroundColor = color
        currentColor = color
        
        currentHexColor = uiColorMarshallings.toHexString(color: currentColor)

        opacitySlider.setupColorsGradient(color: currentColor)
        currentColorStackView.setColor(currentColor, hexColor: currentHexColor)
    }
    
    @objc private func changeValue() {
        alpha = opacitySlider.value
        
        let colorWithAlpha = currentColor.withAlphaComponent(CGFloat(alpha))
        currentHexColor = uiColorMarshallings.toHexString(color: colorWithAlpha)

        opacitySlider.setupColorsGradient(
            color: uiColorMarshallings.fromHexString(hex: currentHexColor)
        )
        currentColorStackView.setColor(
            uiColorMarshallings.fromHexString(hex: currentHexColor),
            hexColor: currentHexColor
        )
    }
    
    @objc private func close() {
        passColor()
        dismiss(animated: true)
    }
    
    // MARK: - Private methods
    private func addElements() {
        [
            closeButton,
            currentColorStackView,
            gradientView,
            opacitySlider
        ].forEach {
            view.addSubview($0)
        }
        
        gradientView.addSubview(indicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            
            currentColorStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            currentColorStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            
            gradientView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            gradientView.topAnchor.constraint(
                equalTo: currentColorStackView.bottomAnchor,
                constant: 20
            ),
            gradientView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            
            opacitySlider.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            opacitySlider.topAnchor.constraint(
                equalTo: gradientView.bottomAnchor,
                constant: 30
            ),
            opacitySlider.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            opacitySlider.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -30
            )
        ])
    }
    
    private func passColor() {
        let color = uiColorMarshallings.fromHexString(hex: currentHexColor)
        delegate?.didUpdateColor(color)
    }
}
