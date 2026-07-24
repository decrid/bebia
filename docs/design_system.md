# Design systém Bebia

## Identita

Bebia je každodenní pomocník pro rodiče malých dětí. Vizuální jazyk proto
spojuje klid, důvěryhodnost a rychlou čitelnost jednou rukou. Základ tvoří
hluboká šalvějová barva, teplé neutrální plochy, měkké rohy a střídmé stíny.
Primární značka zůstává stabilní napříč profily; profil dítěte se může jemně
projevit jen v sekundárním gradientu. Význam událostí se tím nemění.

Značkový symbol je abstraktní písmeno B tvořené otevřenou linií objetí a malým
akcentním bodem. Neobsahuje text ani doslovný obrázek dítěte. Stejná geometrie
je zdrojem pro Flutter komponentu, nativní splash, adaptive launcher ikonu a
Android 13+ monochrome ikonu. Editovatelné mastery jsou v `assets/branding/`.
Android používá vektorové resources přímo. iOS rasterizované AppIcon a
LaunchImage soubory reprodukovatelně vytváří
`tool/generate_ios_brand_assets.ps1`; skript se spouští ručně pouze při změně
geometrie nebo barev značky.

Na rozdíl od TimIQ nepoužívá Bebia chronografickou, technickou estetiku. Z jeho
referenční implementace přebírá pouze principy: centralizované tokeny, vlastní
komponenty, adaptivní shell, trvalé preference a systematický dark mode.

## Zdroj pravdy

Všechny nové tokeny a theme jsou v `lib/core/design/bebia_theme.dart`:

- `BebiaColors` – značkové a sémantické základní barvy,
- `BebiaSpace` – kroky 4, 8, 12, 16, 24, 32 a 40 dp,
- `BebiaRadius` – 12, 18, 26, 34 dp a pill,
- `BebiaIconSize` – 18, 24, 30 a 40 dp,
- `BebiaBreakpoints` – kompaktní rozhraní do 600 dp, rozšířené od 900 dp a
  maximální šířka čitelného obsahu 760 dp,
- `BebiaMotion` – 140, 240 a 360 ms s křivkami `easeOutCubic` a
  `easeInCubic`,
- `BebiaMetrics.minimumTouchTarget` – minimální aktivní plocha 48 dp,
- `BebiaVisuals` – sémantické barvy událostí, stavové barvy, tlumený text,
  hero gradient, stín karet a preference omezeného pohybu.

## Barvy

| Role | Světlý základ | Význam |
| --- | --- | --- |
| Primární | `#2F6B5A` | značka, navigace a hlavní akce |
| Krmení | `#D96F57` | krmení a množství |
| Spánek | `#6571B5` | spánek a odpočinek |
| Přebalení | `#43866B` | přebalování a péče |
| Pláč | `#C98A32` | pláč, upozornění a zvuková analýza |
| Chyba | `#B94747` | chyba a destruktivní akce |
| Canvas | `#F7F4EE` | teplé světlé pozadí |
| Surface | `#FFFCF7` | čitelná obsahová plocha |
| Dark canvas | `#101714` | noční pozadí bez čisté černé |
| Dark surface | `#17211D` | zvýšená noční plocha |

Tmavá varianta používá světlejší sémantické odstíny pro kontrast na tmavých
plochách. Informace se nikdy nerozlišuje jen barvou: typ události má současně
ikonu a textový popisek.

Plochy, text a okraje se vždy párují z jedné sémantické rodiny:
`surface/onSurface`, `primaryContainer/onPrimaryContainer`,
`secondaryContainer/onSecondaryContainer`, `error/onError`. Event akcent se v
tmavém režimu používá jako průsvitná vrstva nad `surface`, nikoli jako pevný
světlý pastel. Profilové chipy vytvářejí vlastní `ColorScheme.fromSeed` pro
aktuální brightness, takže modrá/růžová identita zůstává rozlišitelná bez
světlé plochy v nočním režimu.

## Typografie

Theme vychází z Material 2021 text scale, ale upravuje hierarchii:

- titulní a nadpisové styly používají váhu 800 a těsnější řádkování,
- názvy karet a prvků používají váhu 700,
- běžný text má řádkování 1,45 pro čitelnost delší češtiny,
- důležité popisky používají váhu 800,
- navigační chrome omezuje extrémní škálování na 1,35×, samotný obsah zůstává
  dostupný systémovému škálování až do testovaných 2×.

Text musí růst bez pevné výšky kontejneru. Jednořádkové zkrácení je přijatelné
jen u sekundárních metadat, nikdy u instrukce, chyby nebo primární akce.

## Sdílené komponenty

`lib/shared/widgets/bebia_components.dart` poskytuje:

- `BebiaPage` – SafeArea, maximální šířka a konzistentní okraje,
- `BebiaScreenHeader` – název, vysvětlení a volitelná akce,
- `BebiaCard` – společná plocha, focus/pressed stav a Semantics,
- `BebiaSectionHeader` – stabilní informační hierarchie,
- `BebiaSettingsTile` – přístupný řádek preference,
- `BebiaInfoBanner` – kontextová informace bez závislosti pouze na barvě,
- `BebiaStatePanel` – základ pro empty/error state,
- `BebiaFormIntroCard` – theme-aware hero formulářů s event akcentem,
- `BebiaModalSurface` – bottom sheet omezený výškou, scrollovatelný a
  reagující na `viewInsets`,
- `showBebiaConfirmDialog` – scrollovatelný adaptivní potvrzovací dialog.

