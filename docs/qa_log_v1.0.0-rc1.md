# QA Log - v1.0.0-rc1

- Version: `v1.0.0`
- Build: `1.0.0+1`
- Date: `2026-04-08`
- Tester: `TBD`
- Device: `TBD`
- Android version: `TBD`

## 1) Build And Static Checks

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build apk --debug` (or RC variant)

## 2) First Launch And Basic Navigation

- [ ] Clean install launches without crash
- [ ] Home opens
- [ ] Timeline opens
- [ ] Add opens
- [ ] Statistics opens
- [ ] Recommendations opens
- [ ] Pull-to-refresh works on Home
- [ ] Pull-to-refresh works on Recommendations

## 3) Core Event Flows

- [ ] Create/edit/delete feeding
- [ ] Create/edit/delete sleep
- [ ] Create/edit/delete diaper
- [ ] Create/edit/delete crying
- [ ] Data remains after app restart

## 4) Crying AI Flow (Critical)

- [ ] AI analysis runs in crying form
- [ ] AI summary shows cause/confidence/signals
- [ ] Home card shows next action
- [ ] `Provést krok` opens correct flow
- [ ] Timeline crying row shows AI context + `Další krok`

## 5) Recommendations And Predictions

- [ ] Screen loads predictions block
- [ ] Screen loads recommendations block
- [ ] Empty state renders correctly (when applicable)
- [ ] Priority/time-window labels render correctly
- [ ] No overflow on common phone width

## 6) Data Consistency

- [ ] Edit historical event updates Home/Timeline/Recommendations
- [ ] Delete event updates dependent recommendations/predictions
- [ ] Optional fields (duration/note/audio) do not crash UI

## 7) UX And Language

- [ ] Czech text is readable (no mojibake)
- [ ] Loading states are understandable
- [ ] Empty states are understandable
- [ ] Error states are understandable

## 8) Result

- Overall: `PASS / PASS WITH NOTES / BLOCKED`
- Blocking issues:
- Non-blocking notes:
