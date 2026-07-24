# Statický audit a rebuild Bebia

Datum původní kontroly: 22. 7. 2026  
Datum následného hardeningu: 23. 7. 2026

> Audit byl proveden kontrolou zdrojových souborů. Na výslovný požadavek
> nebyly spuštěny Flutter, Dart, Git, Android ani jiné terminálové příkazy.
> Analýza, testy, generování a APK build proto čekají na ruční ověření.

## Účel a hlavní workflow

Bebia je česká mobilní aplikace pro rodiče novorozenců a malých dětí. Umožňuje
vést časovou osu krmení, spánku, přebalování a pláče, přepínat profily dětí,
sledovat souhrny a doporučení a volitelně sdílet péči v rodině. Pláč může být
doplněn lokální analýzou zvuku pomocí TFLite modelu. Firebase vrstva poskytuje
volitelné přihlášení a synchronizaci rodinného prostoru; lokální provoz a
stávající záznamy na ní nejsou závislé.

Veřejný repozitář nemá doloženou licenci. Typ licence vyžaduje rozhodnutí
vlastníka; samotná veřejnost zdrojů automaticky neuděluje právo k dalšímu
použití. Bezpečnostní hlášení popisuje `SECURITY.md` a skutečné datové toky
technicky shrnuje `PRIVACY.md`.

Nejčastější cesta je nyní: **Zapsat → typ události → formulář → uložení →
aktualizovaná časová osa**. První záložka není dashboard: neobsahuje `Pulse dne`
ani Rodinné sdílení, pouze čtyři přímé akce Krmení, Spánek, Přebalení a Pláč.
Historie a statistiky jsou samostatné hlavní sekce. Nastavení je čtvrtá hlavní
sekce a Rodinné sdílení zůstává dostupné přes profil dítěte.

## Původní technický stav

- Flutter/Material 3, ručně sestavené obrazovky a české texty přímo ve
  widgetech; projekt nemá generovanou lokalizaci.
- Stav je spravován jednoduchými controllery, `ChangeNotifier` a
  `ValueNotifier` přes statický `AppServices`. Pro současný rozsah je to
  srozumitelné, ale service locator komplikuje izolované widget testy.
- Timeline je uložena v Isar Community. Profily, přiřazení událostí, stav
  onboardingu a rodinného spojení používají samostatné lokální JSON stores s
  atomickým zápisem, recovery zálohou a izolací neplatných položek.
- Volitelná vzdálená vrstva používá Firebase Core, Auth, Firestore, Google a
  Apple sign-in. Audio používá `record`; inference `tflite_flutter`.
- Theme byl pouze světlý, s několika barvami odvozenými od pohlaví aktivního
  profilu. Karty, navigace, radiusy, mezery a animace neměly společný zdroj
  pravdy.
- Shell měl tři hlavní sekce, při přepnutí stav obrazovky nezachoval a rychlé
  přidání používalo vlastní pevně stylovaný sheet.
- Testovací vrstvu tvořil jediný minimální widget test; persistence, navigace,
  formuláře, chyba zápisu a responsivita pokryté nebyly.
- Největší prezentační soubory (`family_sharing_screen.dart`,
  `home_screen.dart`, `timeline_screen.dart`, `crying_form_screen.dart`) mají
  mnoho lokálních widgetů a odpovědností. Jde o hlavní budoucí riziko údržby.

## Seznam obrazovek a navigačních cest

### Hlavní sekce

1. `HomeScreen` – první záložka `Zapsat`, čtyři přímé akce pro Krmení, Spánek,
   Přebalení a Pláč, informace o aktivním profilu a volitelná poslední aktivita.
2. `TimelineScreen` – filtry, seznam událostí, editace a potvrzené mazání.
3. `StatisticsScreen` – souhrny a časové/statistické přehledy.
4. `SettingsScreen` – nový vzhled, hustota, omezení pohybu, haptika, soukromí,
   obnova preferencí a informace o aplikaci.

### Záznam událostí

- `FeedingFormScreen`,
- `SleepFormScreen`,
- `DiaperFormScreen`,
- `CryingFormScreen` včetně nahrávání a lokální analýzy,
- `AddEventScreen` – scrollovatelný rozcestník používající stejné sémantické
  event tiles jako rychlý modal; je zachován pro existující navigační cesty.

### Doplňkové workflow

- `ChildProfileScreen` – správa a přepnutí profilu dítěte,
- `OnboardingFlow` – úvodní vysvětlení a založení prvního profilu,
- `RecommendationsScreen` – doporučení z existujících záznamů,
- `FamilySharingScreen` – účet, propojení rodiny, členové, pečující osoby,
  strategie a stav synchronizace,
