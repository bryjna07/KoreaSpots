//
//  FontManager.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit

struct FontManager {

    // MARK: - Title Fonts
    static let largeTitle = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let title1 = UIFont.systemFont(ofSize: 22, weight: .bold)
    static let title2 = UIFont.systemFont(ofSize: 18, weight: .bold)
    static let title3 = UIFont.systemFont(ofSize: 16, weight: .semibold)

    // MARK: - Body Fonts
    static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let bodyBold = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bodyMedium = UIFont.systemFont(ofSize: 16, weight: .medium)

    // MARK: - Caption Fonts
    static let caption1 = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let caption2 = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let caption3 = UIFont.systemFont(ofSize: 10, weight: .regular)

    // MARK: - Card Specific Fonts
    struct Card {
        static let title = FontManager.bodyBold
        static let subtitle = FontManager.caption1
        static let description = FontManager.caption2
    }

    // MARK: - Header Fonts
    struct Header {
        static let sectionTitle = FontManager.title2
        static let actionButton = FontManager.caption1
    }

    // MARK: - Navigation Fonts
    struct Navigation {
        static let title = FontManager.title1
        static let button = FontManager.body
    }
}

// MARK: - Dynamic Type Support
extension FontManager {
    static func scaledFont(_ font: UIFont, textStyle: UIFont.TextStyle = .body) -> UIFont {
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: font)
    }
}