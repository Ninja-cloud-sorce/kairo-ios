import SwiftUI

enum KairoColor {
    static let background   = Color(hex: 0x0A0A14)
    static let surface      = Color(hex: 0x0F0F1C)
    static let surfaceVariant = Color(hex: 0x161628)
    static let accent       = Color(hex: 0x5E6AD2)
    static let accentDim    = Color(hex: 0x3D4899)
    static let accentSoft   = Color(hex: 0xB4C6FC)
    static let text         = Color(hex: 0xF2F2FF)
    static let textMuted    = Color(hex: 0x8888AA)
    static let success      = Color(hex: 0x4ADE80)
    static let error        = Color(hex: 0xFF6B6B)
    static let warning      = Color(hex: 0xFFBB44)

    static func level(_ code: String) -> Color {
        switch code {
        case "N5": return Color(hex: 0x4ADE80)
        case "N4": return Color(hex: 0x60A5FA)
        case "N3": return Color(hex: 0xA78BFA)
        case "N2": return Color(hex: 0xFB923C)
        case "N1": return Color(hex: 0xFF6B6B)
        default:   return accent
        }
    }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
