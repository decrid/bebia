# Bebia Release Notes (Draft)

## Header

- Version: `v1.0.0`
- Build: `1.0.0+1`
- Date: `2026-04-08`
- Owner: `TBD`

## Summary

This release candidate finalizes the core parent flow across Home, Timeline, Crying AI, and Recommendations.  
The app now gives clearer AI crying context, recommends a concrete next step, and keeps the UI calmer and easier to scan.

## What's New

- Home: AI crying card now includes a recommended next action and direct action button (`Provést krok`).
- Timeline: Added daily summary card and clearer crying AI context, including `Další krok`.
- Crying AI: Analysis output now includes structured next-step metadata (type, title, description).
- Recommendations / Predictions: Unified into one practical assistant view (`what is next` + `what to do now`).
- Stability / performance: Completed final text/encoding cleanup and consistency pass across key screens.

## Improvements

- UX: Reduced visual overload with short, action-oriented cards and clearer hierarchy.
- Text / localization: Unified Czech copy and fixed mojibake/encoding artifacts in key flows.
- Data consistency: Home, Timeline, and Recommendations now present aligned AI guidance.

## Fixes

- Fixed: Unused element and related analyzer warning in crying form flow.
- Fixed: Multiple broken-encoding UI labels and separators on Home/Timeline/Recommendations.
- Fixed: Inconsistent wording between AI result, timeline context, and recommendation surfaces.

## Known Limitations

- Limitation: AI crying interpretation remains heuristic/context-first in this RC.
- Workaround: Treat AI result as guidance and validate via event context and caregiver judgment.

## QA Verification

- Smoke checklist completed: `pending`
- Device(s): `pending`
- Result: `pending`
- Notes: `pending`
- Detailed QA log: [docs/qa_log_v1.0.0-rc1.md](qa_log_v1.0.0-rc1.md)

## Rollout Plan

- Internal test: `TBD`
- Beta rollout: `TBD`
- Production rollout: `TBD`

## Rollback Plan

- Trigger condition: Critical regression in event save/edit/delete or AI flow navigation.
- Rollback action: Revert to previous stable tag/build and pause rollout.
- Owner: `TBD`