- `AppAccountSetupScreen` – nastavení účtu/providera,
- `MonetizationPlanScreen` – informace o plánovaném modelu,
- dialogy pro potvrzení mazání a obnovy,
- bottom sheety pro rychlé přidání, výběr profilu a rodinné workflow.

Systémové tlačítko Zpět nyní z vedlejší hlavní sekce nejdřív vrátí uživatele
na Zapsat. Vnořené formuláře a detailní workflow zůstávají na standardním
Navigator stacku.

## Datová vrstva a kompatibilita

### Zachované beze změny

- model `TimelineItem` a jeho generované Isar schéma,
- existující Isar inicializace, název databáze a kolekce,
- soubory profilů, rodinného spojení, přiřazení událostí a onboardingu; jejich
  cílové názvy zůstaly stejné,
- Firebase cesty, identifikátory rodiny a synchronizační orchestrace,
- Android application id. Zůstal beze změny podle zadání; před publikací je
  `com.example.bebia` samostatný blokátor popsaný v `android_release.md`.

Rebuild nevyžaduje změnu databázového schématu, a proto nevzniká databázová
migrace ani riziko drop-and-recreate. Nové UI preference jsou oddělené v
`bebia_preferences.json` v application support directory. Formát má pole
`version: 1`, používá stabilní názvy enum hodnot, ignoruje neznámé hodnoty a při
nečitelném souboru přejde na bezpečné výchozí hodnoty. Chyba zápisu vrátí
controller na předchozí hodnotu a zobrazí uživatelskou chybu. Reset preferencí
se nikdy nedotýká rodičovských dat.

## Nalezené problémy a rizika

### Architektura a kvalita

- Původní theme míchal značku, profilovou personalizaci a náhodné hodnoty v
  jednom souboru; chyběl dark mode a semantic event palette.
- Vlastní prezentační prvky se opakovaly a zásadní Material komponenty neměly
  jednotné pressed/focus/error chování.
- Několik obrazovek přesahuje 700–2 000 řádků. Další bezpečný krok je dělení
  podle existujících sekcí, nikoli zavedení nového frameworku správy stavu.
- `AppServices` ztěžuje dependency injection. Nový settings controller ji už
  podporuje konstruktorem a stejný princip lze postupně aplikovat na feature
  controllery.
- Český text je vložen přímo ve zdroji. Pro jediný podporovaný jazyk je to
  funkční, ale před druhým jazykem je nutné zavést `gen-l10n`.
- Staticky nebylo nalezeno verzované úložiště uživatelských UI preferencí.
- Původní test nepokrýval skutečná workflow ani framework exceptions.

### Staticky dohledané zdroje overflow

1. Home quick-action karta měla pevnou výšku 112 dp. Dlouhý český text nebo
   velké systémové písmo nemohly zvětšit kartu. Výška je nově minimální.
2. Původní quick-add sheet používal neomezený `Column(mainAxisSize: min)` a
   vlastní spodní padding. Nová `BebiaModalSurface` má maximum 88 % viewportu,
   `Flexible` scroll, `SafeArea`, `AnimatedPadding` a `viewInsets`.
3. Rodinný sheet používal 94 % celé výšky i při otevřené klávesnici a současně
   mohl započítat spodní SafeArea dvakrát. Nyní se nejdřív aplikuje `SafeArea`
   a animovaný keyboard inset a až z reálně zbývající výšky se vezme 94 %;
   vnitřní obsah je scrollovatelný.
4. Formuláře událostí mají velké `Column` layouty. Jejich obsah už byl z větší
   části v `Expanded + SingleChildScrollView`; nyní explicitně používají
   `resizeToAvoidBottomInset: true` a zachovávají scroll při klávesnici.
5. Původní bottom navigace měla pevné rozměry, tři delší popisky a stylování
   mimo theme. Nový chrome má krátké názvy, bezpečné maximální škálování 1,35×,
   `SafeArea` a od 600 dp přechází na rail. Obsah obrazovek se neomezuje.
6. Původní shell přes `AnimatedSwitcher` při změně indexu znovu vytvářel celou
   sekci. Nový lazy `Stack + Offstage + TickerMode` zachová navštívené sekce a
   současně nespouští skryté animace.
7. Potvrzovací dialogy s dlouhou češtinou mohly na nízkém displeji přesáhnout
   viewport. Nová sdílená varianta má maxHeight, vnitřní scroll a akce ve
   `Wrap`.
