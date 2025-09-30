//
//  BaseViewController+Alert.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/30/25.
//

import UIKit

// MARK: - Alert Presentation
extension BaseViewController {

    /// 에러 알럿을 표시합니다.
    /// - Parameters:
    ///   - message: 에러 메시지
    ///   - title: 알럿 타이틀 (기본값: 에러 타이틀)
    ///   - confirmTitle: 확인 버튼 타이틀 (기본값: 확인)
    ///   - completion: 확인 버튼 탭 후 실행될 클로저
    func showErrorAlert(
        message: String,
        title: String? = nil,
        confirmTitle: String? = nil,
        completion: (() -> Void)? = nil
    ) {
        let alertTitle = title ?? LocalizedKeys.Error.title.localized
        let confirmButtonTitle = confirmTitle ?? LocalizedKeys.Action.confirm.localized

        let alert = UIAlertController(
            title: alertTitle,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            completion?()
        })

        present(alert, animated: true)
    }

    /// 일반 알럿을 표시합니다.
    /// - Parameters:
    ///   - title: 알럿 타이틀
    ///   - message: 알럿 메시지
    ///   - confirmTitle: 확인 버튼 타이틀 (기본값: 확인)
    ///   - completion: 확인 버튼 탭 후 실행될 클로저
    func showAlert(
        title: String?,
        message: String?,
        confirmTitle: String? = nil,
        completion: (() -> Void)? = nil
    ) {
        let confirmButtonTitle = confirmTitle ?? LocalizedKeys.Action.confirm.localized

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            completion?()
        })

        present(alert, animated: true)
    }

    /// 확인/취소 알럿을 표시합니다.
    /// - Parameters:
    ///   - title: 알럿 타이틀
    ///   - message: 알럿 메시지
    ///   - confirmTitle: 확인 버튼 타이틀 (기본값: 확인)
    ///   - cancelTitle: 취소 버튼 타이틀 (기본값: 취소)
    ///   - confirmHandler: 확인 버튼 탭 후 실행될 클로저
    ///   - cancelHandler: 취소 버튼 탭 후 실행될 클로저
    func showConfirmAlert(
        title: String?,
        message: String?,
        confirmTitle: String? = nil,
        cancelTitle: String? = nil,
        confirmHandler: (() -> Void)? = nil,
        cancelHandler: (() -> Void)? = nil
    ) {
        let confirmButtonTitle = confirmTitle ?? LocalizedKeys.Action.confirm.localized
        let cancelButtonTitle = cancelTitle ?? LocalizedKeys.Action.cancel.localized

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            cancelHandler?()
        })

        alert.addAction(UIAlertAction(title: confirmButtonTitle, style: .default) { _ in
            confirmHandler?()
        })

        present(alert, animated: true)
    }

    /// 삭제 확인 알럿을 표시합니다.
    /// - Parameters:
    ///   - title: 알럿 타이틀
    ///   - message: 알럿 메시지
    ///   - deleteHandler: 삭제 버튼 탭 후 실행될 클로저
    func showDeleteConfirmAlert(
        title: String?,
        message: String?,
        deleteHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: LocalizedKeys.Action.cancel.localized, style: .cancel))

        alert.addAction(UIAlertAction(title: LocalizedKeys.Action.delete.localized, style: .destructive) { _ in
            deleteHandler()
        })

        present(alert, animated: true)
    }
}