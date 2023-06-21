import UIKit

final class CustomColorPickerViewController: UIViewController {
    
    //MARK: - Properties
    private let closeView: UIView = {
        let view = UIView()
        view.backgroundColor = .tdBackSecondaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let currentColorStackView = ColorStackViewColorPicker()
    
    private let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.radius
        return view
    }()
    
    private let indicator: UIView = {
        let indicator = UIView()
        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicator.layer.cornerRadius = 30 / 2
        indicator.layer.borderWidth = 2
        indicator.layer.borderColor = UIColor.tdBackPrimaryColor.cgColor
        return indicator
    }()
    
    private var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.orange.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor,
            UIColor.purple.cgColor,
            UIColor.red.cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        return gradientLayer
    }()
    
    private lazy var opacitySlider = OpacitySlider()
    
    private let uiColorMarshallings = UIColorMarshallings()
    private var currentColor = UIColor()
    private var alpha = Float()

    var currentHexColor = ""
    
    weak var delegate: DetailTodoItemViewDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .tdBackPrimaryColor
        addElements()
        setupConstraints()
        
        currentColor = uiColorMarshallings.fromHexString(hex: currentHexColor)
        currentColorStackView.setColor(currentColor, hexColor: currentHexColor)
        opacitySlider.setupColorsGradient(
            color: uiColorMarshallings.fromHexString(hex: currentHexColor)
        )
        
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        colorView.addGestureRecognizer(panRecognizer)
        
        opacitySlider.addTarget(
            self,
            action: #selector(changeValue),
            for: .valueChanged
        )
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = colorView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let color = uiColorMarshallings.fromHexString(hex: currentHexColor)
        delegate?.didUpdateColor(color)
    }
    
    //MARK: - Actions
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: colorView)
        let color = gradientLayer.pickColor(at: point)
        
        indicator.center = CGPoint(x: point.x, y: point.y)
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
    
    //MARK: - Private methods
    private func addElements() {
        [
            closeView,
            currentColorStackView,
            colorView,
            opacitySlider
        ].forEach {
            view.addSubview($0)
        }
        
        colorView.layer.addSublayer(gradientLayer)
        colorView.addSubview(indicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 10
            ),
            closeView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            closeView.heightAnchor.constraint(
                equalToConstant: 5
            ),
            closeView.widthAnchor.constraint(
                equalToConstant: 60
            ),
            
            currentColorStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            currentColorStackView.topAnchor.constraint(
                equalTo: closeView.bottomAnchor, constant: 20
            ),
            
            colorView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            colorView.topAnchor.constraint(
                equalTo: currentColorStackView.bottomAnchor,
                constant: 20
            ),
            colorView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            
            opacitySlider.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            opacitySlider.topAnchor.constraint(
                equalTo: colorView.bottomAnchor,
                constant: 50
            ),
            opacitySlider.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            opacitySlider.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -70
            )
        ])
    }
}
