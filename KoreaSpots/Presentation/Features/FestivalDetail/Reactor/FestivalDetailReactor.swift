//
//  FestivalDetailReactor.swift
//  KoreaSpots
//
//  Created by YoungJin on 11/13/26.
//

import Foundation
import ReactorKit
import RxSwift

final class FestivalDetailReactor: Reactor {

    enum Action {
        case viewDidLoad
        case refresh
        case toggleFavorite
    }

    enum Mutation {
        case setLoading(Bool)
        case setSections(title: String, sections: [FestivalDetailSectionModel])
        case setError(String?)
        case setFavorite(Bool)
        case showToast(String)
    }

    struct State {
        var isLoading: Bool = false
        var title: String?
        var sections: [FestivalDetailSectionModel] = []
        var error: String?
        var isFavorite: Bool = false
        @Pulse var toastMessage: String?
    }

    let initialState = State()
    private let place: Place
    private let tourRepository: TourRepository
    private let checkFavoriteUseCase: CheckFavoriteUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase

    init(
        place: Place,
        tourRepository: TourRepository,
        checkFavoriteUseCase: CheckFavoriteUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.place = place
        self.tourRepository = tourRepository
        self.checkFavoriteUseCase = checkFavoriteUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                .just(.setLoading(true)),
                checkFavoriteStatus(),
                fetchFestivalDetail(),
                .just(.setLoading(false))
            ])

        case .refresh:
            return Observable.concat([
                .just(.setLoading(true)),
                fetchFestivalDetail(),
                .just(.setLoading(false))
            ])

        case .toggleFavorite:
            let wasLiked = currentState.isFavorite
            let placeName = place.title

            return toggleFavoriteUseCase.execute(place: place, isFavorite: wasLiked)
                .andThen(Observable.just(()))
                .flatMap { [weak self] _ -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    return Observable.concat([
                        self.checkFavoriteStatus(),
                        wasLiked ? .empty() : .just(.showToast("\(placeName)이(가) 즐겨찾기에 추가되었습니다."))
                    ])
                }
                .catch { error in
                    let message = (error as? LocalizedError)?.errorDescription ?? "즐겨찾기 변경 중 오류가 발생했습니다."
                    return .just(.setError(message))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setSections(title, sections):
            newState.title = title
            newState.sections = sections
            newState.error = nil
        case let .setError(error):
            newState.error = error
        case let .setFavorite(isFavorite):
            newState.isFavorite = isFavorite
        case let .showToast(message):
            newState.toastMessage = message
        }

        return newState
    }
}

// MARK: - Fetch
private extension FestivalDetailReactor {

    func checkFavoriteStatus() -> Observable<Mutation> {
        return checkFavoriteUseCase.execute(contentId: place.contentId)
            .asObservable()
            .map { Mutation.setFavorite($0) }
            .catch { _ in .empty() }
    }

    func fetchFestivalDetail() -> Observable<Mutation> {
        let contentTypeId = place.contentTypeId ?? 15

        // 이미지 조회 실패는 화면 전체 실패로 보지 않고 빈 배열로 대체
        let images = tourRepository.getPlaceImages(contentId: place.contentId)
            .asObservable()
            .catch { _ in .just([]) }

        return Observable.combineLatest(
            tourRepository.getPlaceDetail(contentId: place.contentId).asObservable(),
            tourRepository.getPlaceOperatingInfo(contentId: place.contentId, contentTypeId: contentTypeId).asObservable(),
            images
        )
        .map { [weak self] detail, operatingInfo, images -> Mutation in
            guard let self else { return .setLoading(false) }
            let sections = self.buildSections(detail: detail, operatingInfo: operatingInfo, images: images)
            return .setSections(title: detail.title, sections: sections)
        }
        .catch { _ in .just(.setError(LocalizedKeys.Error.fetchPlaceDetailFailed.localized)) }
    }
}

