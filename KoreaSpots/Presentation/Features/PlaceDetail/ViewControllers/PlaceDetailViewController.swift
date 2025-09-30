//
//  PlaceDetailViewController.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class PlaceDetailViewController: BaseViewController, View, Navigator {

    typealias Reactor = PlaceDetailReactor

    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var placeDetailView: PlaceDetailView { return view as! PlaceDetailView }

    // MARK: - Lifecycle
    override func loadView() {
        view = PlaceDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Bind
    func bind(reactor: PlaceDetailReactor) {
        // Action
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        placeDetailView.refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isLoading in
                if isLoading {
                    owner.placeDetailView.showSkeleton()
                } else {
                    owner.placeDetailView.hideSkeleton()
                    owner.placeDetailView.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] sections in
                self?.placeDetailView.updateLayout(with: sections)
            })
            .drive(placeDetailView.collectionView.rx.items(dataSource: placeDetailView.dataSource))
            .disposed(by: disposeBag)

        reactor.state
            .map(\.error)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "Unknown error")
            .drive(with: self, onNext: { owner, error in
                owner.showErrorAlert(message: error)
            })
            .disposed(by: disposeBag)

        // Navigation Title
        reactor.state
            .map(\.placeDetail?.place.title)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, title in
                owner.navigationItem.title = title
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup
private extension PlaceDetailViewController {

    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never

        // Back button
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        pop()
    }
}