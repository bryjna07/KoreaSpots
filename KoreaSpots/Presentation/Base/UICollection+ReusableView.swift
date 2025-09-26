//
//  UICollection+ReusableView.swift
//  KoreaSpots
//
//  Created by Youngjin on 2025/09/26.
//

import UIKit

extension UICollectionReusableView: ReusableView {}

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
}
