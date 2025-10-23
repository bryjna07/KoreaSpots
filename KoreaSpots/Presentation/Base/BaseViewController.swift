//
//  BaseViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import UIKit
import Toast

class BaseViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(frame:) instead.")
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.view.backgroundColor = .clear
        setupNaviBar()
        setupMockModeObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .mockModeEntered, object: nil)
    }

    // MARK: - Mock Mode Observer

    private func setupMockModeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMockModeEntered(_:)),
            name: .mockModeEntered,
            object: nil
        )
    }

    @objc private func handleMockModeEntered(_ notification: Notification) {
        print("📢 BaseViewController received Mock Mode notification")

        let message = """
        서버 오류로 인해
        예시 데이터를 표시합니다.

        • 표시되는 데이터는 실제와 다를 수 있습니다.
        • 여행 기록 작성/수정, 좋아요 기능이 제한됩니다.
        • 기존에 작성한 여행 기록은 정상적으로 조회됩니다.

        서버 복구 시 자동으로 정확한 데이터가 표시됩니다.
        """

        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "예시 데이터 사용 중",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "확인", style: .default))

            self?.present(alert, animated: true) {
                print("✅ Mock Mode Alert displayed in BaseViewController")
            }
        }
    }
    
    func setupNaviBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backGround
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: FontManager.title1 ?? UIFont.systemFont(ofSize: 20)
        ]

        navigationController?.navigationBar.tintColor = .textPrimary
        navigationItem.standardAppearance   = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance    = appearance
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    // MARK: - Toast

    func showToast(message: String) {
        view.makeToast(message, duration: 2.0, position: .bottom)
    }
}
