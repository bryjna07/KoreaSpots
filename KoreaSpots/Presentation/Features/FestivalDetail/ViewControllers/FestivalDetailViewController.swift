//
//  FestivalDetailViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class FestivalDetailViewController: BaseViewController, View, Navigator {

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var festivalDetailView: FestivalDetailView { return view as! FestivalDetailView }

    private let favoriteButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: nil,
        action: nil
    )

    // MARK: - Lifecycle
    override func loadView() {
        view = FestivalDetailView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup
    override func setupNaviBar() {
        super.setupNaviBar()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }

    @objc func backButtonTapped() {
        pop()
    }

    // MARK: - Bind
    func bind(reactor: FestivalDetailReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }

    private func bindAction(reactor: FestivalDetailReactor) {
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        festivalDetailView.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 즐겨찾기 해제는 확인 후 처리
        favoriteButton.rx.tap
            .bind(with: self) { owner, _ in
                if reactor.currentState.isFavorite {
                    owner.showDeleteConfirmAlert(
                        title: "즐겨찾기 삭제",
                        message: "즐겨찾기에서 삭제하시겠습니까?"
                    ) {
                        reactor.action.onNext(.toggleFavorite)
                    }
                } else {
                    reactor.action.onNext(.toggleFavorite)
                }
            }
            .disposed(by: disposeBag)

        // 전화/링크 행 탭
        festivalDetailView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                guard case .infoRow(let row) = owner.festivalDetailView.dataSource[indexPath],
                      let action = row.action else { return }
                owner.perform(action)
            }
            .disposed(by: disposeBag)
    }

    private func bindState(reactor: FestivalDetailReactor) {
        reactor.state
            .map(\.isFavorite)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isFavorite in
                owner.favoriteButton.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
                owner.favoriteButton.tintColor = isFavorite ? .redPastel : .textPrimary
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    owner.festivalDetailView.showSkeleton()
                } else {
                    owner.festivalDetailView.hideSkeleton()
                    owner.festivalDetailView.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] sections in
                self?.festivalDetailView.updateLayout(with: sections)
            })
            .drive(festivalDetailView.collectionView.rx.items(dataSource: festivalDetailView.dataSource))
            .disposed(by: disposeBag)

        reactor.state
            .map(\.error)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "Unknown error")
            .drive(with: self) { owner, error in
                owner.showErrorAlert(message: error)
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$toastMessage)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, message in
                owner.showToast(message: message)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map(\.title)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, title in
                owner.navigationItem.title = title
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    private func perform(_ action: FestivalInfoRow.Action) {
        switch action {
        case .call(let number):
            guard let url = URL(string: "tel://\(number.filter { $0.isNumber || $0 == "+" })") else { return }
            UIApplication.shared.open(url)
        case .openURL(let url):
            UIApplication.shared.open(url)
        }
    }
}
