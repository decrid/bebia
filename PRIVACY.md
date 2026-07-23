# Technický popis ochrany soukromí

Tento dokument popisuje chování aktuálního zdrojového kódu Bebia. Není právně
posouzenými zásadami ochrany osobních údajů ani náhradou za text, který může být
vyžadován obchodem s aplikacemi nebo provozovatelem služby.

## Data uložená v zařízení

- Události krmení, spánku, přebalování a pláče jsou primárně uložené lokálně v
  Isar databázi.
- Profily dětí, onboarding, přiřazení událostí a stav rodinného propojení
  používají oddělená lokální úložiště v aplikačním prostoru.
- Vzhled a chování UI jsou v souboru `bebia_preferences.json` v application
  support directory.
- Reset UI nastavení nemaže profily, timeline ani stav rodiny.

Odinstalace aplikace nebo vymazání jejích dat systémovým nastavením může tato
lokální data odstranit. Aplikace v této verzi neposkytuje vlastní export ani
obnovu všech lokálních dat.

## Mikrofon a audio

Mikrofon se používá pouze po akci uživatele ve formuláři pláče. Android žádá o
`RECORD_AUDIO` za běhu. Zamítnutí nespustí nahrávání.

Nahrávka vzniká jako dočasný lokální WAV soubor a může být použita lokální
klasifikací zvuku. Samotný audio obsah se v aktuální Firestore implementaci
neodesílá. Strukturovaný timeline dokument ale při zapnuté synchronizaci
zachovává existující pole `audioSamplePath`, tedy lokální cestu z původního
zařízení. Tato cesta není přenositelná a na druhém zařízení neposkytne audio;
její odstranění z cloudového schématu vyžaduje samostatné kompatibilitní
rozhodnutí a migraci.

Akce „Odebrat audio“ odstraní nový nepotvrzený soubor; u existujícího záznamu
se původní soubor odstraní až po úspěšném uložení změny. Aktivní nahrávání se
při opuštění formuláře zruší a nepotvrzený nový soubor se uklidí best effort.
Operační systém může navíc spravovat obsah dočasného adresáře vlastním
životním cyklem.

## Rodinné účty a cloud

Firebase je volitelný a aktivuje se pouze při platné konfiguraci projektu.
Přihlášení může používat Firebase Authentication, Google nebo Apple podle
platformy a zvolené akce uživatele.

Při skutečně spuštěné rodinné synchronizaci může Firestore obsahovat:

- identifikátor rodiny a uživatelského účtu,
- jméno zobrazované u vlastníka rodiny,
- role a stav členství,
- pozvánkový kód a jeho časovou platnost,
- identifikátor a název dítěte,
- strukturované údaje událostí a odvozené AI hodnoty.

Timeline zůstává lokální, dokud nejsou splněny podmínky účtu, rodiny a aktivního
profilu a uživatel nespustí odpovídající synchronizační workflow. Přesný přenos
a pravidla přístupu závisejí také na nasazené Firebase konfiguraci a security
rules; ty musí provozovatel před produkčním vydáním samostatně ověřit.

## Analytics, tracking a reklama

Ve zkontrolovaném kódu nejsou přidané analytics, reklamní SDK ani vlastní
tracking uživatelského chování. Síťové SDK použitá pro přihlášení a Firestore
mohou zpracovávat technická data podle své konfigurace a podmínek příslušného
poskytovatele; tento repozitář jejich provozní nastavení nedokládá.

## Oprávnění a citlivé soubory

- Mikrofon je volitelná schopnost a žádá se až při nahrávání.
- Release keystore, hesla a `android/key.properties` nesmějí být ve veřejném
  repozitáři.
- Audio obsah se nesynchronizuje. Existující cloudový formát však může obsahovat
  nepřenositelný řetězec lokální cesty `audioSamplePath`.

## Otevřené produktové povinnosti

Před veřejným vydáním musí provozovatel doplnit právně posouzené zásady,
retenci a mazání cloudových dat, kontaktní údaje správce, proces žádostí
uživatelů, deklarace obchodů s aplikacemi a ověřené Firebase security rules.
Samostatně je nutné rozhodnout o zpětně kompatibilním odstranění
`audioSamplePath` z cloudových dokumentů.