8. Informační a settings řádky nyní dávají text do `Expanded` a trailing prvky
   oddělují mezerou, takže šířku neurčuje délka titulku.
9. Široké FAB ve vizuální referenci zakrývalo spodní statistické karty. Na
   první záložce Zapsat je globální FAB skrytý, protože čtyři akce jsou přímo v
   obsahu. V Přehledu a Statistikách zůstává kompaktní přístupné FAB s tooltipem.

### Místa vyžadující runtime kontrolu

- dlouhé výsledky AI analýzy pláče a průběh nahrávání,
- extrémní timeline a grafy bez/ s tisíci položkami,
- family sheet při skutečné softwarové klávesnici v landscape,
- systémová lišta na jednotlivých Android verzích a zařízeních s gesty,
- přihlášení Google/Apple a Firebase konfigurace,
- TFLite model a oprávnění mikrofonu,
- obnovení procesu aplikace během zápisu lokálních a cloudových dat.

## Implementovaný rebuild

- Centralizovaný `BebiaTheme` pro light/dark, profilový akcent, semantic event
  colors, typografii, spacing, radiusy, elevation, ikony, motion a breakpointy.
- Vlastní komponentová vrstva pro stránky, headery, karty, sekce, settings
  tiles, bannery, empty/error panely, dialog a modal surface.
- Adaptivní shell se čtyřmi sekcemi, lazy zachováním stavu, spodní navigací na
  telefonu a rail na širších displejích.
- Nový rychlý záznam s jasnou vizuální rolí každého typu události a
  scrollovatelným layoutem.
- Nová obrazovka nastavení s reálnými persistentními volbami.
- System UI overlay pro správný kontrast status/navigation baru v obou
  režimech.
- Globální sjednocení karet, app barů, inputů, chipů, tlačítek, FAB, dialogů,
  sheetů a snackbarů i pro stávající feature obrazovky bez zásahu do business
  logiky.
- Statické opravy nejrizikovějších pevných výšek a keyboard layoutů.
- Timeline používá jeden koordinovaný `CustomScrollView` a líný `SliverList`;
  kontextové karty už neodebírají pevnou výšku samostatnému vnořenému seznamu.
- Nastavení serializuje rychlé zápisy, používá dočasný a záložní soubor,
  rozlišuje verze formátu a nedestruktivně odmítá zápis do budoucí verze.
- Mikrofonní flow rozlišuje zamítnuté oprávnění a chybu recorderu, po startu
  ověřuje skutečný stav a při opuštění formuláře aktivní záznam ruší.
- Release Android build už nepoužívá debug signing, MediaPipe má přesnou verzi
  a verze zobrazená v aplikaci pochází z package metadata.
- Přidané CI ověřuje formát, analýzu, testy a debug APK bez release tajemství.
- Vizuální diferenciace dříve jednotně tyrkysových typů událostí pomocí stálé
  sémantické palety, ikon a textových názvů; identita se už neopírá jen o
  barevné obdélníky.

## Nastavení a skutečný dopad

| Nastavení | Výchozí | Dopad | Persistence |
| --- | --- | --- | --- |
| Vzhled | Podle systému | `ThemeMode.system/light/dark`, včetně systémových lišt | JSON |
| Kompaktní zobrazení | Vypnuto | Změní `VisualDensity`, výšku navigace a vertikální padding inputů | JSON |
| Omezit pohyb | Vypnuto | Vynuluje theme, route a modal transition durations | JSON |
| Haptická odezva | Zapnuto | Odezva při navigaci, rychlé volbě a změně preference | JSON |
| Obnovit nastavení | – | Vrátí pouze předchozí čtyři volby; data dítěte zůstanou | JSON |

Oznámení, export/import a mazání dat nebyly přidány: projekt pro ně nemá
hotovou obecnou produktovou cestu a nefunkční ovládací prvky by byly zavádějící.

## Připravené testy

- start `BebiaApp` se skutečným `AppShell` a produkčními obrazovkami přes
  injektované datové seams,
- System/Light/Dark persistence a nové načtení controlleru,
- rychlá série 63 zápisů, pořadí fronty a failure novější/starší revize,
- soubor bez verze, version 0 migrace, budoucí read-only verze, neplatná pole,
  poškozený JSON, backup recovery a simulované přerušení atomického replace,
- navigace všemi hlavními sekcemi, systémové Zpět a zachování skutečně zadané
  hodnoty formuláře,
- Home, Timeline, Statistics, Settings, Family Sharing a všechny formuláře ve
  světlém i tmavém režimu na 320 × 568 dp, s 2× textem a keyboard insets,
- prázdný/loading/error i naplněný stav Timeline a Statistics včetně extrémních
  hodnot,
