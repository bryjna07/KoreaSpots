//
//  ConfigureUI.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Foundation

@objc protocol ConfigureUI: AnyObject {
    func configureHierarchy()
    func configureLayout()
    func configureView()
}
