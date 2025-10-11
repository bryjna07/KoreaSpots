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

    /// Reverse Geocoding: 좌표 → 지역코드 추출
    func getAreaCode(from location: CLLocation) -> Single<AreaCode>

    /// 사용자 위치 기반 지역코드 조회 (실패 시 서울 기본값)
    func getCurrentAreaCode() -> Single<AreaCode>
}

// MARK: - Location Service Implementation
extension LocationManager: LocationService {

    /// Reverse Geocoding을 통해 AreaCode 추출
    func getAreaCode(from location: CLLocation) -> Single<AreaCode> {
        return Single.create { single in
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    single(.failure(error))
                    return
                }

                guard let placemark = placemarks?.first,
                      let administrativeArea = placemark.administrativeArea,
                      let areaCode = AreaCode.from(administrativeArea: administrativeArea) else {
                    single(.failure(LocationError.areaCodeNotFound))
                    return
                }

                print("📍 Reverse Geocoding: \(administrativeArea) → \(areaCode.displayName) (code: \(areaCode.rawValue))")
                single(.success(areaCode))
            }

            return Disposables.create {
                geocoder.cancelGeocode()
            }
        }
    }

    /// 사용자 위치 기반 지역코드 조회 (실패 시 서울 기본값)
    func getCurrentAreaCode() -> Single<AreaCode> {
        return currentLocation
            .take(1)
            .asSingle()
            .flatMap { [weak self] location -> Single<AreaCode> in
                guard let self = self else { return .just(.seoul) }
                return self.getAreaCode(from: location)
            }
            .catch { error in
                print("⚠️ 위치 기반 지역코드 조회 실패: \(error.localizedDescription)")
                print("📍 기본 지역(서울)으로 설정합니다.")
                return .just(.seoul)
            }
    }
}

// MARK: - Location Error
enum LocationError: Error, LocalizedError {
    case areaCodeNotFound
    case permissionDenied
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .areaCodeNotFound:
            return "현재 위치의 지역 정보를 찾을 수 없습니다."
        case .permissionDenied:
            return "위치 권한이 거부되었습니다."
        case .locationUnavailable:
            return "위치 정보를 가져올 수 없습니다."
        }
    }
}