- validace, validní save a repository failure u všech čtyř formulářů,
- audio permission denial, start failure, start/stop/remove a dispose během
  aktivního nahrávání přes fake recorder,
- dynamická package verze a fallback,
- otevření Isar databáze po close/reopen a důkaz, že reset UI nastavení
  existující timeline záznam nezmění,
- Semantics a minimální 48 × 48 dp pro hlavní quick-add akci.

Isar model ani schema hash nebyly změněny. Připravený reopen test používá přesně
stávající `TimelineItemSchema`; produkční upgrade nad kopií reálných dat stále
vyžaduje ruční smoke test.

## Architektonické doporučení

1. Zachovat jednoduché controllery a repository rozhraní; nepřidávat nový state
   framework jen kvůli velikosti UI.
2. Rozdělit čtyři největší obrazovky do privátních section widgetů a malých
   presenterů v rámci stejné feature.
3. Postupně předávat controllery konstruktorem jako u nastavení, aby šly testovat
   empty/error stavy bez globálního Isar/Firebase prostředí.
4. Zabalit opakované formátování data/času do jedné utility před přidáním
   preference formátu.
5. Před přidáním dalšího jazyka přesunout texty do Flutter localization ARB.
6. Pro vzdálenou synchronizaci přidat contract testy s fake repository; nikdy
   netestovat cloud jen přes widgety.

## Ověřovací strategie

### Staticky ověřeno

- nové preference jsou mimo stávající datové soubory a Isar schéma,
- reset nastavení nevolá žádný user-data store,
- nové layouty používají SafeArea, omezení šířky/výšky, scroll a `viewInsets`,
- sémantické typy událostí mají barvu, ikonu i text,
- hlavní ovládací prvky používají nejméně 48 dp,
- hlavní sekce jsou lazy a po návštěvě zůstávají ve stromu,
- všechny přidané volby mají kódový dopad i save/load cestu,
- jediná nová Flutter dependency je používané `package_info_plus` pro runtime
  verzi; nebyly přidány analytics, tracking ani změna identifikátoru aplikace,
- Android release signing nemá debug fallback a secrets jsou ignorované,
- MediaPipe používá přesnou verzi `0.10.35`,
- cloudový timeline dokument neukládá audio obsah; kvůli zákazu změny
  existujícího formátu zatím zachovává pole s nepřenositelnou lokální cestou,
  což `PRIVACY.md` označuje jako následné kompatibilitní rozhodnutí.

### Čeká na ruční ověření

1. `flutter pub get`
2. `dart format .`
3. `flutter analyze`
4. `flutter test`
5. `flutter build apk --debug`
6. smoke test na úzkém a běžném Android telefonu v light/dark,
7. 2× systémový text, landscape a otevřená klávesnice ve všech formulářích,
8. upgrade přes instalaci nad existující Isar databází a JSON stores,
9. mikrofon, lokální inference a volitelné Firebase přihlášení/synchronizace.

## Známé limity

- Výsledky analyzátoru, testů a buildu nejsou k dispozici, protože jejich
  spuštění bylo výslovně zakázáno.
- Verze v obrazovce O aplikaci se načítá přes `package_info_plus`; po přidání
  dependency je nutné ručně spustit `flutter pub get`.
- Starší feature obrazovky využívají nový globální theme, ale jejich další
  dělení na menší soubory je doporučený následný refaktor, ne podmínka datové
  kompatibility.
- Plnou kompatibilitu tmavého režimu vlastních grafických ploch a pluginových
  dialogů je nutné potvrdit vizuálním smoke testem.
- Stávající PNG ilustrace mají světlé neprůhledné okraje. Jsou zachované kvůli
  kontinuitě identity; v dark mode je nutné vizuálně ověřit jejich záměrnou
  světlou kartu na všech formulářích.
- `com.example.bebia` je release blocker, ale kvůli ochraně identity a dat nebyl
  v tomto kroku změněn.
- Podepsaný release vyžaduje existující soukromý upload keystore a lokální
  `android/key.properties`; bez něj nebyl signing runtime ověřen.
- Typ open-source licence vyžaduje rozhodnutí vlastníka. Repozitář bez licence
  automaticky neuděluje právo k dalšímu použití.
- Technický `PRIVACY.md` není právně posouzená privacy policy pro store release.
- Existující Firestore formát může synchronizovat řetězec lokálního
  `audioSamplePath` (nikoli audio obsah). Odstranění pole vyžaduje samostatné
  kompatibilitní rozhodnutí, protože tento hardening nesměl měnit datový formát.
