# Tour API

- Base URL: `https://apis.data.go.kr`, path prefix `/B551011/KorService2/`
- Endpoints: `areaBasedList2`, `searchFestival2`, `locationBasedList2`, `searchKeyword2`, `detailCommon2`, `detailIntro2`, `detailImage2`, `detailInfo2`
- Code: `Core/Networking/API/TourAPI.swift`, `TourAPI+Builder.swift`, `Provider/MoyaProviderFactory.swift`

## API key flow (never print values)
`Resources/Config/Secrets/APIKey.xcconfig` (git-ignored, base config for Debug/Release) -> Info.plist key `APIKey` -> `Bundle.main.object(forInfoDictionaryKey:)` in `TourAPI`.

## Failure handling
Quota exceeded / server error -> `DataSourceMode.mockFallback` -> mock JSON in `Resources/Mock/`.

## Known gaps
- `FetchFestivalUseCase.swift:61` pageNo handling TODO.
- `TripLocalDataSourceImpl.swift:214` region code 0 handling TODO.
