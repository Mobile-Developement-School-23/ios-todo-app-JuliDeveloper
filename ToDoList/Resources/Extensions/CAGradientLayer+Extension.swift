import UIKit

extension CAGradientLayer {
    func pickColor(at point: CGPoint) -> UIColor {
        guard let colors = colors as? [CGColor] else { return .black }
        
        let percentage = point.x / bounds.width
        let index = Int(percentage * CGFloat(colors.count - 1))
        
        guard index >= 0, index + 1 < colors.count else { return .black }
        
        let startColor = UIColor(cgColor: colors[index])
        let endColor = UIColor(cgColor: colors[index + 1])
        
        let relativePosition = CGFloat(index) / CGFloat(colors.count - 1)
        let difference = percentage - relativePosition
        let ratio = difference * CGFloat(colors.count - 1)
        
        return interpolate(from: startColor, to: endColor, with: ratio)
    }
    
    private func interpolate(from start: UIColor, to end: UIColor, with ratio: CGFloat) -> UIColor {
        let startComponents = start.cgColor.components ?? [0, 0, 0, 0]
        let endComponents = end.cgColor.components ?? [0, 0, 0, 0]
        
        let red = startComponents[0] + (endComponents[0] - startComponents[0]) * ratio
        let green = startComponents[1] + (endComponents[1] - startComponents[1]) * ratio
        let blue = startComponents[2] + (endComponents[2] - startComponents[2]) * ratio
        let alpha = startComponents[3] + (endComponents[3] - startComponents[3]) * ratio
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
