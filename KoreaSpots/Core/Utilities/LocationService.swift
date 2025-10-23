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
    var authorizationStatus: Observable<CLAuthorizationStatus> { get }
    func requestLocationPermission()

    /// Reverse Geocoding: 좌표 → 지역코드 추출
    func getAreaCode(from location: CLLocation) -> Single<AreaCode>

    /// 사용자 위치 기반 지역코드 조회 (실패 시 nil 반환)
    func getCurrentAreaCode() -> Single<AreaCode?>

    /// 위치가 한국 내인지 확인
    func isCoordinateInKorea(latitude: Double, longitude: Double) -> Bool
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

                print("Reverse Geocoding: \(administrativeArea) → \(areaCode.displayName) (code: \(areaCode.rawValue))")
                single(.success(areaCode))
            }

            return Disposables.create {
                geocoder.cancelGeocode()
            }
        }
    }

    /// 사용자 위치 기반 지역코드 조회 (실패 시 nil 반환)
    func getCurrentAreaCode() -> Single<AreaCode?> {
        // 권한이 결정될 때까지 기다림 (.notDetermined 건너뛰기)
        return authorizationStatus
            .filter { $0 != .notDetermined }
            .take(1)
            .timeout(.seconds(10), scheduler: MainScheduler.asyncInstance)
            .asSingle()
            .flatMap { [unowned self] status -> Single<AreaCode?> in
                // 권한이 거부되었으면 즉시 nil 반환 (전국 조회)
                guard status != .denied && status != .restricted else {
                    print("⚠️ 위치 권한 거부됨 - 전국 조회")
                    return .just(nil)
                }

                // 권한이 허용됨 → 위치 기반 지역코드 조회
                return self.currentLocation
                    .take(1)
                    .timeout(.seconds(5), scheduler: MainScheduler.asyncInstance)
                    .asSingle()
                    .flatMap { [unowned self] location -> Single<AreaCode?> in
                        // 한국 내 위치인지 확인
                        guard self.isCoordinateInKorea(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        ) else {
                            print("⚠️ 현재 위치가 한국이 아닙니다 - 전국 조회")
                            return .just(nil)
                        }

                        return self.getAreaCode(from: location)
                            .map(Optional.some)
                            .catch { error in
                                print("⚠️ 지역코드 추출 실패: \(error.localizedDescription)")
                                return .just(nil)
                            }
                    }
                    .catch { error in
                        print("⚠️ 위치 정보 가져오기 실패: \(error.localizedDescription)")
                        return .just(nil)
                    }
            }
            .catch { error in
                // timeout 등의 에러 발생 시 전국 조회
                print("⚠️ 권한 대기 timeout - 전국 조회")
                return .just(nil)
            }
    }

    /// 위치가 한국 내인지 확인
    func isCoordinateInKorea(latitude: Double, longitude: Double) -> Bool {
        // 대한민국 대략적인 경계
        // 위도: 33.0°N ~ 38.6°N (제주도 포함)
        // 경도: 124.5°E ~ 132.0°E
        let isInKorea = (33.0...38.6).contains(latitude) && (124.5...132.0).contains(longitude)

        if !isInKorea {
            print("📍 현재 위치: lat=\(latitude), lon=\(longitude) (한국 밖)")
        }

        return isInKorea
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