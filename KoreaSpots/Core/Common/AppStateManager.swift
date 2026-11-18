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

    // MARK: - Mock 모드 복구 시도 (half-open)
    // Mock 모드 중에도 일정 주기/포그라운드 복귀 시 요청 1건은 실제 API로 보내 서버 복구를 확인
    private let realAPIRetryInterval: TimeInterval = 5 * 60
    private var lastRealAPIAttemptAt: Date?
    private var isRealAPIRetryRequested = false
    private let retryLock = NSLock()

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
        retryLock.lock()
        lastRealAPIAttemptAt = Date()
        isRealAPIRetryRequested = false
        retryLock.unlock()
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

    // MARK: - Mock 모드 복구

    /// 이번 요청에 Mock 데이터를 써야 하는지 판단
    /// - Mock 모드라도 마지막 시도 후 5분이 지났거나 포그라운드 복귀 직후면 1건만 실제 API로 보냄
    func shouldUseMockData() -> Bool {
        guard currentMode == .mockFallback else { return false }

        retryLock.lock()
        defer { retryLock.unlock() }

        let isIntervalElapsed = lastRealAPIAttemptAt.map {
            Date().timeIntervalSince($0) >= realAPIRetryInterval
        } ?? true

        guard isRealAPIRetryRequested || isIntervalElapsed else { return true }

        // 동시 요청 중 1건만 실제 API로 보내도록 시각 갱신
        isRealAPIRetryRequested = false
        lastRealAPIAttemptAt = Date()
        print("🔁 Mock Mode - retrying real API")
        return false
    }

    /// 포그라운드 복귀 시 다음 요청에서 실제 API 재시도
    func requestRealAPIRetry() {
        guard currentMode == .mockFallback else { return }
        retryLock.lock()
        isRealAPIRetryRequested = true
        retryLock.unlock()
    }

    /// 실제 API 응답 파싱 성공 → Mock 모드였다면 정상 모드로 복구
    func reportRealAPISuccess() {
        guard currentMode == .mockFallback else { return }
        enterNormalMode()
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
