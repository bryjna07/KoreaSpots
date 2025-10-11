//
//  BaseReusableView.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import UIKit

// MARK: - BaseReusableView
class BaseReusableView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }

    // MARK: - Override Methods
    func configureHierarchy() {
    }

    func configureLayout() {
    }

    func configureView() {
        backgroundColor = .backGround
    }
}
