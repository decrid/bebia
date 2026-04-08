# Release Smoke Checklist

Use this checklist before each release candidate build.

## 1) Build And Static Checks

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug` (or release candidate build variant)

## 2) First Launch And Basic Navigation

- App launches without crash on clean install.
- Home, Timeline, Add, Statistics, Recommendations screens open correctly.
- Pull-to-refresh works on Home and Recommendations.

## 3) Core Event Flows

- Create, edit, and delete `feeding` event.
- Create, edit, and delete `sleep` event.
- Create, edit, and delete `diaper` event.
- Create, edit, and delete `crying` event.
- Events are visible in Timeline and survive app restart.

## 4) Crying AI Flow (Critical)

- In crying form: AI analysis can be triggered and returns result.
- AI summary shows probable cause, confidence, and signals.
- AI next-step action is shown and works from Home (`Provést krok`).
- Timeline crying entries show AI cause and `Další krok` label.

## 5) Recommendations And Predictions

- Recommendations screen loads both prediction and recommendation blocks.
- Empty-state copy is shown when no data exists.
- Priority labels and time-window labels are rendered correctly.
- No visual overflow on common mobile widths.

## 6) Data Consistency

- Editing a historical event updates Home, Timeline, and Recommendations consistently.
- Deleting events updates dependent recommendations/predictions.
- App handles missing optional fields (duration, note, audio path) without crashes.

## 7) UX And Language

- Czech text is readable and consistent (no mojibake characters).
- Loading, empty, and error states are understandable.
- UI remains calm and scannable (no overly dense blocks).

## 8) Final Sign-Off

- Test on at least one real Android device.
- Verify cold start + background/foreground resume.
- Capture release notes summary (what changed + known limitations).

## Optional Quick Regression Script

1. Add one event of each type.
2. Trigger crying AI from form.
3. Confirm Home AI card and next-step action.
4. Open Timeline and verify new entries and AI context.
5. Open Recommendations and verify both sections.
6. Edit one event and delete one event.
7. Re-check Home, Timeline, Recommendations after refresh.
