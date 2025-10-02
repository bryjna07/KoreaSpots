//
//  TabBarController.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import Then

final class TabBarController: UITabBarController {

    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init() instead.")
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    // MARK: - Setup
    private func setupViewControllers() {
        let categoryVC = createSearchTab()
        let homeVC = createHomeTab()
        let tripVC = createTripTab()
        let settingsVC = createSettingsTab()

        setViewControllers([categoryVC, homeVC, tripVC, settingsVC], animated: false)
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: FontManager.caption2
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: FontManager.caption2
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Creation
private extension TabBarController {
   
    func createSearchTab() -> UINavigationController {
        let categoryVC = AppContainer.shared.makeCategoryViewController()
        let navController = UINavigationController(rootViewController: categoryVC)

        navController.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        navController.tabBarItem.tag = 1

        return navController
    }
    
    func createHomeTab() -> UINavigationController {
        let homeVC = AppContainer.shared.makeHomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)

        navController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        navController.tabBarItem.tag = 0

        return navController
    }


    func createTripTab() -> UINavigationController {
        // TODO: Trip 화면 구현 후 교체
        let placeholderVC = PlaceholderViewController(title: "여행 기록", message: "여행 기록 화면 준비중입니다")
        let navController = UINavigationController(rootViewController: placeholderVC)

        navController.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        navController.tabBarItem.tag = 2

        return navController
    }

    func createSettingsTab() -> UINavigationController {
        // TODO: Settings 화면 구현 후 교체
        let placeholderVC = PlaceholderViewController(title: "설정", message: "설정 화면 준비중입니다")
        let navController = UINavigationController(rootViewController: placeholderVC)

        navController.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        navController.tabBarItem.tag = 3

        return navController
    }
}

// MARK: - Placeholder ViewController
private final class PlaceholderViewController: BaseViewController {

    private let messageLabel = UILabel()
    private let iconImageView = UIImageView()
    private let displayTitle: String
    private let displayMessage: String

    init(title: String, message: String) {
        self.displayTitle = title
        self.displayMessage = message
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = displayTitle
        view.backgroundColor = .systemBackground

        view.addSubview(iconImageView)
        view.addSubview(messageLabel)

        iconImageView.do {
            $0.image = UIImage(systemName: "hammer.fill")
            $0.tintColor = .systemGray3
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.text = displayMessage
            $0.font = FontManager.body
            $0.textColor = .systemGray
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
            $0.width.height.equalTo(80)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(Constants.Layout.standardPadding)
            $0.leading.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
        }
    }
}
