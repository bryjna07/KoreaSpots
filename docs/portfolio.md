# 포트폴리오 정리 - 어디로 (KoreaSpots)

> 이력서/README/면접용 원재료. "(예정)" 표시는 아직 구현 전이므로 완료로 쓰지 말 것.
> 근거 문서: `architecture.md`, `architecture-decisions.md`, `code-review-opus.md`, `claude-workflow.md`.

## 한 줄 소개
한국관광공사 Tour API 기반으로 관광지·축제를 찾고 여행을 기록하는 iOS 앱. App Store 출시(v1.1.1), 1인 개발.

## 기술 스택과 선택 이유
| 영역 | 선택 | 이유 (면접 답변 포인트) |
|---|---|---|
| UI | UIKit(코드 기반) + SnapKit/Then | 복잡한 컬렉션 레이아웃(고정 헤더, 사이드바+그리드)을 세밀하게 제어 |
| 리스트 | Diffable DataSource, CellRegistration, Compositional Layout | 인덱스 계산 없이 스냅샷으로 상태를 표현, 크래시(불일치 업데이트) 방지 |
| 상태 관리 | ReactorKit (RxSwift) | Action → Mutation → State 단방향 흐름. 화면 상태가 한 곳(State)에 모여 디버깅과 테스트가 쉬움 |
| 네트워크 | Moya | API 명세를 enum(TargetType)으로 한 파일에 모음, 플러그인으로 로깅 |
| 저장소 | Realm | 즐겨찾기·여행기록·API 캐시. 스키마 마이그레이션 지원 |
| 아키텍처 | Clean Architecture 계층 + 수동 DI 컨테이너 | Presentation → Domain ← Data. 의존성 역전으로 Data 교체/목킹이 쉬움 |

## 아키텍처 (말로 설명하는 버전)
- 계층: `Presentation`(VC/View/Reactor) → `Domain`(Entity, UseCase, Repository 프로토콜) ← `Data`(RepositoryImpl, DataSource, DTO, Mapper).
- 모든 경계는 `프로토콜 + Impl`. `AppContainer`가 DataSource → Repository → UseCase → Reactor 순서로 생성자 주입.
- 화면 이동은 `Navigator` 프로토콜 기본 구현 + `AppContainer.makeXxxViewController()` 팩토리.

## 핵심 구현 포인트
1. **장애 대응(Graceful degradation)**: API 한도 초과/서버 오류 시 번들 예시 데이터로 전환(`DataSourceMode`). 예시 데이터임을 표시(`[예시]`)하고 쓰기 작업을 막아 가짜 데이터가 저장되지 않게 함.
2. **외부 API 개편 대응**: 2026 Tour API 분류체계 변경(cat → lclsSystm, 지역코드 → 법정동). 분류표를 Swift enum에서 JSON 데이터로 바꿔, 다음 개편 때는 코드 수정 없이 JSON만 교체.
3. **출시 앱의 안전한 DB 마이그레이션**: 미출시 스키마 변경 여러 개를 v3 하나로 통합. 1.1.1 → 신버전 실기기 업그레이드 테스트 통과.
4. **Realm 스레드 규칙 준수**: 백그라운드에서 작업마다 Realm 인스턴스를 새로 만들고, 도메인 struct로 변환한 뒤 UI로 전달.
5. **캐시 정책**: API 권장사항(1일 1회 갱신)에 맞춘 오전 4시(KST) 기준 갱신 + `modifiedtime` 기반 변경 감지.
6. **iPhone Duo(대화면 폴더블) 대응**: Apple HIG 확인 → 정규 너비에서 떠 있는 탭바가 콘텐츠를 가리는 문제를 safe area 기준 레이아웃으로 수정.

