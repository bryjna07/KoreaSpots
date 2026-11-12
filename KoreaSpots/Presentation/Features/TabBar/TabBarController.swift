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
        let favoriteVC = createFavoriteTab()
       // let settingsVC = createSettingsTab()

        setViewControllers([categoryVC, homeVC, tripVC, favoriteVC, ], animated: false)
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backGround

        appearance.stackedLayoutAppearance.selected.iconColor = .greenPastel
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: FontManager.caption2 ?? UIFont.systemFont(ofSize: 12)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: FontManager.caption2 ?? UIFont.systemFont(ofSize: 12)
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Creation
private extension TabBarController {
   
    func createSearchTab() -> UINavigationController {
        let categoryVC = AppContainer.shared.makeCategoryViewController()
        let nav = UINavigationController(rootViewController: categoryVC)

        nav.tabBarItem = UITabBarItem(
            title: "카테고리",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        nav.tabBarItem.tag = 1

        return nav
    }
    
    func createHomeTab() -> UINavigationController {
        let homeVC = AppContainer.shared.makeHomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)

        nav.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        nav.tabBarItem.tag = 0

        return nav
    }


    func createTripTab() -> UINavigationController {
        let tripRecordVC = AppContainer.shared.makeTripRecordViewController()
        let nav = UINavigationController(rootViewController: tripRecordVC)

        nav.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        nav.tabBarItem.tag = 2

        return nav
    }

    func createFavoriteTab() -> UINavigationController {
        let favoriteVC = AppContainer.shared.makeFavoriteViewController()
        let nav = UINavigationController(rootViewController: favoriteVC)

        nav.tabBarItem = UITabBarItem(
            title: "즐겨찾기",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        nav.tabBarItem.tag = 3

        return nav
    }
    
    func createSettingsTab() -> UINavigationController {
        // TODO: Settings 화면 구현 후 교체
        let placeholderVC = PlaceholderViewController(title: "설정", message: "설정 화면 준비중입니다")
        let nav = UINavigationController(rootViewController: placeholderVC)

        nav.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        nav.tabBarItem.tag = 4

        return nav
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = displayTitle
        view.backgroundColor = .backGround

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
