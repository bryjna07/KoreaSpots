//
//  ReusableView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit.UIView

protocol ReusableView: AnyObject { }

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
