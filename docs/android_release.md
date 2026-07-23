# Android release a podepisování

## Stav po hardeningu

- Release build už nikdy automaticky nepoužije debug klíč.
- Citlivé údaje se načítají pouze z lokálního `android/key.properties`.
- `android/key.properties`, `*.jks` a `*.keystore` v `android/app` jsou
  ignorované Gitem.
- Bez úplné konfigurace vznikne nepodepsaný release artefakt. To je záměrně
  bezpečnější než artefakt omylem podepsaný debug klíčem.
- CI sestavuje jen debug APK a nepotřebuje release tajemství.

## Lokální konfigurace upload klíče

1. Vygenerujte nebo bezpečně získejte upload keystore pro Google Play.
2. Uložte jej mimo Git, například jako `android/app/upload-keystore.jks`.
3. Zkopírujte `android/key.properties.example` na
   `android/key.properties`.
4. Nahraďte všechny ukázkové hodnoty skutečnými údaji.
5. Ověřte, že soubory nejsou mezi sledovanými změnami.
6. Sestavte release AAB a proveďte ověření podpisu podle procesu obchodu.

`storeFile` se vyhodnocuje relativně k `android/app`. Hesla nepatří do zdrojů,
dokumentace, CI logů ani screenshotů.

## Verze aplikace

Zdroj pravdy je `version` v `pubspec.yaml`. Flutter předává `versionName` a
`versionCode` do Android buildu a obrazovka Nastavení je načítá za běhu přes
platformní package metadata. Uživatelské UI proto neobsahuje ručně zapsanou
kopii verze.

## MediaPipe audio

Android dependency je připnutá na
`com.google.mediapipe:tasks-audio:0.10.35`. Dynamická verze
`latest.release` se nepoužívá, aby stejný commit sestavil reprodukovatelný
artefakt.

Použité API odpovídá oficiálnímu
[MediaPipe Audio Classifier guide pro Android](https://developers.google.com/edge/mediapipe/solutions/audio/audio_classifier/android);
konkrétní pin je nutné při upgradu ověřit proti Google Maven a reálnému
zařízení.

Při plánovaném upgradu:

1. změňte verzi v `android/app/build.gradle.kts`,
2. projděte release notes a kompatibilitu API `AudioClassifier`,
3. spusťte statickou analýzu, testy a debug build,
4. na reálném Android zařízení ověřte povolení i zamítnutí mikrofonu,
5. nahrajte, zastavte a zrušte audio a ověřte lokální klasifikaci,
6. změnu verze izolujte do samostatného review.

## Oprávnění mikrofonu

Manifest deklaruje `android.permission.RECORD_AUDIO`; mikrofon je volitelná
hardwarová schopnost, aby instalace nebyla omezena jen na zařízení s
mikrofonem. Formulář pláče žádá o oprávnění až při spuštění nahrávání. Zamítnutí
nezapne UI stav nahrávání a zobrazí postup pro povolení v nastavení aplikace.
Opuštění formuláře aktivní nahrávání zruší. Nativní MediaPipe klasifikace běží
na jednom background executor vlákně, výsledek se vrací na UI thread a
classifier se při zániku Activity zavře.

## Blokátor před publikací

`applicationId` a `namespace` zůstávají podle zadání beze změny:
`com.example.bebia`. Identifikátor s prefixem `com.example` není vhodný pro
produkční publikaci. Před prvním vydáním je nutné zvolit vlastněný stabilní
identifikátor, upravit Android package strukturu a znovu ověřit Firebase
konfiguraci, deep links, přihlášení a případné záznamy v obchodu. Po publikaci
už application id nelze u stejné aplikace změnit.

Bezpečný budoucí postup:

1. Nejdřív zjistěte, zda už existuje distribuovaný build se skutečnými daty.
   Pokud ano, application id neměňte bez samostatného export/import nebo jiného
   explicitně navrženého migračního mostu; Android by nový identifikátor
   považoval za jinou aplikaci.
2. Pokud aplikace ještě publikovaná není, vlastník zvolí unikátní reverse-DNS
   identifikátor pod doménou, kterou kontroluje.
3. V jednom izolovaném change setu upravte `applicationId`, `namespace`,
   package deklaraci a umístění `MainActivity`.
4. Pro nový identifikátor zaregistrujte Android aplikaci ve Firebase, dodejte
   odpovídající `google-services.json`, OAuth klienty a SHA fingerprints.
5. Zkontrolujte deep links, Android intent filtry, Google/Apple sign-in,
   Firestore rules a identifikátory v konfiguraci obchodu.
6. Ověřte čistou instalaci i upgrade/migrační scénář nad kopií dat. Teprve potom
   založte finální store listing; stejný identifikátor už následně neměňte.