// MARK: - Build Sections
private extension FestivalDetailReactor {

    typealias Keys = LocalizedKeys.FestivalDetail

    func buildSections(detail: Place, operatingInfo: OperatingInfo, images: [PlaceImage]) -> [FestivalDetailSectionModel] {
        var sections: [FestivalDetailSectionModel] = []

        var festivalInfo: FestivalSpecificInfo?
        if case .festival(let info) = operatingInfo.specificInfo {
            festivalInfo = info
        }

        // 이미지: 상세 이미지가 없으면 대표 이미지 한 장으로 대체
        var imageList = images
        if imageList.isEmpty, let url = detail.imageURL, !url.isEmpty {
            imageList = [PlaceImage(contentId: detail.contentId, originImageURL: url, imageName: nil, smallImageURL: nil)]
        }
        if !imageList.isEmpty {
            sections.append(.init(section: .imageCarousel, items: imageList.map { .image($0) }))
        }

        // 헤더
        sections.append(.init(section: .header, items: [.header(makeHeader(detail: detail, info: festivalInfo))]))

        // 행사 정보
        let infoRows = makeInfoRows(festivalInfo)
        if !infoRows.isEmpty {
            sections.append(.init(section: .info, items: infoRows.map { .infoRow($0) }))
        }

        // 소개
        if let overview = detail.overview?.decodedHTML {
            sections.append(.init(section: .description, items: [.description(overview)]))
        }

        // 프로그램
        let programRows = makeProgramRows(festivalInfo)
        if !programRows.isEmpty {
            sections.append(.init(section: .program, items: programRows.map { .infoRow($0) }))
        }

        // 문의 · 링크
        let contactRows = makeContactRows(festivalInfo)
        if !contactRows.isEmpty {
            sections.append(.init(section: .contact, items: contactRows.map { .infoRow($0) }))
        }

        // 위치
        if detail.mapX != nil, detail.mapY != nil {
            sections.append(.init(section: .location, items: [.location(detail)]))
        }

        return sections
    }

    func makeHeader(detail: Place, info: FestivalSpecificInfo?) -> FestivalHeaderInfo {
        // 날짜는 상세 정보 우선, 없으면 목록에서 넘어온 eventMeta 사용
        let start = info?.eventstartdate?.nonEmpty ?? place.eventMeta?.eventStartDate
        let end = info?.eventenddate?.nonEmpty ?? place.eventMeta?.eventEndDate

        var period: String?
        if let start, let end {
            period = DateFormatterUtil.formatPeriodWithYear(start: start, end: end)
        } else if let start {
            period = DateFormatterUtil.formatShortDisplayDate(from: start) ?? start
        }

        let placeText = info?.eventplace?.decodedHTML ?? detail.address.nonEmpty

        return FestivalHeaderInfo(
            contentId: detail.contentId,
            title: detail.title,
            period: period,
            place: placeText,
            status: makeStatus(start: start, end: end)
        )
    }

