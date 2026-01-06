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

    // MARK: - Mock Data Prefix
    /// Mock 데이터에 "[예시]" 접두사 추가 (배열)
    private func addMockPrefix(to places: [Place]) -> [Place] {
        return places.map { addMockPrefix(to: $0) }
    }

    /// Mock 데이터에 "[예시]" 접두사 추가 (단일 객체)
    private func addMockPrefix(to place: Place) -> Place {
        return Place(
            contentId: place.contentId,
            title: "[예시] \(place.title)",
            address: place.address,
            imageURL: place.imageURL,
            mapX: place.mapX,
            mapY: place.mapY,
            tel: place.tel,
            overview: place.overview,
            contentTypeId: place.contentTypeId,
            areaCode: place.areaCode,
            sigunguCode: place.sigunguCode,
            cat1: place.cat1,
            cat2: place.cat2,
            cat3: place.cat3,
            distance: place.distance,
            modifiedTime: place.modifiedTime,
            eventMeta: place.eventMeta,
            isCustom: place.isCustom,
            customPlaceId: place.customPlaceId,
            userProvidedImagePath: place.userProvidedImagePath
        )
    }

    func fetchAreaBasedList(
        areaCode: Int?,
        sigunguCode: Int?,
        contentTypeId: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        // 통합 Mock 파일 사용
        let filename = "areaBasedList2"

        print("🏛️ Area-based search - areaCode: \(areaCode ?? 0), sigunguCode: \(sigunguCode ?? 0), contentTypeId: \(contentTypeId ?? 0), cat1: \(cat1 ?? "nil"), cat2: \(cat2 ?? "nil"), cat3: \(cat3 ?? "nil")")
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                var places = response.toPlaces()

                // 지역 필터링 (areaCode가 nil이면 전국 검색)
                if let areaCode = areaCode, areaCode > 0 {
                    places = places.filter { $0.areaCode == areaCode }
                }

                // 시군구 필터링
                if let sigunguCode = sigunguCode {
                    places = places.filter { $0.sigunguCode == sigunguCode }
                }

                // 콘텐츠 타입 필터링
                if let contentTypeId = contentTypeId {
                    places = places.filter { $0.contentTypeId == contentTypeId }
                }

                // cat1 필터링 (대분류)
                if let cat1 = cat1, !cat1.isEmpty {
                    places = places.filter { $0.cat1 == cat1 }
                    print("🔍 cat1 filter applied: \(cat1), results: \(places.count)")
                }

                // cat2 필터링 (중분류)
                if let cat2 = cat2, !cat2.isEmpty {
                    places = places.filter { $0.cat2 == cat2 }
                    print("🔍 cat2 filter applied: \(cat2), results: \(places.count)")
                }

                // cat3 필터링 (쉼표 구분 복수 값 지원, 소분류)
                if let cat3 = cat3, !cat3.isEmpty {
                    let cat3List = cat3.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                    if !cat3List.isEmpty {
                        places = places.filter { place in
                            guard let placeCat3 = place.cat3 else { return false }
                            return cat3List.contains(placeCat3)
                        }
                        print("🔍 cat3 filter applied: \(cat3List), results: \(places.count)")
                    }
                }

                print("📊 Filtered results: \(places.count) places")

                // 페이징 처리
                let startIndex = (pageNo - 1) * numOfRows
                let endIndex = min(startIndex + numOfRows, places.count)

                guard startIndex < places.count else {
                    print("📄 Page \(pageNo) is out of range, returning empty")
                    return []
                }

                let pagedPlaces = Array(places[startIndex..<endIndex])
                print("📄 Paging: page=\(pageNo), numOfRows=\(numOfRows), returning \(pagedPlaces.count) places (startIndex: \(startIndex), endIndex: \(endIndex))")

                return self.addMockPrefix(to: pagedPlaces)
            }
            .asSingle()
    }

    func fetchFestivalList(
        eventStartDate: String,
        eventEndDate: String,
        areaCode: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        // Mock 데이터는 단일 파일 사용
        let filename = "searchFestival2_2025-09-27_2025-10-27"

        print("🗓️ Festival search - startDate: \(eventStartDate), endDate: \(eventEndDate), areaCode: \(areaCode ?? 0)")
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                var places = response.toFestivalPlaces()  // Festival → Place (eventMeta 포함)

                // 지역 필터링 (areaCode가 nil이면 전국 축제)
                if let areaCode = areaCode, areaCode > 0 {
                    places = places.filter { $0.areaCode == areaCode }
                    print("🔍 AreaCode filter applied: \(areaCode), results: \(places.count)")
                }

                return self.addMockPrefix(to: places)
            }
            .asSingle()
    }

    func fetchSearchKeyword(
        keyword: String,
        areaCode: Int?,
        sigunguCode: Int?,
        contentTypeId: Int?,
        cat1: String?,
        cat2: String?,
        cat3: String?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        let filename = "areaBasedList2"

        print("🔍 Keyword search - keyword: \(keyword)")
        print("🔍 Filters - areaCode: \(areaCode ?? 0), sigunguCode: \(sigunguCode ?? 0), contentTypeId: \(contentTypeId ?? 0)")
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                var places = response.toPlaces()

                // 1. 키워드 필터링 (title or address contains keyword)
                let lowercasedKeyword = keyword.lowercased()
                places = places.filter { place in
                    place.title.lowercased().contains(lowercasedKeyword) ||
                    (place.address.lowercased().contains(lowercasedKeyword))
                }
                print("🔍 Keyword filter applied: \(keyword), results: \(places.count)")

                // 2. 지역 필터링
                if let areaCode = areaCode, areaCode > 0 {
                    places = places.filter { $0.areaCode == areaCode }
                    print("🔍 AreaCode filter applied: \(areaCode), results: \(places.count)")
                }

                // 3. 시군구 필터링
                if let sigunguCode = sigunguCode {
                    places = places.filter { $0.sigunguCode == sigunguCode }
                    print("🔍 SigunguCode filter applied: \(sigunguCode), results: \(places.count)")
                }

                // 4. 콘텐츠 타입 필터링
                if let contentTypeId = contentTypeId {
                    places = places.filter { $0.contentTypeId == contentTypeId }
                    print("🔍 ContentTypeId filter applied: \(contentTypeId), results: \(places.count)")
                }

                // 5. cat1 필터링 (대분류)
                if let cat1 = cat1, !cat1.isEmpty {
                    places = places.filter { $0.cat1 == cat1 }
                    print("🔍 cat1 filter applied: \(cat1), results: \(places.count)")
                }

                // 6. cat2 필터링 (중분류)
                if let cat2 = cat2, !cat2.isEmpty {
                    places = places.filter { $0.cat2 == cat2 }
                    print("🔍 cat2 filter applied: \(cat2), results: \(places.count)")
                }

                // 7. cat3 필터링 (쉼표 구분 복수 값 지원, 소분류)
                if let cat3 = cat3, !cat3.isEmpty {
                    let cat3List = cat3.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                    if !cat3List.isEmpty {
                        places = places.filter { place in
                            guard let placeCat3 = place.cat3 else { return false }
                            return cat3List.contains(placeCat3)
                        }
                        print("🔍 cat3 filter applied: \(cat3List), results: \(places.count)")
                    }
                }

                print("📊 Final search results: \(places.count) places")
                return self.addMockPrefix(to: places)
            }
            .asSingle()
    }

    func fetchLocationBasedList(
        mapX: Double,
        mapY: Double,
        radius: Int,
        contentTypeId: Int?,
        numOfRows: Int,
        pageNo: Int,
        arrange: String
    ) -> Single<[Place]> {
        print("📍 Location-based search - mapX: \(mapX), mapY: \(mapY), radius: \(radius)m, contentTypeId: \(contentTypeId ?? 0)")

        // 사용자 위치에 따라 다른 Mock 데이터 제공
        let filename = determineLocationMockFile(mapX: mapX, mapY: mapY)
        print("📂 Using mock file: \(filename)")

        return loadMockData(filename: filename)
            .map { response in
                var places = response.toPlaces()

                // 콘텐츠 타입 필터링 (12: 관광지, 14: 문화시설, 15: 축제, 38: 쇼핑, 39: 음식점)
                if let contentTypeId = contentTypeId {
                    places = places.filter { $0.contentTypeId == contentTypeId }
                    print("🔍 ContentTypeId filter applied: \(contentTypeId), results: \(places.count)")
                }

                return self.addMockPrefix(to: places)
            }
            .asSingle()
    }

    private func determineLocationMockFile(mapX: Double, mapY: Double) -> String {
        // 유저 지역에 따라. api 제공
        return "locationBasedList2"
    }

    func fetchDetailCommon(
        contentId: String
    ) -> Single<Place> {
        print("📋 Detail common - contentId: \(contentId)")
        return loadMockData(filename: "detailCommon2")
            .map { response in
                let places = response.toPlaces()
                guard let matchedPlace = places.first(where: { $0.contentId == contentId }) else {
                    print("⚠️ No detailCommon found for contentId \(contentId), returning first place")
                    return self.addMockPrefix(to: places.first ?? Place.empty)
                }
                print("✅ Found detailCommon for contentId \(contentId)")
                return self.addMockPrefix(to: matchedPlace)
            }
            .asSingle()
    }

    func fetchDetailIntro(
        contentId: String,
        contentTypeId: Int
    ) -> Single<OperatingInfo> {
        print("🏢 Detail intro - contentId: \(contentId), contentTypeId: \(contentTypeId)")
        return loadMockDetailIntroData(filename: "detailIntro2")
            .map { response in
                let operatingInfo = response.toOperatingInfo()
                print("✅ Found detailIntro for contentId \(contentId)")
                return operatingInfo
            }
            .asSingle()
    }

    func fetchDetailImages(
        contentId: String
    ) -> Single<[PlaceImage]> {
        print("🖼️ Detail images - contentId: \(contentId)")

        // 1. detailImage2_<contentId>.json 파일이 있는지 확인
        let specificFilename = "detailImage2_\(contentId)"
        if fileExists(filename: specificFilename) {
            print("✅ Found specific image file: \(specificFilename).json")
            return loadMockImageData(filename: specificFilename)
                .map { response in
                    response.toPlaceImages()
                }
                .asSingle()
        }

        // 2. 파일이 없으면 여러 소스에서 firstimage 검색
        print("⚠️ No specific image file for contentId \(contentId), searching in mock data files")
        let fallbackImages = loadFallbackImageFromMultipleSources(contentId: contentId)
        return Single.just(fallbackImages)
    }

    private func fileExists(filename: String) -> Bool {
        // Bundle Mock 폴더에서 확인
        if Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Mock") != nil {
            return true
        }

        // Resources/Mock 폴더에서 확인
        if Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources/Mock") != nil {
            return true
        }

        // 파일 시스템에서 직접 확인 (개발 중)
        let mockPath = "/Users/youngjin/Desktop/SaeSsac/KoreaSpots/KoreaSpots/Resources/Mock/\(filename).json"
        return FileManager.default.fileExists(atPath: mockPath)
    }

    private func loadFallbackImageFromMultipleSources(contentId: String) -> [PlaceImage] {
        print("🔍 Searching fallback image for contentId: \(contentId)")

        // 1. locationBasedList2에서 먼저 검색
        if let image = loadFallbackImageFromFile(contentId: contentId, filename: "locationBasedList2") {
            return [image]
        }

        // 2. areaBasedList2에서 검색
        if let image = loadFallbackImageFromFile(contentId: contentId, filename: "areaBasedList2") {
            return [image]
        }

        print("❌ No fallback image found for contentId \(contentId)")
        return []
    }

    private func loadFallbackImageFromFile(contentId: String, filename: String) -> PlaceImage? {
        var url: URL?

        // 1. Bundle Mock 폴더에서 찾기
        url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Mock")

        // 2. Bundle Resources/Mock 폴더에서 찾기
        if url == nil {
            url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Resources/Mock")
        }

        // 3. Bundle 루트에서 찾기
        if url == nil {
            url = Bundle.main.url(forResource: filename, withExtension: "json")
        }

        // 4. 파일 시스템에서 직접 찾기 (개발 중)
        if url == nil {
            let mockPath = "/Users/youngjin/Desktop/SaeSsac/KoreaSpots/KoreaSpots/Resources/Mock/\(filename).json"
            if FileManager.default.fileExists(atPath: mockPath) {
                url = URL(fileURLWithPath: mockPath)
            }
        }

        guard let fileURL = url,
              let data = try? Data(contentsOf: fileURL),
              let response = try? jsonDecoder.decode(TourAPIResponse.self, from: data) else {
            return nil
        }

        let places = response.toPlaces()
        guard let place = places.first(where: { $0.contentId == contentId }),
              let imageURL = place.imageURL else {
            return nil
        }

        print("✅ Using fallback firstimage from \(filename): \(imageURL)")
        return PlaceImage(
            contentId: contentId,
            originImageURL: imageURL,
            imageName: place.title,
            smallImageURL: imageURL
        )
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

    func fetchDetailInfo(
        contentId: String,
        contentTypeId: Int
    ) -> Single<[TravelCourseDetailItem]> {
        print("🗺️ Detail info - contentId: \(contentId), contentTypeId: \(contentTypeId)")
        // 여행코스 상세 정보는 빈 배열 반환 (Mock 데이터 없음)
        return Single.just([])
    }

    private func loadMockDetailIntroData(filename: String) -> Observable<TourAPIDetailIntroResponse> {
        return Observable.create { [weak self] observer in
            print("🔄 Loading mock detail intro data: \(filename).json")
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
                let errorMessage = "Mock detail intro file not found: \(filename).json in Bundle or file system"
                print("⚠️ \(errorMessage)")
                observer.onError(DataSourceError.parseError)
                return Disposables.create()
            }

            do {
                let data = try Data(contentsOf: mockURL)
                print("📄 Mock detail intro data size: \(data.count) bytes")
                let response = try self.jsonDecoder.decode(TourAPIDetailIntroResponse.self, from: data)
                print("✅ Successfully decoded mock detail intro data from: \(mockURL.lastPathComponent)")
                print("📊 Items count: \(response.items.count)")
                observer.onNext(response)
                observer.onCompleted()
            } catch {
                print("❌ Failed to decode mock detail intro data from \(filename).json")
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

