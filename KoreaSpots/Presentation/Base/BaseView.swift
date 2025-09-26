//
//  BaseView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit

class BaseView: UIView {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }
}

    // MARK: - ConfigureUI
extension BaseView: ConfigureUI {
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .white
    }
}
