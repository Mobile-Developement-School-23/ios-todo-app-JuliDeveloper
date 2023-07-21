import SwiftUI

extension Color {
    static var tdSupportSeparatorColor: Color { Color("tdSupportSeparatorColor") }
    static var tdSupportOverlayColor: Color { Color("tdSupportOverlayColor") }
    static var tdSupportOverlayColorForSwitch: Color { Color("tdSupportOverlayColorForSwitch") }
    static var tdSupportNavBarBlurColor: Color { Color("tdSupportNavBarBlurColor") }
    static var tdLabelPrimaryColor: Color { Color("tdLabelPrimaryColor") }
    static var tdLabelDisableColor: Color { Color("tdLabelDisableColor") }
    static var tdLabelTertiaryColor: Color { Color("tdLabelTertiaryColor") }
    static var tdLabelSecondaryColor: Color { Color("tdLabelSecondaryColor") }
    static var tdRedColor: Color { Color("tdRedColor") }
    static var tdGreenColor: Color { Color("tdGreenColor") }
    static var tdGrayColor: Color { Color("tdGrayColor") }
    static var tdGrayLightColor: Color { Color("tdGrayLightColor") }
    static var tdBlueColor: Color { Color("tdBlueColor") }
    static var tdWhiteColor: Color { Color("tdWhiteColor") }
    static var tdBackElevatedColor: Color { Color("tdBackElevatedColor") }
    static var tdBackIOSPrimaryColor: Color { Color("tdBackIOSPrimaryColor") }
    static var tdBackPrimaryColor: Color { Color("tdBackPrimaryColor") }
    static var tdBackSecondaryColor: Color { Color("tdBackSecondaryColor") }
    static var tdShadowColor: Color { Color("tdShadowColor") }
}

extension Color {
    init(hex: String) {
        let r, g, b, a: Double
        let start = hex.index(hex.startIndex, offsetBy: hex.hasPrefix("#") ? 1 : 0)
        let hexColor = String(hex[start...])
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xFF000000) >> 24) / 255
            g = Double((hexNumber & 0x00FF0000) >> 16) / 255
            b = Double((hexNumber & 0x0000FF00) >> 8) / 255
            a = Double(hexNumber & 0x000000FF) / 255
            
        } else {
            r = 0
            g = 0
            b = 0
            a = 1
        }

        self.init(
            UIColor(red: CGFloat(r),
                    green: CGFloat(g),
                    blue: CGFloat(b),
                    alpha: CGFloat(a))
        )
    }
}
