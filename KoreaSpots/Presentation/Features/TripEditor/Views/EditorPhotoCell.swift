//
//  EditorPhotoCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/10/25.
//

import UIKit
import SnapKit
import Then

// MARK: - EditorPhotoCell

final class EditorPhotoCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .system)
    private let addIconImageView = UIImageView()
    private let addLabel = UILabel()

    var onDeleteTapped: (() -> Void)?
    var onAddTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubviews(imageView, deleteButton, addIconImageView, addLabel)

        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondBackGround

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        deleteButton.do {
            $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            $0.layer.cornerRadius = 12
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }

        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.size.equalTo(24)
        }

        addIconImageView.do {
            $0.image = UIImage(systemName: "plus")
            $0.tintColor = .tertiaryLabel
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        addIconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-10)
            $0.size.equalTo(24)
        }

        addLabel.do {
            $0.text = "추가"
            $0.font = FontManager.caption1
            $0.textColor = .tertiaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }

        addLabel.snp.makeConstraints {
            $0.top.equalTo(addIconImageView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    func configure(with photo: TripPhoto) {
        imageView.isHidden = false
        deleteButton.isHidden = false
        addIconImageView.isHidden = true
        addLabel.isHidden = true
        contentView.backgroundColor = .systemGray5

        if !photo.localPath.isEmpty,
           FileManager.default.fileExists(atPath: photo.localPath),
           let image = UIImage(contentsOfFile: photo.localPath) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .tertiaryLabel
            imageView.contentMode = .scaleAspectFit
        }
    }

    func configureAsAddButton() {
        imageView.isHidden = true
        imageView.image = nil
        deleteButton.isHidden = true
        addIconImageView.isHidden = false
        addLabel.isHidden = false
        contentView.backgroundColor = .secondBackGround
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }

    @objc private func cellTapped() {
        if !addIconImageView.isHidden {
            onAddTapped?()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        onDeleteTapped = nil
        onAddTapped = nil
    }
}