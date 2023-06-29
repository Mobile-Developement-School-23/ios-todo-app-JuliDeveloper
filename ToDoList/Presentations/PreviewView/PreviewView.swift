import UIKit

final class PreviewView: UIView {
    
    //MARK: - Properties
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.tdSubhead
        label.textColor = .tdLabelTertiaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let importanceImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.tdBody
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.backgroundColor = .tdBackSecondaryColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        textView.layer.cornerRadius = Constants.radius
        return textView
    }()
    
    private let uiMarshallingsColor = UIColorMarshallings()
    
    //MARK: - Helpers
    func configure(from todoItem: TodoItem?) {
        backgroundColor = .tdBackPrimaryColor
        
        addElements()
        setupConstraints()
        
        textView.text = todoItem?.text
        textView.textColor = uiMarshallingsColor.fromHexString(hex: todoItem?.hexColor ?? "")
        
        if todoItem?.deadline != nil {
            dateLabel.text = "Сделать до: \(todoItem?.deadline?.dateForLabelWithoutYear ?? "")"
        } else {
            dateLabel.text = ""
        }
        
        switch todoItem?.importance {
        case .important: importanceImageView.image = UIImage(named: "importance")
        case .unimportant: importanceImageView.image = UIImage(named: "unimportant")
        default: break
        }
    }
    
    //MARK: - Private methods
    private func addElements() {
        addSubview(dateLabel)
        addSubview(importanceImageView)
        addSubview(textView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(
                equalTo: topAnchor, constant: 20
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 32
            ),

            importanceImageView.heightAnchor.constraint(
                equalToConstant: 20
            ),
            importanceImageView.widthAnchor.constraint(
                equalTo: importanceImageView.heightAnchor
            ),
            importanceImageView.centerYAnchor.constraint(
                equalTo: dateLabel.centerYAnchor
            ),
            importanceImageView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -32
            ),
            
            textView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 20
            ),
            textView.topAnchor.constraint(
                equalTo: dateLabel.bottomAnchor, constant: 20
            ),
            textView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -20
            ),
            textView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -20
            )
        ])
    }
}
