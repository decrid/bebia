# Firebase Family Sync Setup

## Co je už připravené v projektu

V Bebii je nachystaný základ pro:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`
- `sign_in_with_apple`

Kód zatím běží bezpečně i bez konfigurace Firebase projektu.

## Co je potřeba doplnit jako další krok

### 1. Založit Firebase projekt

- vytvořit nový Firebase projekt pro Bebii
- přidat Android a iOS aplikaci

### 2. Připojit FlutterFire

- nainstalovat `flutterfire_cli`
- spustit konfiguraci projektu
- vygenerovat `firebase_options.dart`

### 3. Zapnout Authentication

Ve Firebase Console povolit:

- Google
- Apple
- Email/Password nebo email link

### 4. Zapnout Firestore

- založit databázi v produkčním nebo testovacím režimu
- připravit základní security rules

### 5. Nahradit dočasnou konfiguraci

Současný soubor:

- `lib/core/firebase/bebia_firebase_config.dart`

je jen placeholder.

Jakmile bude k dispozici skutečný `firebase_options.dart`, je potřeba:

- nahradit placeholder importem skutečných options
- vrátit `currentPlatform`

### 6. Implementovat první produkční tok

První ostrá verze by měla umět:

- přihlášení rodiče
- vytvoření rodiny
- vytvoření pozvánky
- přijetí pozvánky druhým rodičem
- zápis události do cloudové rodiny
- čtení sdílených událostí z Firestore

## Doporučené pořadí implementace

1. Auth
2. Family membership
3. Invitations
4. Remote events
5. Přepnutí timeline na cloudový zdroj
