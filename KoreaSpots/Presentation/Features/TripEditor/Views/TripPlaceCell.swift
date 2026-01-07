//
//  TripPlaceCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class TripPlaceCell: BaseCollectionViewCell {

    // MARK: - Properties

    var onDeleteTapped: (() -> Void)?
    private var isShowingDelete = false
    private var panStartX: CGFloat = 0

    // MARK: - UI Components

    private let containerView = UIView()
    private let deleteButton = UIButton(type: .system)
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let reorderIcon = UIImageView()

    // MARK: - Lifecycle

    override func configureHierarchy() {
        contentView.addSubview(deleteButton)
        contentView.addSubview(containerView)
        containerView.addSubviews(thumbnailImageView, titleLabel, reorderIcon)
    }

    override func configureLayout() {
        // contentView를 셀에 꽉 채우고 고정 높이 설정
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(76)
        }

        // 삭제 버튼은 containerView 뒤에 숨겨져 있다가 스와이프 시 보임
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(70)
        }

        // containerView는 contentView와 동일한 크기 (스와이프 시 transform으로 이동)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(60)
        }

        reorderIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(reorderIcon.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()

        contentView.do {
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
        }

        deleteButton.do {
            $0.backgroundColor = .systemRed
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            $0.layer.cornerRadius = 8
            $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // 오른쪽만 둥글게
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }

        containerView.do {
            $0.backgroundColor = .secondBackGround
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .systemGray6
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
        }

        reorderIcon.do {
            $0.image = UIImage(systemName: "line.3.horizontal")
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
        }

        // 스와이프 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        containerView.addGestureRecognizer(panGesture)

        // 탭하면 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Configuration

    func configure(with place: VisitedPlace) {
        titleLabel.text = place.placeNameSnapshot

        if let thumbnailURL = place.thumbnailURLSnapshot, let url = URL(string: thumbnailURL) {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }

        // 초기 상태로 리셋
        resetSwipeState(animated: false)
    }

    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: contentView)

        switch gesture.state {
        case .began:
            panStartX = containerView.frame.origin.x

        case .changed:
            let newX = panStartX + translation.x
            // 왼쪽으로만 스와이프 가능 (최대 -70까지)
            let clampedX = max(-70, min(0, newX))
            containerView.transform = CGAffineTransform(translationX: clampedX, y: 0)

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: contentView)
            let currentX = containerView.transform.tx

            // 빠르게 스와이프하거나 35 이상 스와이프했으면 삭제 버튼 표시
            if velocity.x < -500 || currentX < -35 {
                showDeleteButton()
            } else {
                hideDeleteButton()
            }

        default:
            break
        }
    }

    @objc private func handleTap() {
        if isShowingDelete {
            hideDeleteButton()
        }
    }

    private func showDeleteButton() {
        isShowingDelete = true
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = CGAffineTransform(translationX: -70, y: 0)
        }
    }

    private func hideDeleteButton() {
        isShowingDelete = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
        }
    }

    func resetSwipeState(animated: Bool = true) {
        isShowingDelete = false
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.containerView.transform = .identity
            }
        } else {
            containerView.transform = .identity
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        onDeleteTapped = nil
        resetSwipeState(animated: false)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TripPlaceCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: contentView)
            // 수평 스와이프만 인식 (드래그 앤 드롭과 충돌 방지)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
}
