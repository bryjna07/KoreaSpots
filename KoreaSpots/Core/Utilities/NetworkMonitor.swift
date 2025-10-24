//
//  NetworkMonitor.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/20/25.
//

import Foundation
import Network
import RxSwift
import RxCocoa

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.koreaSpots.networkMonitor")

    // MARK: - Observables
    private let _isConnected = BehaviorRelay<Bool>(value: true)
    private let _connectionType = BehaviorRelay<NWInterface.InterfaceType?>(value: nil)

    var isConnected: Observable<Bool> {
        return _isConnected.asObservable()
    }

    var isConnectedValue: Bool {
        return _isConnected.value
    }

    var connectionType: Observable<NWInterface.InterfaceType?> {
        return _connectionType.asObservable()
    }

    // MARK: - Initialization
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let isConnected = path.status == .satisfied
            self._isConnected.accept(isConnected)

            // 연결 타입 감지 (WiFi, Cellular, Wired)
            if isConnected {
                if path.usesInterfaceType(.wifi) {
                    self._connectionType.accept(.wifi)
                } else if path.usesInterfaceType(.cellular) {
                    self._connectionType.accept(.cellular)
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self._connectionType.accept(.wiredEthernet)
                } else {
                    self._connectionType.accept(.other)
                }
            } else {
                self._connectionType.accept(nil)
            }

            // 로깅
            self.logNetworkStatus(isConnected: isConnected, path: path)
        }

        monitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func logNetworkStatus(isConnected: Bool, path: NWPath) {
        if isConnected {
            var connectionTypeString = "Unknown"
            if path.usesInterfaceType(.wifi) {
                connectionTypeString = "WiFi"
            } else if path.usesInterfaceType(.cellular) {
                connectionTypeString = "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                connectionTypeString = "Wired"
            }
            print("🌐 Network Connected: \(connectionTypeString)")
        } else {
            print("📴 Network Disconnected")
        }
    }
}