## 리팩터링/개선 스토리 (STAR로 말하기 좋음)
- **God Repository 분리**: 관광 데이터와 사용자 데이터(최근 검색어)가 한 Repository에 섞여 있음 → 책임별로 분리(SRP/ISP). 컴파일러가 모든 호출처를 찾아줌.
- **파일 분리 기준 세우기**: 줄 수가 아니라 "책임이 섞였는가"로 판단. 처음에 과하게 분리한 2건을 스스로 되돌린 경험 포함.
- **날짜 포맷 버그**: 기기 달력을 불교력/일본력으로 바꾸면 API에 `2569…`년이 전송됨을 스크립트로 재현 → Apple 문서대로 API용 포매터는 `en_US_POSIX` + 그레고리력 고정, 화면 표시용은 그레고리력만 고정(로케일은 유지). 타임존은 해외 사용자 날짜 밀림 위험 때문에 일부러 건드리지 않음.
- **메모리 누수**: ReactorKit `transform`에서 `self` 강한 캡처로 생긴 순환 참조. `leaks`는 0건으로 보고했지만, Memory Graph(`heap`) 인스턴스 수로 화면을 닫은 뒤에도 `SearchReactor` 3개가 남고 `SearchViewController`는 0개인 것을 확인 → `[weak self]`로 수정(검색, 장소 목록). (수정 후 Memory Graph 재확인·스크린샷은 남기는 중)
- **장애 모드 복구 (서킷 브레이커 half-open)**: 일시적 서버 오류 한 번으로 세션 내내 예시 데이터 모드가 유지되던 문제. 예시 데이터 모드에서도 5분마다 또는 포그라운드 복귀 시 요청 1건만 실제 API로 보내고, 응답 디코딩까지 성공하면 정상 모드로 복귀. 알림은 모든 화면(BaseViewController)이 아니라 SceneDelegate 한 곳에서 최상단 화면에 표시하도록 정리. (서버 복구 상황 재현은 아직)
- **캐시 오적중 버그**: 목록·상세 데이터가 Realm 한 행과 하나의 `cachedAt`을 공유해서, 목록에서 본 장소의 상세 화면이 API 호출 없이 개요가 빠진 채로 표시됨. 화면은 다른 API(운영정보)로 채워져 정상처럼 보였지만 로그(`Detail Cache Hit`)와 섹션 구성 코드를 대조해 확인 → "상세를 받아온 적 있는 행"만 캐시로 인정. 시뮬레이터 전/후 스크린샷 확보. 같은 원인으로 즐겨찾기 추가가 상세 정보를 덮어쓰던 문제, 주변 장소 캐시에 축제가 섞이던 문제(타입·개수 확인)도 수정.
- **캐시 설계 트레이드오프**: 주변 장소 캐시를 정확하게 만들자 장소가 적은 지역에선 매번 API를 호출하게 됨(서울시청 기준 홈 진입당 3회). 근본 해결(요청 단위 캐시 키)은 Realm 마이그레이션이 필요해 2.0.0 이후로 미룸 → "정확성 우선, 비용은 측정 후 개선".
- **Auto Layout 모호성**: 상세 화면 태그가 스크롤 후 찌그러짐. 제목과 태그의 압축 저항 우선순위가 같아(750) 셀 재사용 시점마다 결과가 달라졌음 → Content Compression Resistance / Hugging 우선순위 지정.
- **DisposeBag 누적**: 앱 수명 동안 살아있는 Repository의 DisposeBag에 일회성 캐시 저장 구독이 계속 쌓이던 문제 → 끝나는 스트림(Completable)은 bag 없이 구독하고 실패를 로그로 남김.
- **API 키 로그 노출 차단**: 릴리스 빌드에서 네트워크 로거가 키가 포함된 URL을 출력 → `#if DEBUG`로 디버그 빌드에서만 로거 추가(Release 빌드 확인).

## 면접 예상 질문과 답변 키워드
- ReactorKit을 고른 이유, MVVM과 차이 → 단방향 흐름, State 단일화, `mutate`/`reduce` 분리로 부수효과 위치가 명확.
- `transform(mutation:)`은 언제 쓰나 → 외부 스트림(Realm 변경, 즐겨찾기 상태)을 Mutation에 합칠 때. 순환 참조 주의.
- Diffable DataSource 장점 → 스냅샷 기반, `performBatchUpdates` 불일치 크래시 제거, Hashable 식별자.
- Realm 스레드 문제 → 인스턴스/객체는 스레드에 묶임. 스레드 넘길 땐 struct 변환 또는 ThreadSafeReference.
- 마이그레이션 전략 → 출시된 스키마만 단계 유지, 미출시 변경은 통합.
- 테스트가 없는데 리팩터링은 어떻게 → 동작 보존 이동만, 커밋 1개 = 변경 1개, 빌드 + 줄 단위 diff 검증(전용 리뷰 에이전트).
- 의존성 주입을 라이브러리 없이 한 이유 → 규모상 수동 컨테이너로 충분, 의존 그래프가 코드에 그대로 보임.

## AI 활용 개발 워크플로우 (AI 에이전트 직무 어필)
- Claude Code에 프로젝트 규칙(CLAUDE.md), 전용 서브에이전트(`build-verifier`, `refactor-reviewer`), 스킬(파일 분리, 주석, 스모크 체크)을 구성.
- 토큰 사용량을 측정하고(세션/모델별) 컨텍스트 저장·재개 방식으로 비용을 관리. 상세: `claude-workflow.md`.
- 모델 비교(Sonnet vs Opus) 결과는 측정 후 추가 예정.

## 앞으로 (로드맵 요약)
2.0.0(카테고리 개선, UI 다듬기, 로고) → 다국어 → AI 챗봇(장소 추천, 백엔드 프록시로 키 보호, Tour API 툴 호출) → 테스트(Reactor/UseCase).
