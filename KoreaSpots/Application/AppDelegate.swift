//
//  AppDelegate.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift
import RealmSwift
//import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Realm 마이그레이션 설정 (CodeBook 로드 전에 실행)
        configureRealm()

        FirebaseApp.configure()

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        // CodeBook 데이터 미리 로드 (Cat3, Sigungu)
        loadCodeBooks()

        // 앱 시작 시 만료된 캐시 정리 (백그라운드)
//        clearExpiredCacheOnStartup()

        return true
    }

    // MARK: - Realm Configuration
    private func configureRealm() {
        // 현재 스키마 버전
        let currentSchemaVersion: UInt64 = 1

        let config = Realm.Configuration(
            schemaVersion: currentSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                // 마이그레이션 블록
                // oldSchemaVersion < currentSchemaVersion일 때만 실행됨

                #if DEBUG
                print("🔄 Realm Migration: \(oldSchemaVersion) → \(currentSchemaVersion)")
                #endif

                // Version 0 → 1: 기존 스키마 (마이그레이션 없음)
                if oldSchemaVersion < 1 {
                    // 초기 버전이므로 마이그레이션 불필요
                }

                // Version 1 → 2: 향후 근접 알림 스키마 추가 예정
                // if oldSchemaVersion < 2 {
                //     // PlaceNotificationSettingR, NotificationHistoryR 추가
                //     // 기존 데이터는 영향 없음 (새 테이블 추가만)
                // }

                // Version 2 → 3: 향후 추가 기능
                // if oldSchemaVersion < 3 {
                //     // 필드 추가/삭제/변경 처리
                // }
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // 100MB 이상이고 사용률 50% 미만이면 압축
                let hundredMB = 100 * 1024 * 1024
                return (totalBytes > hundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            }
        )

        // 기본 Realm 설정 적용
        Realm.Configuration.defaultConfiguration = config

        #if DEBUG
        // Realm 파일 위치 출력 (디버그 모드)
        if let fileURL = config.fileURL {
            print("📁 Realm file location: \(fileURL.path)")
        }
        #endif

        // Realm 초기화 테스트 (앱 시작 시 문제 조기 발견)
        do {
            let realm = try Realm()
            print("✅ Realm initialized successfully (Schema v\(currentSchemaVersion))")

            #if DEBUG
            // 디버그 모드에서 스키마 정보 출력
            print("📊 Realm Schema Objects:")
            realm.schema.objectSchema.forEach { objectSchema in
                print("  - \(objectSchema.className): \(objectSchema.properties.count) properties")
            }
            #endif
        } catch {
            print("❌ Realm initialization failed: \(error.localizedDescription)")
            // 마이그레이션 실패 시 앱 크래시 방지를 위한 처리
            // 프로덕션에서는 사용자에게 안내 후 재설치 유도 가능
        }
    }

    // MARK: - CodeBook Loading
    private func loadCodeBooks() {
        // Cat3 코드 로드
        CodeBookStore.Cat3.loadFromBundleAsync(fileName: "cat3_codes") { success in
            if success {
                print("✅ AppDelegate: cat3_codes.json loaded successfully")
            } else {
                print("⚠️ AppDelegate: cat3_codes.json load failed")
            }
        }

        // Sigungu 코드 로드
        CodeBookStore.Sigungu.loadFromBundleAsync(fileName: "sigungu_codes") { success in
            if success {
                print("✅ AppDelegate: sigungu_codes.json loaded successfully")
            } else {
                print("⚠️ AppDelegate: sigungu_codes.json load failed")
            }
        }
    }

    // MARK: - Cache Management
//    private func clearExpiredCacheOnStartup() {
//        let localDataSource = TourLocalDataSourceImpl()
//        localDataSource.clearExpiredCache()
//            .subscribe(
//                onCompleted: {
//                    print("✅ AppDelegate: Expired cache cleared on startup")
//                },
//                onError: { error in
//                    print("⚠️ AppDelegate: Failed to clear expired cache: \(error)")
//                }
//            )
//            .disposed(by: disposeBag)
//    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

