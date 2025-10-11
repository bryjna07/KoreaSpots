//
//  PlaceLocationCell.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import UIKit
import MapKit
import SnapKit
import Then
import SkeletonView

final class PlaceLocationCell: BaseCollectionViewCell {

    // MARK: - UI Components
    private let containerView = UIView()
    private let mapView = MKMapView()
    private let addressLabel = UILabel()

    // MARK: - Configuration
    func configure(with place: Place) {
        addressLabel.text = place.address

        // 지도에 위치 표시
        if let latitude = place.mapY, let longitude = place.mapX {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: false)

            // 핀 추가
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = place.title
            mapView.addAnnotation(annotation)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        addressLabel.text = nil
        mapView.removeAnnotations(mapView.annotations)
    }
}

// MARK: - ConfigureUI
extension PlaceLocationCell {

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(
            mapView,
            addressLabel
        )
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(Constants.Layout.smallPadding)
            $0.leading.trailing.equalToSuperview().inset(Constants.Layout.standardPadding)
            $0.bottom.equalToSuperview().inset(Constants.Layout.standardPadding)
        }
    }

    override func configureView() {
        super.configureView()

        containerView.do {
            $0.backgroundColor = .backGround
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = Constants.UI.Shadow.opacity
            $0.layer.shadowOffset = Constants.UI.Shadow.offset
            $0.layer.shadowRadius = Constants.UI.Shadow.radius
            $0.isSkeletonable = true
        }

        mapView.do {
            $0.layer.cornerRadius = Constants.UI.CornerRadius.medium
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.showsUserLocation = false
            $0.isUserInteractionEnabled = false
            $0.mapType = .standard
            $0.isSkeletonable = true
        }

        addressLabel.do {
            ///TODO: - 폰트, 높이 조절 필요
            $0.font = UIFont.systemFont(ofSize: 16)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 2
            $0.isSkeletonable = true
        }
    }
}
