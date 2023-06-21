import UIKit

final class OpacitySlider: UISlider {
    
    //MARK: - Properties
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    private let thumbImageView = UIImageView()
        
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
        setupThumb()
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Lifecycle
    override func layoutSubviews() {
        gradientLayer.frame = bounds
        
        let thumbRect = thumbRect(
            forBounds: bounds,
            trackRect: trackRect(forBounds: CGRect(
                x: 0, y: 0, width: bounds.width - 2, height: bounds.height)
            ),
            value: value
        )
        thumbImageView.center = CGPoint(x: thumbRect.midX, y: thumbRect.midY)
    }
    
    //MARK: - Helpers
    func setupColorsGradient(color: UIColor) {
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            color.cgColor
        ]
        
        value = Float(color.cgColor.alpha)
    }
    
    //MARK: - Private methods
    private func setupSlider() {
        minimumValue = 0
        maximumValue = 1

        clipsToBounds = true
        layer.cornerRadius = Constants.sliderRadius
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    private func setupThumb() {
        let thumbImage = UIImage(named: "thumb")
        thumbImageView.image = thumbImage
        thumbImageView.frame = CGRect(
            x: 0, y: 0,
            width: thumbImage?.size.width ?? 0,
            height: thumbImage?.size.height ?? 0
        )
        
        addSubview(thumbImageView)
    }
}
