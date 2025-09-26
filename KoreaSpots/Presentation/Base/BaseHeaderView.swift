//
//  BaseHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation

//
//  BaseHeaderView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit
import SnapKit
import Then

class BaseHeaderView: UICollectionReusableView {

    // MARK: - Init
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
extension BaseHeaderView: ConfigureUI {
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .white
    }
}
