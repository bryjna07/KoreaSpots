//
//  AppDelegate.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift
//import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    private let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        // CodeBook 데이터 미리 로드 (Cat3, Sigungu)
        loadCodeBooks()

        // 앱 시작 시 만료된 캐시 정리 (백그라운드)
//        clearExpiredCacheOnStartup()

        return true
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

