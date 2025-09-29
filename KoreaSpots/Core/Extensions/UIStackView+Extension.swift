//
//  UIStackView+Extension.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit.UIStackView

// MARK: - addArrangedSubviews
extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
}
