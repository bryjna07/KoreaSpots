//
//  MoyaProviderFactory.swift
//  KoreaSpots
//
//  Created by YoungJin on 9/25/25.
//

import Moya
import RxMoya

enum MoyaProviderFactory {
    /// 실제 API Provider 반환
    static func makeTourProvider() -> MoyaProvider<TourAPI> {
        // 요청 URL에 serviceKey가 포함되므로 릴리스 빌드에서는 로깅하지 않음
        #if DEBUG
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        #else
        let plugins: [PluginType] = []
        #endif

        return MoyaProvider<TourAPI>(plugins: plugins)
    }
}
