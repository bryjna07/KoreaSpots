//
//  AppStateManager.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/20/25.
//

import Foundation
import RxSwift
import RxCocoa

/// 앱 전체 상태 관리 (Mock 데이터 사용 여부, 네트워크 상태 등)
final class AppStateManager {
    static let shared = AppStateManager()

    // MARK: - Observable State
    private let _dataSourceMode = BehaviorRelay<DataSourceMode>(value: .normal)

    /// 현재 데이터 소스 모드 (Observable)
    var dataSourceMode: Observable<DataSourceMode> {
        return _dataSourceMode.asObservable()
    }

    /// 현재 데이터 소스 모드 값 (동기)
    var currentMode: DataSourceMode {
        return _dataSourceMode.value
    }

    // MARK: - Mock 모드 진입/복구 추적
    private var mockModeEnteredAt: Date?
    private var hasNotifiedMockMode = false  // Notification 1회만 발송

    private init() {
        // NetworkMonitor 연동
        NetworkMonitor.shared.isConnected
            .subscribe(onNext: { [weak self] isConnected in
                guard let self = self else { return }

                // 네트워크 복구 시 normal 모드로 전환
                if isConnected && self._dataSourceMode.value == .offline {
                    self.enterNormalMode()
                }
                // 네트워크 끊김 시 offline 모드로 전환 (단, mockFallback이 아닐 때만)
                else if !isConnected && self._dataSourceMode.value == .normal {
                    self.enterOfflineMode()
                }
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()

    // MARK: - Mode Transition

    /// Mock 데이터 모드 진입 (API 오류 발생 시)
    func enterMockMode(reason: String) {
        guard _dataSourceMode.value != .mockFallback else {
            print("⚠️ Already in Mock Mode, skipping")
            return
        }

        print("⚠️ Entering Mock Mode: \(reason)")
        mockModeEnteredAt = Date()
        _dataSourceMode.accept(.mockFallback)
        print("✅ Mock Mode entered. Current mode: \(_dataSourceMode.value)")

        // Notification 발송 (1회만)
        if !hasNotifiedMockMode {
            hasNotifiedMockMode = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .mockModeEntered,
                    object: nil,
                    userInfo: ["reason": reason]
                )
                print("📢 Mock Mode Notification posted")
            }
        }
    }

    /// 오프라인 모드 진입 (네트워크 끊김)
    func enterOfflineMode() {
        guard _dataSourceMode.value != .offline else { return }

        print("📵 Entering Offline Mode")
        _dataSourceMode.accept(.offline)
    }

    /// 정상 모드로 복구
    func enterNormalMode() {
        let previousMode = _dataSourceMode.value

        if previousMode == .mockFallback, let enteredAt = mockModeEnteredAt {
            let duration = Date().timeIntervalSince(enteredAt)
            print("✅ Recovering from Mock Mode (duration: \(Int(duration))s)")
            mockModeEnteredAt = nil
            hasNotifiedMockMode = false  // Notification 플래그 리셋
        } else if previousMode == .offline {
            print("✅ Network Recovered")
        }

        _dataSourceMode.accept(.normal)
    }

    /// 쓰기 작업 가능 여부 체크
    func canPerformWriteOperation() -> Bool {
        return !currentMode.shouldRestrictWriteOperations
    }

    /// 쓰기 작업 차단 시 보여줄 메시지
    func writeOperationBlockedMessage() -> String? {
        guard currentMode.shouldRestrictWriteOperations else { return nil }
        return "예시 데이터 사용 중에는\n이 기능을 사용할 수 없습니다."
    }
}
