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
- [ ] `Zapsat` opens as the first tab
- [ ] `Zapsat` shows Krmení, Spánek, Přebalení and Pláč
- [ ] `Zapsat` does not show Pulse dne, Rodinné sdílení or a global FAB
- [ ] Přehled opens and keeps quick add available
- [ ] Statistiky opens and keeps quick add available
- [ ] Nastavení opens
- [ ] Rodinné sdílení opens from the child profile flow
- [ ] Pull-to-refresh works on Zapsat
- [ ] Pull-to-refresh works on Recommendations

## 3) Core Event Flows

- [ ] Create/edit/delete feeding
- [ ] Create/edit/delete sleep
- [ ] Create/edit/delete diaper
- [ ] Create/edit/delete crying
- [ ] Future event time is rejected in all four forms
- [ ] Failed save keeps the form open and re-enables the save button
- [ ] Data remains after app restart

## 4) Crying AI Flow (Critical)

- [ ] AI analysis runs in crying form
- [ ] AI summary shows cause/confidence/signals
- [ ] Zapsat does not show an AI dashboard card
- [ ] Timeline crying row shows AI context + `Další krok`
- [ ] Real model result is verified on Android before claiming production AI detection

## 5) Recommendations And Predictions

- [ ] Screen loads predictions block
- [ ] Screen loads recommendations block
- [ ] Empty state renders correctly (when applicable)
- [ ] Priority/time-window labels render correctly
- [ ] No overflow on common phone width

## 6) Data Consistency

- [ ] Edit historical event updates Zapsat/Timeline/Recommendations
- [ ] Delete event updates dependent recommendations/predictions
- [ ] Failed delete leaves the timeline item visible and shows a Czech error
- [ ] Optional fields (duration/note/audio) do not crash UI
- [ ] Legacy single child profile keeps the same migrated id after restart
- [ ] Historical unassigned events are visible under the migrated profile once

## 7) Android Widgets And Deep Links

- [ ] Widget picker shows Bebia widget previews, not only the launcher icon
- [ ] Widget empty state renders before first event
- [ ] Widget actions open only known `bebia://timeline/*` and `bebia://add/*` targets
- [ ] Widget snapshot refreshes after add, edit, delete and active profile change
- [ ] Restart phone and verify BOOT_COMPLETED redraws the saved snapshot
- [ ] Unsupported deep links are ignored safely

## 8) UX And Language

- [ ] Czech text is readable (no mojibake)
- [ ] Loading states are understandable
- [ ] Empty states are understandable
- [ ] Error states are understandable

## 9) Result

- Overall: `PASS / PASS WITH NOTES / BLOCKED`
- Blocking issues:
- Non-blocking notes:
