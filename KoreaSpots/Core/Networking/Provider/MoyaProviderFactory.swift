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
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]

        return MoyaProvider<TourAPI>(plugins: plugins)
    }
}
