# Android home-screen widgety Bebia

## Architektura

Widgety jsou nativní `RemoteViews`, aby se zobrazily bez spuštěného Flutter
enginu. Nativní vrstva nikdy neotevírá Isar databázi.

Tok dat:

1. Všechny zápisy, úpravy a mazání timeline procházejí přes
   `TimelineRepository`.
2. Repository po úspěšné mutaci zavolá jediný `BebiaWidgetSnapshotService`.
3. Služba načte z Isar jen timeline aktivního profilu a odvodí poslední
   krmení, spánek, přebalení a pláč.
4. Přes method channel předá pouze timestamp a krátký typový údaj.
5. Android uloží JSON do privátních `SharedPreferences` a obnoví všechny
   instance widgetů.

Snapshot neobsahuje jméno dítěte, poznámky, audio cesty, AI metadata ani jiné
citlivé údaje. Ztráta nebo poškození snapshotu nemá vliv na Isar; widget přejde
do empty stavu a po příštím startu či změně dat se obnoví.

Widget picker používá vlastní statické preview drawable bez skutečných dat
dítěte nebo událostí; nepoužívá launcher ikonu jako zástupný náhled.

## Varianty

- `BebiaFeedingWidget`: čas od posledního krmení, stručný typ/množství a akce
  pro nový záznam krmení.
- `BebiaCareWidget`: poslední krmení, spánek a přebalení plus tři rychlé akce
  do odpovídajících formulářů.

Relativní čas se přepočítá při aktualizaci snapshotu a systémovým refreshi
nejvýše jednou za 30 minut. `BOOT_COMPLETED` a `MY_PACKAGE_REPLACED` pouze
znovu vykreslí uložený snapshot; nevytvářejí background Flutter engine.

## Navigace

Widget používá explicitní immutable `PendingIntent` do `MainActivity`:

- `bebia://timeline` – celý přehled,
- `bebia://timeline/feeding` – přehled filtrovaný na krmení,
- `bebia://add/feeding`,
- `bebia://add/sleep`,
- `bebia://add/diaper`,
- `bebia://add/crying`.

`MainActivity` přijímá počáteční i nový intent a předá validovaný cíl do
`AppShell`. Shell nejprve zavře případnou vnořenou stránku, potom přepne sekci
nebo otevře formulář.

## Ruční ověření

Widgety je nutné ověřit na skutečném Android launcheru. Po instalaci otevřete
Bebii alespoň jednou, aby vznikl první snapshot. Potom přidejte obě varianty
widgetu, otestujte jejich empty stav, všechny akce, editaci a smazání události,
změnu aktivního profilu, restart telefonu a light/dark tapetu.
