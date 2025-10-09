//
//  BaseCollectionViewCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }
}

extension BaseCollectionViewCell: ConfigureUI {
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .backGround
    }
}
