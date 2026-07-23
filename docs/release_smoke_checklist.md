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
- Home, Timeline, Add, Statistics, Recommendations screens open correctly.
- Pull-to-refresh works on Home and Recommendations.

## 3) Core Event Flows

- Create, edit, and delete `feeding` event.
- Create, edit, and delete `sleep` event.
- Create, edit, and delete `diaper` event.
- Create, edit, and delete `crying` event.
- Events are visible in Timeline and survive app restart.

## 4) Crying AI Flow (Critical)

- Při prvním nahrávání se zobrazí systémová žádost o mikrofon.
- Zamítnuté oprávnění nezapne stav nahrávání a UI vysvětlí další postup.
- Spuštění, zastavení a odebrání audia odpovídá skutečnému stavu recorderu.
- Opuštění formuláře během nahrávání recorder bezpečně zruší.
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
- Home, Timeline, Statistics, Settings, Family Sharing a všechny čtyři
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

## 9) Final Sign-Off

- `applicationId` nesmí být `com.example.bebia`; změna vyžaduje před prvním
  vydáním vlastní stabilní identifikátor a kontrolu Firebase návazností.
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
3. Confirm Home AI card and next-step action.
4. Open Timeline and verify new entries and AI context.
5. Open Recommendations and verify both sections.
6. Edit one event and delete one event.
7. Re-check Home, Timeline, Recommendations after refresh.
