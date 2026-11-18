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

    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
}

// MARK: - Screen Navigation Protocol
protocol ScreenNavigatable: Navigator {
    func navigateToPlaceDetail(place: Place)
    func navigateToSearch()
    func navigateToMap()
    func navigateToFestivalDetail(place: Place)
}

// MARK: - Screen Navigation Implementation
extension ScreenNavigatable where Self: UIViewController {
    /// 축제/공연/행사(contentTypeId 15)는 축제 상세, 그 외는 장소 상세로 이동
    func navigateToPlaceDetail(place: Place) {
        let viewController: UIViewController
        if place.contentTypeId == ContentTypeID.festival.rawValue {
            viewController = AppContainer.shared.makeFestivalDetailViewController(place: place)
        } else {
            viewController = AppContainer.shared.makePlaceDetailViewController(place: place)
        }
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

    func navigateToFestivalDetail(place: Place) {
        let viewController = AppContainer.shared.makeFestivalDetailViewController(place: place)
        push(viewController)
    }

    private func showTemporaryAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedKeys.Action.confirm.localized, style: .default))
        present(alert, animated: true)
    }
}