    func makeStatus(start: String?, end: String?) -> FestivalStatus? {
        guard let start, let end,
              let startDate = DateFormatterUtil.yyyyMMdd.date(from: start),
              let endDate = DateFormatterUtil.yyyyMMdd.date(from: end) else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if today < calendar.startOfDay(for: startDate) {
            let days = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: startDate)).day ?? 0
            return .upcoming(daysLeft: days)
        }
        if today <= calendar.startOfDay(for: endDate) {
            return .ongoing
        }
        return .ended
    }

    func makeInfoRows(_ info: FestivalSpecificInfo?) -> [FestivalInfoRow] {
        guard let info else { return [] }
        return [
            row("playTime", "clock", Keys.playTime, info.playtime),
            row("fee", "wonsign.circle", Keys.fee, info.usetimefestival),
            row("discount", "tag", Keys.discount, info.discountinfofestival),
            row("ageLimit", "person.2", Keys.ageLimit, info.agelimit),
            row("duration", "hourglass", Keys.duration, info.spendtimefestival),
            row("placeInfo", "mappin.and.ellipse", Keys.placeInfo, info.placeinfo)
        ].compactMap { $0 }
    }

    func makeProgramRows(_ info: FestivalSpecificInfo?) -> [FestivalInfoRow] {
        guard let info else { return [] }
        return [
            row("program", "list.bullet.rectangle", Keys.program, info.program),
            row("subEvent", "sparkles", Keys.subEvent, info.subevent)
        ].compactMap { $0 }
    }

    func makeContactRows(_ info: FestivalSpecificInfo?) -> [FestivalInfoRow] {
        guard let info else { return [] }

        var rows: [FestivalInfoRow?] = []

        rows.append(contactRow("host", Keys.host, name: info.sponsor1, tel: info.sponsor1tel))
        rows.append(contactRow("organizer", Keys.organizer, name: info.sponsor2, tel: info.sponsor2tel))

        if let homepage = info.eventhomepage?.decodedHTML {
            let url = info.eventhomepage?.extractedURL.flatMap(webURL(from:))
            rows.append(FestivalInfoRow(
                id: "homepage", symbol: "safari", title: Keys.homepage.localized,
                content: url?.absoluteString ?? homepage,
                action: url.map { .openURL($0) }
            ))
        }

        if let booking = info.bookingplace?.decodedHTML {
            let url = info.bookingplace?.extractedURL.flatMap(webURL(from:))
            rows.append(FestivalInfoRow(
                id: "booking", symbol: "ticket", title: Keys.booking.localized,
                content: booking,
                action: url.map { .openURL($0) }
            ))
        }

        return rows.compactMap { $0 }
    }

    /// 문자열을 열 수 있는 웹 URL로 변환 (스킴이 없으면 http:// 보정)
    func webURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmed.lowercased().hasPrefix("http") ? trimmed : "http://" + trimmed
        guard let url = URL(string: candidate), let host = url.host, host.contains(".") else { return nil }
        return url
    }

    // MARK: Row Helpers
    func row(_ id: String, _ symbol: String, _ titleKey: String, _ value: String?) -> FestivalInfoRow? {
        guard let content = value?.decodedHTML?.withBulletLineBreaks else { return nil }
        return FestivalInfoRow(id: id, symbol: symbol, title: titleKey.localized, content: content, action: nil)
    }

    func contactRow(_ id: String, _ titleKey: String, name: String?, tel: String?) -> FestivalInfoRow? {
        let name = name?.decodedHTML
        let phone = tel?.extractedPhoneNumber
        guard name != nil || phone != nil else { return nil }

        let content = [name, phone].compactMap { $0 }.joined(separator: " · ")
        return FestivalInfoRow(
            id: id,
            symbol: phone != nil ? "phone" : "building.2",
            title: titleKey.localized,
            content: content,
            action: phone.map { .call($0) }
        )
    }
}

// MARK: - String Helpers
private extension String {

    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// 태그 없이 이어 붙은 항목을 줄바꿈 (예: "70,000원- R석 60,000원※ 변경 가능" → 각 항목 별도 줄)
    /// 전화번호/날짜의 하이픈은 건드리지 않도록 "- "(하이픈+공백)이 글자 바로 뒤에 올 때만 분리
    var withBulletLineBreaks: String {
        self
            .replacingOccurrences(of: "([^\\s])[ \\t]*(※)", with: "$1\n$2", options: .regularExpression)
            .replacingOccurrences(of: "([^\\s])(- )", with: "$1\n$2", options: .regularExpression)
    }

    /// 첫 번째 전화번호만 추출 (예: "02-123-4567 / 02-765-4321" → "02-123-4567")
    var extractedPhoneNumber: String? {
        guard let range = range(of: "[0-9+][0-9\\-]{6,}", options: .regularExpression) else { return nil }
        return String(self[range])
    }
}
