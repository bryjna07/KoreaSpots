//
//  UIView+Extension.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit.UIView

// MARK: - addSubviews
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
