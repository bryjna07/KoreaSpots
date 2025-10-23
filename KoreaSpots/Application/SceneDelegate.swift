//
//  SceneDelegate.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let tabBarVC = AppContainer.shared.makeTabBarController()
        tabBarVC.selectedIndex = 1 // 시작 탭: 두 번째 탭

        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()

        // API 키 유효성 체크 (백그라운드)
        checkAPIKeyValidity()
    }

    // MARK: - API Key Validation
    private func checkAPIKeyValidity() {
        print("🔐 Checking API key validity...")

        // 간단한 API 호출로 키 유효성 체크 (축제 목록 1개만)
        let tourRepository = AppContainer.shared.makeTourRepository()

        // 현재 날짜 기준 축제 검색 (결과가 없어도 상관없음, API 응답만 확인)
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: today)

        tourRepository.getFestivals(
            eventStartDate: dateString,
            eventEndDate: dateString,
            areaCode: nil,
            numOfRows: 1,
            pageNo: 1,
            arrange: "O"
        )
        .subscribe(
            onSuccess: { _ in
                print("✅ API Key is valid - Normal mode")
            },
            onFailure: { error in
                print("❌ API Key validation failed: \(error)")
                print("⚠️ This will trigger Mock mode on next API call")
            }
        )
        .disposed(by: disposeBag)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

