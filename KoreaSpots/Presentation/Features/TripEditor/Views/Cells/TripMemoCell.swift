//
//  TripMemoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

final class TripMemoCell: UICollectionViewCell {

    // MARK: - Properties

    var onTextChanged: ((String) -> Void)?
    private var isConfiguring = false

    // MARK: - UI Components

    private let memoTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.cornerRadius = 8
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        memoTextView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(memoTextView)
    }

    private func setupConstraints() {
        memoTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
            $0.height.greaterThanOrEqualTo(100)
        }
    }

    // MARK: - Configuration

    func configure(with memo: String) {
        isConfiguring = true
        if memoTextView.text != memo {
            memoTextView.text = memo
        }
        isConfiguring = false
    }
}

// MARK: - UITextViewDelegate

extension TripMemoCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard !isConfiguring else { return }
        onTextChanged?(textView.text)
    }
}
