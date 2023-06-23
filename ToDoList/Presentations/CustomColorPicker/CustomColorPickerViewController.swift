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
    private let gradientView = GradientView()
    
    private let indicator: UIView = {
        let indicator = UIView()
        indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        indicator.layer.cornerRadius = 30 / 2
        indicator.layer.borderWidth = 2
        indicator.layer.borderColor = UIColor.tdBackPrimaryColor.cgColor
        return indicator
    }()
    
    private lazy var opacitySlider = OpacitySliderColorPicker()
    
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
        let color = uiColorMarshallings.fromHexString(hex: currentHexColor)
        delegate?.didUpdateColor(color)
    }
    
    //MARK: - Actions
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
    
    //MARK: - Private methods
    private func addElements() {
        [
            closeView,
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
            
            gradientView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            gradientView.topAnchor.constraint(
                equalTo: currentColorStackView.bottomAnchor,
                constant: 20
            ),
            gradientView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            
            opacitySlider.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            opacitySlider.topAnchor.constraint(
                equalTo: gradientView.bottomAnchor,
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
