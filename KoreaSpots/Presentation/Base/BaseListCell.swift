//
//  BaseListCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit

class BaseListCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }
}

extension BaseListCell: ConfigureUI {
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .onPrimary
    }
}
