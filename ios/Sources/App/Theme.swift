import SwiftUI

/// Palette mirrored 1:1 from the Android app's res/values/colors.xml so the two
/// fixtures look identical to a human reviewer.
enum Theme {
    static let brandPrimary  = Color(hex: 0xFF6B00)
    static let brandDark     = Color(hex: 0x1B1B1F)
    static let card          = Color(hex: 0xFFFFFF)
    static let cardBorder    = Color(hex: 0xE5E5EA)
    static let textPrimary   = Color(hex: 0x111111)
    static let textSecondary = Color(hex: 0x5A5A66)
    static let bg            = Color(hex: 0xF5F6FA)
    static let violationRed  = Color(hex: 0xD72638)
    static let okGreen       = Color(hex: 0x138A36)
    static let infoBlue      = Color(hex: 0x1F6FEB)
    static let warnYellow    = Color(hex: 0xE1A100)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
