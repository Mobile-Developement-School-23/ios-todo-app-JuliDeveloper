import UIKit

struct UIColorMarshallings {
    func toHexString(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        let alpha = Int(a * 255)
        
        return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
    }
    
    func fromHexString(hex: String) -> UIColor {
        let r, g, b, a: CGFloat
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        } else {
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}

