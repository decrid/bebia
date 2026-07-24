# Bebia Family Sync Architecture

## Aktuální stav v aplikaci

Tento dokument popisuje cílovou architekturu. Aktuální build má
`BebiaFirebaseConfig.currentPlatform == null`, přihlášení běží přes lokální
`signInPreview` a timeline synchronizace je převážně payload/plan preview.
Nejde tedy o hotovou synchronizaci dvou telefonů.

## Cíl

Bebia má být použitelná pro oba rodiče současně, ne jen pro jedno zařízení.
Rodinné sdílení proto nesmí být jen "více lidí na jednom účtu", ale skutečný
sdílený prostor rodiny se samostatnými účty, auditní stopou a pozvánkami.

## Proč nejít cestou Huckleberry

Huckleberry veřejně komunikuje sdílení přes stejný účet na více telefonech.
To je rychlé pro první nasazení, ale má to limity:

- není jasné, kdo konkrétní záznam vytvořil
- hůř se řeší odpojení jednoho rodiče
- nejsou přirozené role a oprávnění
- účet sdílí více osob, což je slabší z pohledu bezpečnosti i soukromí

Bebia by měla pokrýt právě tyto slabiny:

- každý rodič má vlastní účet
- dítě a události patří rodině, ne jednotlivci
- je vidět, kdo zapsal nebo upravil událost
- rodina může mít více pečujících osob
- pozvánky a členství jdou spravovat bez sdílení hesla

## Doporučená technologie

### Identita

Použít `Firebase Authentication`.

Přihlášení nabídnout přes:

- Google
- Sign in with Apple
- e-mail jako neutrální fallback

Google účet je vhodný jako způsob přihlášení, ne jako model sdílení.

### Sdílená data

Použít `Cloud Firestore`.

Důvody:

- realtime synchronizace mezi zařízeními
- offline cache v mobilních aplikacích
- jednoduché nasazení pro Flutter
- snadné napojení na Firebase Auth

### Lokální vrstva

Současný Isar a lokální JSON úložiště mohou zůstat v přechodové fázi jako:

- lokální cache
- fallback pro offline práci
- migrační zdroj při prvním spuštění cloudové verze

Zdroj pravdy pro family sharing ale musí být cloud.

## Datový model

### users

Každý člověk používající aplikaci má vlastní účet.

Pole:

- `uid`
- `displayName`
- `email`
- `providers`
- `createdAt`
- `lastActiveAt`

### families

Rodinný pracovní prostor.

Pole:

- `familyId`
- `name`
- `createdBy`
- `createdAt`
- `plan`

### family_members

Členství konkrétního uživatele v rodině.

Pole:

- `familyId`
- `uid`
- `role`
- `status`
- `invitedBy`
- `invitedAt`
- `joinedAt`

Role pro první verzi:

- `owner`
- `parent`
- `caregiver`

### children

Dítě patří rodině.

Pole:

- `childId`
- `familyId`
- `name`
- `dateOfBirth`
- `sex`
- `createdBy`
- `createdAt`
- `archivedAt`

### events

Událost patří dítěti a rodině.

Pole:

- `eventId`
- `familyId`
- `childId`
- `type`
- `payload`
- `occurredAt`
- `createdBy`
- `createdAt`
- `updatedBy`
- `updatedAt`
- `deletedAt`

`payload` nese konkrétní data podle typu události:

- krmení
- spánek
- přebalení
- pláč

### invitations

Pozvánky do rodiny.

Pole:

- `inviteId`
- `familyId`
- `code`
- `createdBy`
- `createdAt`
- `expiresAt`
- `acceptedBy`
- `acceptedAt`
- `status`

## Doporučený tok uživatele

### Vytvoření rodiny

1. Uživatel se přihlásí
2. Vytvoří rodinu
3. Rodina dostane `familyId`
4. Uživatel je do ní zapsán jako `owner`

### Pozvání druhého rodiče

1. Vlastník vytvoří pozvánku
2. Aplikace vygeneruje krátký kód nebo deep link
3. Druhý rodič se přihlásí vlastním účtem
4. Přijme pozvánku
5. Je přidán do stejné rodiny jako `parent`

### Práce s daty

1. Každé zařízení čte události podle aktivní rodiny
2. Lokální změny se zapisují ihned
3. Firestore je rozšíří na další zařízení
4. UI ukazuje, kdo záznam vytvořil nebo upravil

## Konflikty a synchronizace

Pro první verzi je přijatelný model:

- `last write wins` pro běžné úpravy
- `soft delete` místo tvrdého mazání
- auditní metadata `createdBy`, `updatedBy`

To je dostatečné pro první produkční verzi.

Pozdější rozšíření:

- historie změn
- ruční obnova omylem smazaných záznamů
- konfliktní hlášení u citlivých úprav

## Co implementovat nejdřív

### Fáze 1

- Firebase projekt
- Firebase Auth
- základní `users`, `families`, `family_members`, `children`, `events`
- vytvoření rodiny
- pozvání druhého rodiče
- synchronizace eventů a profilů dětí

Výsledek:
Skutečné sdílení mezi dvěma rodiči na dvou telefonech.

### Fáze 2

- audit "kdo zapsal"
- označení autora události v UI
- správa členů rodiny
- odpojení člena rodiny

### Fáze 3

- role a oprávnění
- chůva / babička jako omezený člen
- handoff poznámky
- sdílené připomínky

## Dopad na současnou aplikaci

Současný stav:

- `ChildProfileStore` je lokální
- `FamilyConnectionStore` je lokální
- `EventAssignmentStore` je lokální
- `TimelineRepository` je čistě lokální nad Isar

Pro cloudovou verzi bude potřeba:

- zavést `auth` vrstvu
- zavést `family session` vrstvu
- oddělit lokální repository od sdílené repository
- přidat migrační krok z lokálních dat do první rodiny

## Doporučený kódový směr

Navržené nové vrstvy:

- `features/auth/`
- `features/family_session/`
- `data/remote/`
- `data/repositories/synced_timeline_repository.dart`
- `data/repositories/synced_child_profile_repository.dart`

Současné repository je vhodné ponechat jako:

- `local_timeline_repository`
- `local_child_profile_repository`

A přes vyšší servis rozhodovat, zda aplikace běží:

- lokálně
- nebo v cloudovém family režimu

## Produktový princip

Bebia nemá prodávat jen tracking.
Má prodávat:

- jistotu
- sdílený přehled
- předání kontextu mezi rodiči
- méně mentální zátěže

Skutečný family sync je proto jedna z nejdůležitějších základních funkcí.
