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
    
    private let currentColorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let hexCurrentColorLabel = CustomLabel(text: "#000000")
    
    private let currentColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 34).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.tdSupportOverlayColor.withAlphaComponent(0.1).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 34 / 2
        return view
    }()
    
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
    
    private var currentColor = UIColor()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .tdBackPrimaryColor
        addElements()
        setupConstraints()
        
        currentColor = .orange
        let panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        colorView.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = colorView.bounds
    }
    
    //MARK: - Actions
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: colorView)
        let color = gradientLayer.pickColor(at: point)
        
        indicator.center = CGPoint(x: point.x, y: point.y)
        indicator.backgroundColor = color
        
        currentColor = color
        opacitySlider.setupColorsGradient(color: currentColor)
        currentColorView.backgroundColor = currentColor
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
        
        [
            currentColorView,
            hexCurrentColorLabel
        ].forEach {
            currentColorStackView.addArrangedSubview($0)
        }
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
