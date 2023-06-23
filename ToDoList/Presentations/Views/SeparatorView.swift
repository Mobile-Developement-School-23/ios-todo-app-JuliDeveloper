import UIKit

final class SeparatorView: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = .tdSupportSeparatorColor
        translatesAutoresizingMaskIntoConstraints = false
        let separatorHeight = 1 / UIScreen.main.scale
        heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
