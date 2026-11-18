//
//  UICollection+ReusableView.swift
//  KoreaSpots
//
//  Created by Youngjin on 2025/09/26.
//

import UIKit

extension UICollectionView {

    // MARK: - Cell Registration Helpers
    func register<T>(
        cell: T.Type,
        forCellWithReuseIdentifier reuseIdentifier: String = T.reuseIdentifier
    ) where T: UICollectionViewCell {
        register(cell, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Supplementary Registration Helpers
    func register<T>(header: T.Type, reuseIdentifier: String = T.reuseIdentifier) where T: UICollectionReusableView {
        register(header, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseIdentifier)
    }

    func register<T>(footer: T.Type, reuseIdentifier: String = T.reuseIdentifier) where T: UICollectionReusableView {
        register(footer, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reuseIdentifier)
    }

    func register<T>(supplementary: T.Type) where T: UICollectionReusableView {
        register(supplementary, forSupplementaryViewOfKind: T.elementKind, withReuseIdentifier: T.reuseIdentifier)
    }

    // MARK: - Dequeue Helpers
    /// 등록되지 않은 타입을 요청하는 것은 프로그래머 오류이므로 fatalError로 즉시 드러낸다
    func dequeue<T>(cell: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue \(T.self). Register it with register(cell:) first.")
        }
        return cell
    }

    func dequeue<T>(supplementary: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T where T: UICollectionReusableView {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue \(T.self) for kind \(kind). Register it first.")
        }
        return view
    }
}
