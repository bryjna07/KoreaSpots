#!/usr/bin/env python3
"""옛 지역 코드(areaCode/sigunguCode)를 새 법정동 코드(lDongRegnCd/lDongSignguCd)로 잇는 변환표를 만든다.

사용법 (오프라인, API 호출 없음):
    python3 scripts/build_legacy_region_map.py

입력:  scripts/legacy_sigungu_codes.json (옛 코드표, 앱 번들에서 제외됨), KoreaSpots/Resources/ldong_codes.json (새 코드표)
출력:  KoreaSpots/Resources/legacy_region_map.json
    {"<옛 areaCode>": {"regn": <새 시도코드>, "sigungu": {"<옛 sigunguCode>": <새 시군구코드>}}}

시도는 고정 매핑이고, 시군구는 같은 시도 안에서 이름이 일치하는 경우만 연결한다.
(예: 인천 옛 서구는 서해구/검단구로 분리되어 연결하지 않음 -> 사용 시 시군구만 nil)
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

# 옛 areaCode -> 새 lDongRegnCd (광주 5, 전남 38은 전남광주통합특별시 12로 통합)
AREA_TO_REGN: dict[str, int] = {
    "1": 11, "2": 28, "3": 30, "4": 27, "5": 12, "6": 26, "7": 31, "8": 36110,
    "31": 41, "32": 51, "33": 43, "34": 44, "35": 47, "36": 48, "37": 52, "38": 12, "39": 50,
}


def build(old: dict[str, dict[str, dict[str, str]]], new: dict[str, dict[str, dict[str, str]]]):
    result: dict[str, dict] = {}
    unmatched: list[str] = []
    for area, regn in AREA_TO_REGN.items():
        new_sigungu = new.get(str(regn), {})
        by_name = {v["ko"]: int(code) for code, v in new_sigungu.items()}
        old_sigungu = old.get(area, {})
        mapping: dict[str, int] = {}
        for old_code, rec in old_sigungu.items():
            name = rec["ko"]
            if name in by_name:
                mapping[old_code] = by_name[name]
            elif len(old_sigungu) == 1 and len(new_sigungu) == 1:
                # 세종: 시도와 시군구가 하나씩이라 이름이 달라도 연결
                mapping[old_code] = int(next(iter(new_sigungu)))
            else:
                unmatched.append(f"area {area} sigungu {old_code} ({name})")
        result[area] = {"regn": regn, "sigungu": mapping}
    return result, unmatched


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--res-dir", type=Path, default=Path("KoreaSpots/Resources"))
    args = parser.parse_args()

    old = json.loads(Path("scripts/legacy_sigungu_codes.json").read_text(encoding="utf-8"))
    new = json.loads((args.res_dir / "ldong_codes.json").read_text(encoding="utf-8"))
    result, unmatched = build(old, new)

    out = args.res_dir / "legacy_region_map.json"
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    total = sum(len(v) for v in old.values())
    matched = sum(len(v["sigungu"]) for v in result.values())
    print(f"시군구 연결 {matched}/{total}, 미연결 {len(unmatched)}")
    for line in unmatched:
        print("  미연결:", line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
