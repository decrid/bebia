# Bebia

Bebia je česká Flutter aplikace pro přehled každodenní péče o malé dítě.
Pomáhá rodičům rychle zaznamenat krmení, spánek, přebalování a pláč, sledovat
časovou osu a statistiky a podle potřeby sdílet péči v rodině.

## Funkce

- profily dětí a rychlé přepínání aktivního profilu,
- záznam a editace krmení, spánku, přebalování a pláče,
- časová osa s filtry a bezpečným mazáním,
- statistiky, doporučení a predikce z existujících záznamů,
- volitelná lokální analýza pláče pomocí TFLite/MediaPipe,
- volitelný účet a Firebase rodinná synchronizace,
- systémový, světlý a tmavý vzhled,
- komfortní nebo kompaktní hustota, omezení animací a haptika,
- adaptivní navigace pro telefon i širší displej.

## Architektura

- `lib/core` – služby, Firebase bootstrap, design systém a preference,
- `lib/data` – Isar repository, lokální stores a volitelné Firestore adaptery,
- `lib/features` – obrazovky, feature controllery, modely a doménové služby,
- `lib/shared/widgets` – shell a sdílené Bebia komponenty,
- `test` – preference, theme, navigace a rizikové responzivní scénáře.

Timeline je offline-first v Isar Community. Profily, onboarding, přiřazení a
rodinné spojení používají stávající oddělené lokální stores. UI preference jsou
uložené samostatně v `bebia_preferences.json`; reset preferencí nemaže profily
ani události. Databázové schéma ani application id rebuild nemění.

## Design systém

Vizuální tokeny jsou v `lib/core/design/bebia_theme.dart`, sdílené komponenty v
`lib/shared/widgets/bebia_components.dart`. Pravidla identity, barev,
typografie, responsivity a budoucích obrazovek popisuje
[`docs/design_system.md`](docs/design_system.md).

## Dokumentace

- [Statický audit a rebuild](docs/rebuild_audit.md)
- [Design systém](docs/design_system.md)
- [Release smoke checklist](docs/release_smoke_checklist.md)
- [Android release a podepisování](docs/android_release.md)
- [Technický privacy popis](PRIVACY.md)
- [Bezpečnostní hlášení](SECURITY.md)
- [Rodinná synchronizace](docs/family_sync_architecture.md)
- [Firebase setup](docs/firebase_family_sync_setup.md)

Kontrolu formátu, analýzu, testy a debug APK provádí také workflow
`.github/workflows/flutter-quality.yml` pro pull requesty a změny na `main`.

## Android release signing

Release build nepoužívá debug klíč. Pro lokální podepsaný release:

1. vytvořte nebo bezpečně získejte existující upload keystore,
2. uložte jej mimo Git, typicky jako `android/app/upload-keystore.jks`,
3. zkopírujte `android/key.properties.example` na
   `android/key.properties`,
4. nahraďte ukázkové hodnoty skutečnou cestou, aliasem a hesly,
5. před buildem ověřte, že keystore ani `key.properties` nejsou sledované.

Bez úplného `key.properties` release zůstane nepodepsaný; nikdy se tiše
nepodepíše debug identitou. Podrobnosti a blokátor `com.example.bebia` jsou v
[Android release dokumentaci](docs/android_release.md).

## Licence

Projekt zatím neobsahuje licenční soubor ani doložené rozhodnutí vlastníka o
typu licence. Veřejná dostupnost repozitáře sama o sobě neuděluje právo software
kopírovat, upravovat nebo distribuovat. Volba MIT, Apache-2.0, GPL nebo jiné
licence zůstává blokujícím produktovým rozhodnutím vlastníka; žádná licence
nebyla v rámci technického auditu domyšlena.

## Ruční ověření

Na výslovný požadavek nejsou validační příkazy spouštěné automaticky. Po změně
zdrojů spusťte v kořeni projektu:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Poté proveďte smoke test na malém telefonu, s 2× systémovým textem, otevřenou
klávesnicí, v obou motivech a nad kopií existujících uživatelských dat. Release
build vyžaduje soukromou signing konfiguraci popsanou v Android release
dokumentaci.
