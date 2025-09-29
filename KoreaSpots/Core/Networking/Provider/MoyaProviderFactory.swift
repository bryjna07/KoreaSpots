//
//  MoyaProviderFactory.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Moya
import RxMoya

enum MoyaProviderFactory {
    /// 환경에 따라 Mock 또는 실제 API Provider 반환
    static func makeTourProvider(useMock: Bool = false, stub: Bool = false) -> MoyaProvider<TourAPI> {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]

        if useMock {
            return MoyaProvider<TourAPI>.makeMockProvider()
        } else if stub {
            return MoyaProvider<TourAPI>(stubClosure: MoyaProvider.immediatelyStub, plugins: plugins)
        } else {
            return MoyaProvider<TourAPI>(plugins: plugins)
        }
    }

    /// 개발 환경에서 Mock 데이터를 쉽게 사용할 수 있는 헬퍼
    static func makeDevTourProvider() -> MoyaProvider<TourAPI> {
        #if DEBUG
        // 개발 중에는 Mock 데이터 사용 (서버 문제 대응)
        return makeTourProvider(useMock: true)
        #else
        return makeTourProvider(useMock: false)
        #endif
    }
}
