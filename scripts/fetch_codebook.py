#!/usr/bin/env python3
"""TourAPI 코드표(법정동, 분류체계)를 받아 앱 번들용 JSON으로 저장한다.

사용법 (API 키는 환경변수로만 전달, 출력하지 않음):
    TOUR_API_KEY=... uv run scripts/fetch_codebook.py [--out-dir KoreaSpots/Resources]

출력 (CodeBookStore 형식: 부모코드 -> 자식코드 -> {"ko": 이름}, 최상위는 "ROOT"):
    ldong_codes.json  ROOT=시도, 시도코드=시군구
    lcls_codes.json   ROOT=대분류, 대분류=중분류, 중분류=소분류
    codebook_meta.json  생성 시각, 출처, 건수 (CodeBookStore가 읽지 않는 별도 파일)
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

BASE_URL = "https://apis.data.go.kr/B551011/KorService2"
PAGE_SIZE = 1000
ROOT = "ROOT"

CodeTable = dict[str, dict[str, dict[str, str]]]


def fetch_all(operation: str, api_key: str, extra: dict[str, str]) -> list[dict[str, Any]]:
    """페이지를 순회하며 items 전체를 반환한다. 오류 시 URL(키 포함)은 출력하지 않는다."""
    items: list[dict[str, Any]] = []
    page = 1
    while True:
        query = urllib.parse.urlencode(
            {
                "serviceKey": api_key,
                "MobileOS": "IOS",
                "MobileApp": "KoreaSpots",
                "_type": "json",
                "numOfRows": PAGE_SIZE,
                "pageNo": page,
                **extra,
            }
        )
        data = _get_json(f"{BASE_URL}/{operation}?{query}", operation)
        response = data.get("response")
        if not response:
            # 게이트웨이 오류 형식 (예: SERVICE_KEY_IS_NOT_REGISTERED_ERROR)
            msg = data.get("OpenAPI_ServiceResponse", {}).get("cmmMsgHeader", {}).get("errMsg", "unknown")
            raise RuntimeError(f"{operation}: gateway error {msg}")
        header, body = response["header"], response["body"]
        if header["resultCode"] != "0000":
            raise RuntimeError(f"{operation}: {header['resultCode']} {header['resultMsg']}")
        chunk = (body.get("items") or {}).get("item") or []
        items.extend(chunk)
        if len(items) >= int(body.get("totalCount", 0)) or not chunk:
            return items
        page += 1


def _get_json(url: str, label: str, retries: int = 3) -> dict[str, Any]:
    for attempt in range(1, retries + 1):
        try:
            with urllib.request.urlopen(url, timeout=30) as res:
                return json.load(res)
        except urllib.error.HTTPError as e:
            # 403 등: 본문에 오류 메시지가 있을 수 있으나 URL은 숨긴다
            try:
                return json.load(e)
            except ValueError:
                raise RuntimeError(f"{label}: HTTP {e.code}") from None
        except (urllib.error.URLError, TimeoutError):
            if attempt == retries:
                raise RuntimeError(f"{label}: network error after {retries} tries") from None
            time.sleep(2 * attempt)
    raise AssertionError("unreachable")


def build_ldong(items: list[dict[str, Any]]) -> CodeTable:
    """lDongListYn=Y 응답 -> {ROOT: 시도, 시도코드: 시군구}."""
    table: CodeTable = {ROOT: {}}
    for i in items:
        sido, sido_name = str(i["lDongRegnCd"]), i["lDongRegnNm"]
        table[ROOT][sido] = {"ko": sido_name}
        sigungu = i.get("lDongSignguCd")
        if sigungu:
            table.setdefault(sido, {})[str(sigungu)] = {"ko": i["lDongSignguNm"]}
    return table


def build_lcls(items: list[dict[str, Any]]) -> CodeTable:
    """lclsSystmListYn=Y 응답 -> {ROOT: 대분류, 대분류: 중분류, 중분류: 소분류}."""
    table: CodeTable = {ROOT: {}}
    for i in items:
        c1, c2, c3 = i["lclsSystm1Cd"], i["lclsSystm2Cd"], i["lclsSystm3Cd"]
        table[ROOT][c1] = {"ko": i["lclsSystm1Nm"]}
        table.setdefault(c1, {})[c2] = {"ko": i["lclsSystm2Nm"]}
        table.setdefault(c2, {})[c3] = {"ko": i["lclsSystm3Nm"]}
    return table


def write_json(path: Path, obj: Any) -> None:
    """임시 파일에 쓴 뒤 교체해서 중간 실패 시 기존 파일을 보존한다."""
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    tmp.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--out-dir", type=Path, default=Path("KoreaSpots/Resources"))
    args = parser.parse_args()

    api_key = os.environ.get("TOUR_API_KEY")
    if not api_key:
        print("TOUR_API_KEY 환경변수가 필요합니다.", file=sys.stderr)
        return 2
    if not args.out_dir.is_dir():
        print(f"출력 폴더가 없습니다: {args.out_dir}", file=sys.stderr)
        return 2

    try:
        ldong = build_ldong(fetch_all("ldongCode2", api_key, {"lDongListYn": "Y"}))
        lcls = build_lcls(fetch_all("lclsSystmCode2", api_key, {"lclsSystmListYn": "Y"}))
    except RuntimeError as e:
        print(f"실패: {e}", file=sys.stderr)
        return 1

    level2 = [c2 for c1 in lcls[ROOT] for c2 in lcls.get(c1, {})]

    write_json(args.out_dir / "ldong_codes.json", ldong)
    write_json(args.out_dir / "lcls_codes.json", lcls)
    write_json(
        args.out_dir / "codebook_meta.json",
        {
            "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "source": f"{BASE_URL}/(ldongCode2, lclsSystmCode2)",
            "counts": {
                "sido": len(ldong[ROOT]),
                "sigungu": sum(len(v) for k, v in ldong.items() if k != ROOT),
                "lclsSystm1": len(lcls[ROOT]),
                "lclsSystm2": len(level2),
                "lclsSystm3": sum(len(lcls.get(c2, {})) for c2 in level2),
            },
        },
    )
    print(f"완료: 시도 {len(ldong[ROOT])}, 대분류 {len(lcls[ROOT])} -> {args.out_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
