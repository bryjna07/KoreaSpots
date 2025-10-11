//
//  LocationManager.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {

    private lazy var locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()

    // MARK: - Observables
    private let _authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    private let _currentLocation = PublishRelay<CLLocation>()
    private let _locationError = PublishRelay<Error>()

    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return _authorizationStatus.asObservable()
    }

    var currentLocation: Observable<CLLocation> {
        return _currentLocation.asObservable()
    }

    var locationError: Observable<Error> {
        return _locationError.asObservable()
    }

    var locationUpdates: Observable<CLLocationCoordinate2D> {
        return _currentLocation.asObservable().map { $0.coordinate }
    }

    // MARK: - Computed Properties
    var isLocationAuthorized: Bool {
        switch _authorizationStatus.value {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }

    var lastKnownLocation: CLLocation? {
        return locationManager.location
    }

    // MARK: - Mock Location (임시: 목데이터 테스트용)
    /// 서울역 좌표 (37.5547, 126.9707)
    private static let seoulStationLocation = CLLocation(
        latitude: 37.5547,
        longitude: 126.9707
    )

    override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // 100m 이상 이동 시 업데이트

        // 초기 권한 상태 설정
        _authorizationStatus.accept(locationManager.authorizationStatus)
    }

    // MARK: - Public Methods
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // 설정으로 이동하도록 알림 표시
            break
        case .authorizedWhenInUse, .authorizedAlways:
            requestCurrentLocation()
        @unknown default:
            break
        }
    }

    func requestCurrentLocation() {
        // TODO: 실제 출시 시 아래 주석 해제하고 임시 위치 제거
        // guard isLocationAuthorized else {
        //     requestLocationPermission()
        //     return
        // }
        // locationManager.requestLocation()

        // MARK: - 임시: 목데이터 테스트용 서울역 위치 반환
        print("⚠️ [MOCK] 임시 위치 사용 중: 서울역 (37.5547, 126.9707)")
        _currentLocation.accept(Self.seoulStationLocation)
    }

    func startUpdatingLocation() {
        // TODO: 실제 출시 시 아래 주석 해제하고 임시 위치 제거
        // guard isLocationAuthorized else {
        //     requestLocationPermission()
        //     return
        // }
        // locationManager.startUpdatingLocation()

        // MARK: - 임시: 목데이터 테스트용 서울역 위치 반환
        print("⚠️ [MOCK] 임시 위치 사용 중: 서울역 (37.5547, 126.9707)")
        _currentLocation.accept(Self.seoulStationLocation)
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        _currentLocation.accept(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _locationError.accept(error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _authorizationStatus.accept(status)

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            requestCurrentLocation()
        case .denied, .restricted:
            // 권한 거부 처리
            break
        case .notDetermined:
            // 결정되지 않음
            break
        @unknown default:
            break
        }
    }
}
