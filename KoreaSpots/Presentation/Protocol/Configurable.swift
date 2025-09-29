//
//  Configurable.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation

protocol Configurable {
    associatedtype Model
    func configure(with model: Model)
}

// MARK: - Collection View Cell Configurable
protocol CollectionViewCellConfigurable: Configurable {
    func prepareForReuse()
}

// MARK: - Header View Configurable
protocol HeaderViewConfigurable: Configurable {
    var actionHandler: (() -> Void)? { get set }
}
