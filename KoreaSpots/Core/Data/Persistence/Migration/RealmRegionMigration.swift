//
//  RealmRegionMigration.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/12/25.
//

import Foundation
import RealmSwift

/// Realm v2 → v3: 저장된 옛 지역 코드(areaCode/sigunguCode)를 법정동 코드로 변환
/// - 배경: TourAPI 개편(2026)으로 지역 코드 체계가 바뀜 (docs/api.md 참고)
/// - PlaceR: 일반 캐시 행은 삭제(옛 코드로 받은 부분 결과), 즐겨찾기·커스텀 장소는 변환
/// - VisitedPlaceE / VisitedAreaE / VisitIndexR(여행 기록): 변환. 분리·폐지된 시군구는 nil
enum RealmRegionMigration {
    private struct Report {
        var convertedArea = 0
        var droppedSigungu = 0
        var unknownArea = 0
        var deletedCache = 0
    }

    static func migrate(_ migration: Migration) {
        var report = Report()

        migration.enumerateObjects(ofType: PlaceR.className()) { _, newObject in
            guard let newObject else { return }
            let isFavorite = newObject["isFavorite"] as? Bool ?? false
            let isCustom = newObject["isCustom"] as? Bool ?? false
            if !isFavorite && !isCustom {
                migration.delete(newObject)
                report.deletedCache += 1
                return
            }
            convertRegion(of: newObject, report: &report)
        }

        let tripTypes = [VisitedPlaceE.className(), VisitedAreaE.className(), VisitIndexR.className()]
        for type in tripTypes {
            migration.enumerateObjects(ofType: type) { _, newObject in
                guard let newObject else { return }
                convertRegion(of: newObject, report: &report)
            }
        }

        #if DEBUG
        print("🔄 Migration v2→v3 (region codes): area \(report.convertedArea) converted, "
              + "\(report.unknownArea) unknown→nil, sigungu \(report.droppedSigungu) dropped, "
              + "cache rows deleted \(report.deletedCache)")
        #endif
    }

    /// areaCode/sigunguCode를 새 체계로 변환. 0은 "위치 기반(지역 없음)" 관례라 그대로 둔다
    private static func convertRegion(of object: MigrationObject, report: inout Report) {
        guard let oldArea = object["areaCode"] as? Int, oldArea != 0 else { return }

        guard let newArea = LegacyRegionMap.regionCode(fromLegacyArea: oldArea) else {
            object["areaCode"] = nil
            object["sigunguCode"] = nil
            report.unknownArea += 1
            return
        }
        object["areaCode"] = newArea
        report.convertedArea += 1

        if let oldSigungu = object["sigunguCode"] as? Int {
            let newSigungu = LegacyRegionMap.signguCode(fromLegacyArea: oldArea, sigungu: oldSigungu)
            object["sigunguCode"] = newSigungu
            if newSigungu == nil { report.droppedSigungu += 1 }
        }
    }
}