Globální theme dále sjednocuje app bary, karty, inputy, chipy, tlačítka,
navigaci, dialogy, bottom sheety a snackbary i ve starších feature widgetech.

`lib/shared/widgets/bebia_brand_mark.dart` vykresluje značku nativně pomocí
`CustomPainter`; nepřidává runtime závislost ani bitmapu. Dashboard používá
nejdřív čas od poslední události, potom stručné metadata. Dlouhé vysvětlení
patří na detail, do empty/error stavu nebo na vyžádání.

## Start aplikace a Android widgety

- Nativní light/dark splash a Android 12+ SplashScreen API používají stejný
  canvas a symbol jako první Flutter frame.
- `BebiaBootstrap` spouští skutečnou inicializaci bez umělého časovače a při
  chybě nabízí bezpečný retry; data nemaže ani nereinitializuje.
- Android home-screen widget nikdy neotevírá Isar. `TimelineRepository`
  centralizovaně vyvolá vytvoření minimálního snapshotu a nativní vrstva jej
  uloží do privátních `SharedPreferences`.
- Snapshot obsahuje jen časy a krátké typové údaje posledního krmení, spánku,
  přebalení a pláče. Neobsahuje jméno dítěte ani poznámky.
- Widget se obnoví po změně timeline, změně aktivního profilu, inicializaci
  aplikace, restartu telefonu, aktualizaci balíčku a nejvýše jednou za 30 minut
  kvůli relativnímu času.
- Akce používají explicitní `PendingIntent` do `MainActivity`; schéma
  `bebia://timeline/...` otevírá filtrovaný přehled a `bebia://add/...`
  odpovídající formulář.

## Light a dark režim

- Aplikace podporuje `system`, `light` a `dark` přes `MaterialApp.themeMode`.
- Oba režimy používají stejnou typografii, spacing a význam barev.
- Žádný widget nesmí odvozovat význam z `Colors.white` nebo `Colors.black`;
  nové prvky čerpají z `ColorScheme` a `BebiaVisuals`.
- Status bar a systémová navigační lišta dostávají kontrastní ikony podle
  aktivního režimu.
- Noční režim používá tmavou zelenošedou místo absolutní černé, aby nepůsobil
  tvrdě při noční péči.
- Stávající bitmapové ilustrace mají záměrně světlé, neprůhledné pozadí. V dark
  režimu patří do samostatné světlé ilustrační karty s popisem; nesmí se položit
  přímo na tmavý canvas ani automaticky invertovat.

## Responzivita a safe areas

- Do 600 dp používá shell spodní navigaci, od 600 dp `NavigationRail`, od
  900 dp její rozšířenou variantu.
- Hlavní sekce se načítají líně a po první návštěvě zachovají scroll i lokální
  stav.
- Formuláře mají `resizeToAvoidBottomInset`, scrollovatelný obsah a pevnou
  akci mimo scroll pouze tam, kde se bezpečně vejde do zbývající výšky.
- Modální obsah používá `viewInsets`, maximálně 88 % výšky a vnitřní scroll.
- Karty s uživatelským textem používají minimální, nikoli pevnou výšku.
- Timeline s proměnlivými kartami nad historií používá jeden
  `CustomScrollView`; dlouhý seznam zůstává líný přes `SliverList`.
- Metrické karty používají obsahově řízený `Wrap`: při šířce pod 380 dp nebo
  text scale alespoň 1,5 přecházejí na jeden sloupec.
- Vícepoložkové kompaktní volby nesmějí spoléhat na jeden široký
  `SegmentedButton`. Na 320 dp nebo při velkém textu se skládají do plnošířkových
  `ChoiceChip` řádků a všechny možnosti zůstávají současně viditelné.
- App bary s přepínačem profilu zvětšují výšku při systémovém textu alespoň
  1,5×; samotné chipy zůstávají vodorovně scrollovatelné.
- Otevřená klávesnice se testuje přes skutečné `viewInsets`; padding i maximální
  výška sheetu se počítají z dostupné výšky, ne z celého viewportu.
- Na širokém zařízení se obsah drží do 760 dp; nevznikají dlouhé nečitelné
  řádky.
- Primární dotykové plochy mají nejméně 48 × 48 dp.

## Pravidla pro budoucí obrazovky

1. Nejprve pojmenujte hlavní úlohu obrazovky a jednu primární akci.
2. Použijte existující token nebo komponentu; lokální číselná hodnota musí mít
   význam, který v tokenech opravdu není.
3. Každý asynchronní obsah má loading, empty a error variantu.
4. Dialog či sheet musí projít kontrolou na 320 × 568 dp, s 2× textem a s
   klávesnicí.
5. Stav se nesmí sdělovat pouze barvou; přidejte ikonu, text nebo Semantics.
6. Před použitím `Row` pro dlouhý text vložte text do `Expanded` nebo použijte
   `Wrap`.
7. Nevkládejte obsah pod systémové oblasti bez záměrného edge-to-edge návrhu.
8. Nová preference musí být trvale uložená, mít výchozí hodnotu, reálný dopad
   a test round-tripu.
9. Testovací minimum pro kritickou obrazovku je light i dark, 320 × 568 dp,
   text scale 2,0 a `tester.takeException() == null`; keyboard workflow navíc
   používá realistické `viewInsets`.
10. Pevný `childAspectRatio`, `Spacer` v neomezeném vertikálním prostoru a
    nesrolovatelný `Column` nad dlouhým seznamem jsou zakázané bez doložených
    horních mezí obsahu.
