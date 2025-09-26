//
//  String+Extension.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with: String) -> String { // 문자열 변수 대응
        return String(format: self.localized, with)
    }
    
    func localized(with: String, age: Int) -> String { // 문자열 변수 대응
        return String(format: self.localized, with, age)
    }
}
