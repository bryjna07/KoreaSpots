//
//  LocationService.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import RxSwift
import CoreLocation

// MARK: - Location Service Protocol
protocol LocationService {
    var locationUpdates: Observable<CLLocationCoordinate2D> { get }
    var currentLocation: Observable<CLLocation> { get }
    func requestLocationPermission()
}

// MARK: - Location Service Implementation
extension LocationManager: LocationService {
    // LocationManager는 이미 이 프로토콜의 요구사항을 구현하고 있음
}