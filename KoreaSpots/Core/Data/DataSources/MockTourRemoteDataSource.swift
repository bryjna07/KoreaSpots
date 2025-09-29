//
//  MockTourRemoteDataSource.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/29/25.
//

import Foundation
import RxSwift

final class MockTourRemoteDataSource: TourRemoteDataSource {
    private let jsonDecoder = JSONDecoder()

    func fetchAreaBasedList(
        areaCode: Int,
        sigunguCode: Int?,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        let filename: String
        switch areaCode {
        case 1: filename = "areaBasedList2_seoul"
        case 6: filename = "areaBasedList2_busan"
        case 39: filename = "areaBasedList2_jeju"
        default: filename = "areaBasedList2_seoul" // 기본값으로 서울 사용
        }

        print("🏛️ Area-based search - areaCode: \(areaCode), sigunguCode: \(sigunguCode ?? 0), contentTypeId: \(contentTypeId ?? 0)")
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                response.toPlaces()
            }
            .asSingle()
    }

    func fetchFestivalList(
        eventStartDate: String,
        eventEndDate: String,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Festival]> {
        // 날짜에 따라 다른 축제 Mock 데이터 제공
        let filename: String
        // yyyyMMdd 형식에서 겨울철 (12월, 1월, 2월) 체크
        if eventStartDate.hasPrefix("202512") || eventStartDate.hasPrefix("202601") || eventStartDate.hasPrefix("202602") {
            filename = "searchFestival2_winter"
        } else {
            filename = "searchFestival2_2025-09-27_2025-10-27"
        }

        print("🗓️ Festival search - startDate: \(eventStartDate), endDate: \(eventEndDate)")
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                response.toFestivals()
            }
            .asSingle()
    }

    func fetchLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        print("📍 Location-based search - mapX: \(mapX), mapY: \(mapY), radius: \(radius)m")

        // 사용자 위치에 따라 다른 Mock 데이터 제공
        let filename = determineLocationMockFile(mapX: mapX, mapY: mapY)
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                response.toPlaces()
            }
            .asSingle()
    }

    private func determineLocationMockFile(mapX: Double, mapY: Double) -> String {
        // 유저 지역에 따라. api 제공
        return "locationBasedList2_sample"
    }

    func fetchDetailCommon(
        contentId: String,
        contentTypeId: Int?
    ) -> Single<Place> {
        return loadMockData(filename: "detailCommon2_sample")
            .map { response in
                response.toPlaces().first ?? Place.empty
            }
            .asSingle()
    }

    func fetchDetailIntro(
        contentId: String,
        contentTypeId: Int
    ) -> Single<Place> {
        return loadMockData(filename: "detailIntro2_sample")
            .map { response in
                response.toPlaces().first ?? Place.empty
            }
            .asSingle()
    }

    func fetchDetailImages(
        contentId: String,
        numOfRows: Int,
        pageNo: Int
    ) -> Single<[PlaceImage]> {
        print("🖼️ Detail images - contentId: \(contentId)")
        print("📂 Using mock file: detailImage2_sample")

        return loadMockImageData(filename: "detailImage2_sample")
            .map { response in
                response.toPlaceImages()
            }
            .asSingle()
    }

    private func loadMockData(filename: String) -> Observable<TourAPIResponse> {
        return Observable.create { [weak self] observer in
            print("🔄 Loading mock data: \(filename).json")
            guard let self = self else {
                observer.onError(DataSourceError.cacheError)
                return Disposables.create()
            }

            // 먼저 Bundle에서 Mock 디렉토리의 파일을 찾아보기
            var url: URL?

            // 1. Bundle의 Mock 하위 디렉토리에서 찾기
            url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Mock")
            if url != nil {
                print("📁 Found in Bundle Mock: \(filename).json")
            }

            // 2. Bundle의 Resources/Mock 하위 디렉토리에서 찾기
            if url == nil {
                url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources/Mock")
                if url != nil {
                    print("📁 Found in Bundle Resources/Mock: \(filename).json")
                }
            }

            // 3. Bundle 루트에서 찾기
            if url == nil {
                url = Bundle.main.url(forResource: filename, withExtension: "json")
                if url != nil {
                    print("📁 Found in Bundle root: \(filename).json")
                }
            }

            // 4. 파일 시스템에서 직접 찾기 (개발 중에만 사용)
            if url == nil {
                let mockPath = "/Users/youngjin/Desktop/SaeSsac/KoreaSpots/KoreaSpots/Resources/Mock/\(filename).json"
                if FileManager.default.fileExists(atPath: mockPath) {
                    url = URL(fileURLWithPath: mockPath)
                    print("📁 Using file system path: \(mockPath)")
                }
            }

            guard let mockURL = url else {
                let errorMessage = "Mock file not found: \(filename).json in Bundle or file system"
                print("⚠️ \(errorMessage)")
                observer.onError(DataSourceError.parseError)
                return Disposables.create()
            }

            do {
                let data = try Data(contentsOf: mockURL)
                print("📄 Mock data size: \(data.count) bytes")
                let response = try self.jsonDecoder.decode(TourAPIResponse.self, from: data)
                print("✅ Successfully decoded mock data from: \(mockURL.lastPathComponent)")
                print("📊 Items count: \(response.items.count)")
                observer.onNext(response)
                observer.onCompleted()
            } catch {
                print("❌ Failed to decode mock data from \(filename).json")
                print("❌ Error details: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ Decoding error details: \(decodingError)")
                }
                observer.onError(DataSourceError.parseError)
            }

            return Disposables.create()
        }
        .delay(.milliseconds(100), scheduler: MainScheduler.instance) // 실제 네트워크 지연 시뮬레이션
    }

    private func loadMockImageData(filename: String) -> Observable<TourAPIImageResponse> {
        return Observable.create { [weak self] observer in
            print("🔄 Loading mock image data: \(filename).json")
            guard let self = self else {
                observer.onError(DataSourceError.cacheError)
                return Disposables.create()
            }

            // 먼저 Bundle에서 Mock 디렉토리의 파일을 찾아보기
            var url: URL?

            // 1. Bundle의 Mock 하위 디렉토리에서 찾기
            url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Mock")
            if url != nil {
                print("📁 Found in Bundle Mock: \(filename).json")
            }

            // 2. Bundle의 Resources/Mock 하위 디렉토리에서 찾기
            if url == nil {
                url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources/Mock")
                if url != nil {
                    print("📁 Found in Bundle Resources/Mock: \(filename).json")
                }
            }

            // 3. 파일 시스템에서 직접 찾기 (개발 중에만 사용)
            if url == nil {
                let mockPath = "/Users/youngjin/Desktop/SaeSsac/KoreaSpots/KoreaSpots/Resources/Mock/\(filename).json"
                if FileManager.default.fileExists(atPath: mockPath) {
                    url = URL(fileURLWithPath: mockPath)
                    print("📁 Using file system path: \(mockPath)")
                }
            }

            guard let mockURL = url else {
                let errorMessage = "Mock image file not found: \(filename).json in Bundle or file system"
                print("⚠️ \(errorMessage)")
                observer.onError(DataSourceError.parseError)
                return Disposables.create()
            }

            do {
                let data = try Data(contentsOf: mockURL)
                print("📄 Mock image data size: \(data.count) bytes")
                let response = try self.jsonDecoder.decode(TourAPIImageResponse.self, from: data)
                print("✅ Successfully decoded mock image data from: \(mockURL.lastPathComponent)")
                print("📊 Images count: \(response.response.body?.items?.item.count ?? 0)")
                observer.onNext(response)
                observer.onCompleted()
            } catch {
                print("❌ Failed to decode mock image data from \(filename).json")
                print("❌ Error details: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ Decoding error details: \(decodingError)")
                }
                observer.onError(DataSourceError.parseError)
            }

            return Disposables.create()
        }
        .delay(.milliseconds(100), scheduler: MainScheduler.instance) // 실제 네트워크 지연 시뮬레이션
    }
}

// MARK: - Place Empty Extension
private extension Place {
    static var empty: Place {
        return Place(
            contentId: "",
            title: "",
            address: "",
            imageURL: nil,
            mapX: nil,
            mapY: nil,
            tel: nil,
            overview: nil,
            contentTypeId: 0,
            distance: nil
        )
    }
}
