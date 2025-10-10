//
//  TripTitleCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class TripTitleCell: UICollectionViewCell {

    // MARK: - Properties

    private var disposeBag = DisposeBag()
    var onTextChanged: ((String) -> Void)?

    // MARK: - UI Components

    private let titleTextField = UITextField().then {
        $0.placeholder = "여행 제목"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.borderStyle = .roundedRect
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(titleTextField)
    }

    private func setupConstraints() {
        titleTextField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.height.greaterThanOrEqualTo(44)
        }
    }

    private func setupBinding() {
        titleTextField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                self.onTextChanged?(text)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Configuration

    func configure(with title: String) {
        if titleTextField.text != title {
            titleTextField.text = title
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        setupBinding()
    }
}
