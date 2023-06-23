import UIKit

protocol ColorMarshallingsProtocol {
    func toHexString(color: UIColor) -> String
    func fromHexString(hex: String) -> UIColor
}
