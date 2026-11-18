---
name: smoke-check
description: Run the app in the simulator via XcodeBuildMCP and screenshot key screens to confirm a refactor did not break them.
---

1. `session_show_defaults` first; set project `KoreaSpots.xcodeproj`, scheme `KoreaSpots`, an available iPhone simulator if missing.
2. `build_run_sim`, then use `snapshot_ui` / `screenshot` per screen. Check each renders and basic interaction works:
   - Home (festival carousel, nearby places), Category -> PlaceList (scroll/pagination), Search (recent keywords), PlaceDetail, Favorite, TripRecord (calendar), TripEditor (open/close), TripDetail.
3. Only check screens related to the changed files unless asked for a full pass.
4. Report in Korean: per screen OK / problem (+ screenshot reference). Stop on first crash and include the log line.
Note: without an API key or network the app uses mock fallback; that is expected.
