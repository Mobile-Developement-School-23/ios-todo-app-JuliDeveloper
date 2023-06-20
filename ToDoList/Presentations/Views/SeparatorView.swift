import UIKit

final class SeparatorView: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = .tdSupportSeparatorColor
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
