//
//  MockDataProvider.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/27/25.
//

import Foundation
import Moya

struct MockDataProvider {
    static func loadMockData(for endpoint: TourAPI) -> Data? {
        let filename = mockFilename(for: endpoint)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Mock"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Mock data not found for: \(filename).json")
            return nil
        }
        return data
    }

    private static func mockFilename(for endpoint: TourAPI) -> String {
        switch endpoint {
        case .areaBasedList(let areaCode, _, _, _, _, _):
            if areaCode == 1 {
                return "areaBasedList2_seoul"
            } else {
                return "areaBasedList2_seoul" // 기본값으로 서울 사용
            }
        case .searchFestival:
            return "searchFestival2_2025-09-27_2025-10-27"
        case .locationBasedList:
            return "locationBasedList2_sample"
        }
    }
}

// MARK: - Mock Provider Extension
extension MoyaProvider where Target == TourAPI {
    static func makeMockProvider() -> MoyaProvider<TourAPI> {
        let customEndpointClosure = { (target: TourAPI) -> Endpoint in
            return Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(200, MockDataProvider.loadMockData(for: target) ?? Data()) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }

        return MoyaProvider<TourAPI>(
            endpointClosure: customEndpointClosure,
            stubClosure: MoyaProvider.immediatelyStub,
            plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
        )
    }
}
