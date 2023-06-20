import UIKit

final class CustomLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        textColor = .tdLabelPrimaryColor
        font = UIFont.tdBody
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
