//
//  Navigator.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit
import Foundation

// MARK: - Navigator Protocol
protocol Navigator: AnyObject {
    func push(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

// MARK: - Default Navigator Implementation
extension Navigator where Self: UIViewController {
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(viewController, animated: animated, completion: completion)
    }

    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Screen Navigation Protocol
protocol ScreenNavigatable: Navigator {
    func navigateToPlaceDetail(place: Place)
    func navigateToSearch()
    func navigateToMap()
    func navigateToFestivalDetail(festival: Festival)
}

// MARK: - Screen Navigation Implementation
extension ScreenNavigatable where Self: UIViewController {
    func navigateToPlaceDetail(place: Place) {
        let viewController = AppContainer.shared.makePlaceDetailViewController(place: place)
        push(viewController)
    }

    func navigateToSearch() {
        let viewController = AppContainer.shared.makeSearchViewController()
        push(viewController)
    }

    func navigateToMap() {
        // TODO: MapViewController 구현 후 활성화
        print("Navigate to map screen")
        showTemporaryAlert(
            title: "지도",
            message: "지도 화면으로 이동합니다."
        )
    }

    func navigateToFestivalDetail(festival: Festival) {
        // TODO: FestivalDetailViewController 구현 후 활성화
        print("Festival selected: \(festival.title)")
//        showTemporaryAlert(
//            title: "축제 상세",
//            message: "축제 상세 화면으로 이동합니다."
//        )
    }

    private func showTemporaryAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedKeys.Action.confirm.localized, style: .default))
        present(alert, animated: true)
    }
}
