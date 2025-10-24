//
//  HTMLParser.swift
//  KoreaSpots
//
//  Created by YoungJin on 10/23/25.
//

import Foundation

/// HTML 태그 및 특수 문자를 파싱하는 유틸리티
/// JSONDecoder는 유니코드 이스케이프(\u003c)를 자동 변환하므로 HTML 태그 처리만 수행
enum HTMLParser {

    /// HTML 문자열을 일반 텍스트로 변환
    /// - HTML 태그 제거 (<a href="...">text</a> → text)
    /// - <br> 태그를 줄바꿈으로 변환
    /// - URL만 추출하는 옵션
    static func decode(_ html: String?, extractURLOnly: Bool = false) -> String? {
        guard let html = html, !html.isEmpty else { return nil }

        var result = html

        // 1. <br> 태그를 줄바꿈으로 변환
        result = result.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        result = result.replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive)

        // 2. URL 추출 모드
        if extractURLOnly {
            if let url = extractURL(from: result) {
                return url
            }
        }

        // 3. HTML 태그 제거 (링크 텍스트만 남김)
        result = stripHTMLTags(result)

        // 4. HTML 엔티티 디코딩 (&nbsp; → 공백 등)
        result = decodeHTMLEntities(result)

        // 5. 여러 공백/줄바꿈 정리
        result = cleanupWhitespace(result)

        return result.isEmpty ? nil : result
    }

    /// HTML 태그에서 URL 추출
    private static func extractURL(from html: String) -> String? {
        // <a href="URL">...</a> 패턴에서 URL 추출
        // href="URL" 또는 href='URL' (대소문자 무시)
        let hrefPattern = /(?i)href\s*=\s*"([^"]+)"/
        if let match = html.firstMatch(of: hrefPattern) {
            return String(match.1)
        }

        let hrefSingleQuotePattern = /(?i)href\s*=\s*'([^']+)'/
        if let match = html.firstMatch(of: hrefSingleQuotePattern) {
            return String(match.1)
        }

        // href 속성이 없으면 URL 패턴 직접 추출
        let urlPattern = /https?:\/\/[^\s<>"'\)]+/
        if let match = html.firstMatch(of: urlPattern) {
            return String(match.0)
        }

        return nil
    }

    /// HTML 태그 제거 (링크 텍스트는 유지)
    private static func stripHTMLTags(_ html: String) -> String {
        var result = html

        // <a>태그의 경우 텍스트 내용만 추출
        // <a href="url">text</a> → text (대소문자 무시)
        let linkPattern = /(?i)<a[^>]*>([^<]*)<\/a>/
        result = result.replacing(linkPattern) { match in
            String(match.1)
        }

        // 나머지 모든 HTML 태그 제거
        let tagPattern = /<[^>]+>/
        result = result.replacing(tagPattern) { _ in "" }

        return result
    }

    /// HTML 엔티티 디코딩 (&nbsp; → 공백 등)
    private static func decodeHTMLEntities(_ text: String) -> String {
        var result = text

        // 기본 HTML 엔티티만 처리 (가장 흔한 것들)
        let entities: [String: String] = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&apos;": "'"
        ]

        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }

        return result
    }

    /// 여러 공백/줄바꿈 정리
    private static func cleanupWhitespace(_ text: String) -> String {
        var result = text

        // 연속된 공백을 하나로 (단, 줄바꿈은 유지)
        result = result.replacing(/[ \t]+/) { _ in " " }

        // 3개 이상의 연속된 줄바꿈을 2개로
        result = result.replacing(/\n{3,}/) { _ in "\n\n" }

        // 앞뒤 공백 제거
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }
}

// MARK: - String Extension

extension String {
    /// HTML 디코딩된 문자열 반환
    var decodedHTML: String? {
        return HTMLParser.decode(self)
    }

    /// HTML에서 URL만 추출
    var extractedURL: String? {
        return HTMLParser.decode(self, extractURLOnly: true)
    }
}
