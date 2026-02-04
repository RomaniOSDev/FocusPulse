//
//  Theme.swift
//  FocusPulse
//
//  Created by Роман Главацкий on 04.02.2026.
//

import SwiftUI

enum AppTheme {
    static let background = Color(hex: "1A2C38")
    static let focusAccent = Color(hex: "1475E1")
    static let breakAccent = Color(hex: "16FF16")

    // Common gradients for depth and glow
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "0F1820"),
            Color(hex: "1A2C38")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func focusGradient(for base: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                base.opacity(0.9),
                base.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

