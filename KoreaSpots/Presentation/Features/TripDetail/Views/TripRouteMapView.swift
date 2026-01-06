//
//  TripRouteMapView.swift
//  KoreaSpots
//
//  Created by Watson22_YJ on 11/16/25.
//

import UIKit
import MapKit
import SnapKit
import Then

final class TripRouteMapView: BaseView {

    // MARK: - UI Components

    let mapView = MKMapView().then {
        $0.showsUserLocation = false
        $0.showsCompass = true
        $0.showsScale = true
    }

    private let emptyStateLabel = UILabel().then {
        $0.text = "방문지의 위치 정보가 없습니다."
        $0.font = FontManager.body
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - Properties

    private var visitedPlaces: [VisitedPlace] = []
    private var routePolyline: MKPolyline?

    // MARK: - Hierarchy & Layout

    override func configureHierarchy() {
        addSubviews(mapView, emptyStateLabel)
    }

    override func configureLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
    }

    override func configureView() {
        mapView.delegate = self
    }

    // MARK: - Public Methods

    func configure(with visitedPlaces: [VisitedPlace]) {
        self.visitedPlaces = visitedPlaces.sorted { $0.order < $1.order }

        // Clear existing annotations and overlays
        mapView.removeAnnotations(mapView.annotations)
        if let polyline = routePolyline {
            mapView.removeOverlay(polyline)
        }

        // Filter places with location
        let placesWithLocation = self.visitedPlaces.compactMap { place -> (VisitedPlace, GeoPoint)? in
            guard let location = place.location else { return nil }
            return (place, location)
        }

        guard !placesWithLocation.isEmpty else {
            emptyStateLabel.isHidden = false
            mapView.isHidden = true
            return
        }

        emptyStateLabel.isHidden = true
        mapView.isHidden = false

        // Add annotations
        for (index, (place, location)) in placesWithLocation.enumerated() {
            let annotation = PlaceAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng),
                title: place.placeNameSnapshot,
                subtitle: nil,
                order: index + 1
            )
            mapView.addAnnotation(annotation)
        }

        // Add route polyline
        if placesWithLocation.count >= 2 {
            let coordinates = placesWithLocation.map {
                CLLocationCoordinate2D(latitude: $0.1.lat, longitude: $0.1.lng)
            }
            routePolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(routePolyline!)
        }

        // Fit map to show all annotations
        let annotations = mapView.annotations
        if !annotations.isEmpty {
            mapView.showAnnotations(annotations, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate

extension TripRouteMapView: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else {
            return nil
        }

        let identifier = "PlaceMarkerAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        // MKMarkerAnnotationView 스타일 (TripEditorView와 동일)
        annotationView?.markerTintColor = .primary
        annotationView?.glyphText = "\(placeAnnotation.order)"

        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.primary
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: - PlaceAnnotation

final class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let order: Int

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, order: Int) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.order = order
    }
}
