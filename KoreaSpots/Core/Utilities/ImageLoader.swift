//
//  ImageLoader.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/26/25.
//

import UIKit
import Kingfisher

// MARK: - ImageLoader Protocol
protocol ImageLoadable {
    func loadImage(from url: String?, placeholder: UIImage?, size: CGSize?, completion: ((Result<UIImage, Error>) -> Void)?)
    func cancelImageLoad()
}

// MARK: - ImageLoader Configuration
enum ImageLoader {

    // MARK: - 한국 관광지 앱에 최적화된 이미지 크기
    enum ImageSize {
        case thumbnail      // 썸네일: 80x80
        case listItem       // 리스트 아이템: 120x90
        case banner         // 배너: 375x200
        case detail         // 상세 화면: 375x280
        case fullScreen     // 전체 화면: 화면 크기

        var size: CGSize {
            switch self {
            case .thumbnail:
                return CGSize(width: 80, height: 80)
            case .listItem:
                return CGSize(width: 120, height: 90)
            case .banner:
                return CGSize(width: 375, height: 200)
            case .detail:
                return CGSize(width: 375, height: 280)
            case .fullScreen:
                return UIScreen.main.bounds.size
            }
        }
    }

    // MARK: - 캐시 정책
    enum CachePolicy {
        case memoryOnly     // 메모리만 (임시 이미지)
        case diskAndMemory  // 디스크 + 메모리 (일반 이미지)
        case aggressive     // 적극적 캐싱 (배너, 주요 이미지)

        var options: KingfisherOptionsInfo {
            switch self {
            case .memoryOnly:
                return [
                    .cacheMemoryOnly,
                    .diskCacheExpiration(.days(1))
                ]
            case .diskAndMemory:
                return [
                    .diskCacheExpiration(.days(7)),
                    .memoryCacheExpiration(.seconds(300))
                ]
            case .aggressive:
                return [
                    .diskCacheExpiration(.days(30)),
                    .memoryCacheExpiration(.seconds(600)),
                    .cacheOriginalImage
                ]
            }
        }
    }

    // MARK: - 기본 옵션 생성
    static func makeOptions(
        for size: ImageSize,
        cachePolicy: CachePolicy = .diskAndMemory,
        enableDownsampling: Bool = true
    ) -> KingfisherOptionsInfo {
        var options: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.2)),
            .backgroundDecode,
            .retryStrategy(DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(1)))
        ]

        // 다운샘플링 적용 (성능 최적화)
        if enableDownsampling {
            let processor = DownsamplingImageProcessor(size: size.size)
            options.append(.processor(processor))
        }

        // 캐시 정책 적용
        options.append(contentsOf: cachePolicy.options)

        return options
    }
}

// MARK: - UIImageView Extension
extension UIImageView: ImageLoadable {

    // MARK: - 기본 이미지 로딩 (URL 문자열)
    func loadImage(
        from urlString: String?,
        placeholder: UIImage? = nil,
        size: ImageLoader.ImageSize = .listItem,
        cachePolicy: ImageLoader.CachePolicy = .diskAndMemory,
        completion: ((Result<UIImage, Error>) -> Void)? = nil
    ) {
        guard let urlString = urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            image = placeholder
            completion?(.failure(ImageLoaderError.invalidURL))
            return
        }

        let options = ImageLoader.makeOptions(for: size, cachePolicy: cachePolicy)

        kf.indicatorType = .activity
        kf.setImage(
            with: url,
            placeholder: placeholder,
            options: options
        ) { result in
            switch result {
            case .success(let imageResult):
                completion?(.success(imageResult.image))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    // MARK: - Protocol 구현
    func loadImage(
        from url: String?,
        placeholder: UIImage?,
        size: CGSize?,
        completion: ((Result<UIImage, Error>) -> Void)?
    ) {
        let imageSize: ImageLoader.ImageSize
        if let size = size {
            // 커스텀 크기에 가장 근접한 ImageSize 찾기
            imageSize = ImageLoader.ImageSize.allCases.min { abs($0.size.width - size.width) < abs($1.size.width - size.width) } ?? .listItem
        } else {
            imageSize = .listItem
        }

        loadImage(from: url, placeholder: placeholder, size: imageSize, completion: completion)
    }

    // MARK: - 관광지 특화 메서드들
    func loadTourismImage(
        from urlString: String?,
        placeholder: UIImage? = UIImage(systemName: "photo.artframe"),
        type: TourismImageType = .attraction
    ) {
        let (size, cachePolicy) = type.imageConfiguration
        loadImage(
            from: urlString,
            placeholder: placeholder,
            size: size,
            cachePolicy: cachePolicy
        )
    }

    func loadFestivalBanner(from urlString: String?) {
        loadImage(
            from: urlString,
            placeholder: UIImage(systemName: "calendar.badge.exclamationmark"),
            size: .banner,
            cachePolicy: .aggressive
        )
    }

    func loadPlaceThumbnail(from urlString: String?) {
        loadImage(
            from: urlString,
            placeholder: UIImage(systemName: "mappin.and.ellipse"),
            size: .thumbnail,
            cachePolicy: .memoryOnly
        )
    }

    // MARK: - 이미지 로딩 취소
    func cancelImageLoad() {
        kf.cancelDownloadTask()
    }
}

// MARK: - 관광지 이미지 타입
enum TourismImageType {
    case attraction     // 관광지
    case festival       // 축제
    case restaurant     // 음식점
    case accommodation  // 숙소
    case banner         // 배너

    var imageConfiguration: (size: ImageLoader.ImageSize, cachePolicy: ImageLoader.CachePolicy) {
        switch self {
        case .attraction:
            return (.listItem, .diskAndMemory)
        case .festival:
            return (.banner, .aggressive)
        case .restaurant:
            return (.listItem, .diskAndMemory)
        case .accommodation:
            return (.detail, .diskAndMemory)
        case .banner:
            return (.banner, .aggressive)
        }
    }
}

// MARK: - ImageLoader Errors
enum ImageLoaderError: Error {
    case invalidURL
    case noImage
    case networkError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "올바르지 않은 이미지 URL입니다."
        case .noImage:
            return "이미지가 없습니다."
        case .networkError:
            return "네트워크 오류로 이미지를 불러올 수 없습니다."
        }
    }
}

// MARK: - ImageSize Extension
extension ImageLoader.ImageSize: CaseIterable {
    static var allCases: [ImageLoader.ImageSize] {
        return [.thumbnail, .listItem, .banner, .detail, .fullScreen]
    }
}
