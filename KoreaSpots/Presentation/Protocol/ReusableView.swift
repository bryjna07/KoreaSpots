//
//  ReusableView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit.UIView

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

extension UIView: ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    static var elementKind: String {
        String(describing: self) + "ElementKind"
    }
}
