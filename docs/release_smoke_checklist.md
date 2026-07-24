# Release Smoke Checklist

Use this checklist before each release candidate build.

## 1) Build And Static Checks

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- Pro release candidate: ověřit soukromý upload keystore a sestavit AAB podle
  `docs/android_release.md`; release nesmí používat debug podpis.

## 2) First Launch And Basic Navigation

- App launches without crash on clean install.
- First tab is `Zapsat`, not a dashboard.
- `Zapsat` shows Krmení, Spánek, Přebalení and Pláč.
- `Zapsat` does not show Pulse dne, Rodinné sdílení or a global FAB.
- Přehled, Statistiky, Nastavení and Recommendations screens open correctly.
- Quick add is available on Přehled and Statistiky.
- Rodinné sdílení remains reachable from the child profile flow.
- Pull-to-refresh works on Zapsat and Recommendations.

## 3) Core Event Flows

- Create, edit, and delete `feeding` event.
- Create, edit, and delete `sleep` event.
- Create, edit, and delete `diaper` event.
- Create, edit, and delete `crying` event.
- Future dates/times are rejected in all four forms.
- Failed event save keeps the form open and re-enables the save button.
- Events are visible in Timeline and survive app restart.

## 4) Crying AI Flow (Critical)

- Při prvním nahrávání se zobrazí systémová žádost o mikrofon.
- Zamítnuté oprávnění nezapne stav nahrávání a UI vysvětlí další postup.
- Spuštění, zastavení a odebrání audia odpovídá skutečnému stavu recorderu.
- Opuštění formuláře během nahrávání recorder bezpečně zruší.
- In crying form: AI analysis can be triggered and returns result.
- AI summary shows probable cause, confidence, and signals.
- AI next-step action is not shown on Zapsat; AI remains in the crying flow and timeline context.
- Timeline crying entries show AI cause and `Další krok` label.
- Real model output must be verified on Android before claiming production AI detection.

## 5) Recommendations And Predictions

- Recommendations screen loads both prediction and recommendation blocks.
- Empty-state copy is shown when no data exists.
- Priority labels and time-window labels are rendered correctly.
- No visual overflow on common mobile widths.

## 6) Data Consistency

- Editing a historical event updates Zapsat, Timeline, and Recommendations consistently.
- Deleting events updates dependent recommendations/predictions.
- Failed delete leaves the timeline item visible and shows a Czech error.
- App handles missing optional fields (duration, note, audio path) without crashes.

## 7) UX And Language

- Czech text is readable and consistent (no mojibake characters).
- Loading, empty, and error states are understandable.
- UI remains calm and scannable (no overly dense blocks).
- Zapsat, Timeline, Statistics, Settings, Family Sharing a všechny čtyři
  formuláře otestovat ve světlém i tmavém režimu.
- Zopakovat na šířce 320 px, s 2× systémovým textem a otevřenou klávesnicí.
- Timeline musí mít jeden společný vertikální scroll bez RenderFlex overflow.
- Všechny volby přebalení a krmení musí zůstat viditelné bez horizontálního
  přetečení.

## 8) Nastavení a upgrade

- Rychle změnit několik voleb nastavení za sebou a po restartu ověřit poslední
  hodnoty.
- Simulovat chybu zápisu: UI se vrátí na poslední potvrzený stav a ukáže chybu.
- Ověřit načtení starého souboru bez `version` a s `version: 0`.
- Budoucí neznámá verze musí zůstat beze změny a pouze pro čtení.
- Reset nastavení nesmí změnit profily, timeline ani rodinné propojení.
- Zobrazená verze v Nastavení musí odpovídat instalovanému balíčku.

## 9) Profily, Lokální JSON A Migrace

- Legacy single-profile JSON migrates to one stable child id.
- Second app start returns the same migrated child id.
- Historical unassigned events become visible under the migrated child once.
- After intentional profile deletion, unassigned events are not auto-assigned again.
- Simulated local JSON write failure preserves the previous valid file and recovery backup.

## 10) Android Widgets And Deep Links

- Widget picker shows static Bebia previews instead of only the launcher icon.
- Snapshot contains latest non-sensitive event details only.
- Add/edit/delete and active profile switch refresh the snapshot.
- `BOOT_COMPLETED` and `MY_PACKAGE_REPLACED` redraw the saved snapshot without opening Isar.
- `bebia://timeline`, `bebia://timeline/feeding`, `bebia://add/feeding`,
  `bebia://add/sleep`, `bebia://add/diaper` and `bebia://add/crying` work.
- Unknown sections or event types are ignored safely.
- Verify cold start, background/foreground resume and phone restart.

## 11) Final Sign-Off

- `applicationId` zůstává `com.example.bebia` v tomto průchodu; změna vyžaduje
  samostatné produktové rozhodnutí před veřejným vydáním.
- Ověřit verzi/build number proti `pubspec.yaml` a instalovanému balíčku.
- Ověřit produkční signing identitu; žádný debug klíč ani secret v repozitáři.
- Zkontrolovat aktuálnost `PRIVACY.md`, store privacy deklarací a oprávnění.
- Ověřit úspěšný GitHub Actions běh pro přesný commit release kandidáta.
- Potvrdit, že změna neobsahuje Isar ID/schema zásah bez samostatné migrace a
  testu nad kopií existujících dat.
- Test on at least one real Android device.
- Verify cold start + background/foreground resume.
- Capture release notes summary (what changed + known limitations).

## Optional Quick Regression Script

1. Add one event of each type.
2. Trigger crying AI from form.
3. Confirm Zapsat still shows only the four logging actions and optional last activity.
4. Open Timeline and verify new entries and AI context.
5. Open Recommendations and verify both sections.
6. Edit one event and delete one event.
7. Re-check Zapsat, Timeline, Recommendations after refresh.
