
  

# In2 Telemetry App

  

## Inicializácia projektu

### Potrebné akcie pred spustením aplikácie
V koreňovom adresári stačí spustiť súbor`./make.sh` ktorý pripravý projekt funkčného stavu pred spustením. Tento skript obsahuje nasledujúce príkazy:

 1. **flutter clean** - vymaže adresáre `build/` and `.dart_tool/`,
 2. **dart pub  get** - získa všetky potrebné Dart knižnice uvedené v súbore pubspec.yaml,
 3. **flutter pub  get** - získa všetky potrebné Flutter knižnice uvedené v súbore pubspec.yaml,
 4. **flutter gen-l10n** - vygenerovanie prekladov,
 5. **dart run  build_runner  build  --delete-conflicting-outputs** - vygenerovanie podporných auto-generujúcich sa súborov.

### Spustenie aplikácie

V prípade používania VS Code IDE stačí prejsť do časti **Run and Debug**, vybrať konfiguráciu (debug mode, profile mode, release mode) a spustiť pomocou zeleného tlačidla PLAY.

Alebo spustenie pomocou príkazového riadku:

 1. flutter run --debug,
 2. flutter run --profile,
 3. flutter run --release

> **Poznámka:** V prípade viacerých dostupných zariadení je možné doplniť -d `id_zariadenia` pre spustenie aplikácie na konkretnom zariadení. Viac info o spúštaní https://docs.flutter.dev/testing/debugging

  
### Editácia prekladov
Po každej zmene prekladov v súbore `lib/l10n/intl_cs.arb` je potrebné pregenerovať preklady pomocou príkazu **flutter gen-l10n**.

### Rozšírenie objektov o nové atribúty
V prípade vytváraní nových objektov alebo existujúcich objektov, ktoré používajú nasledujúce anotácie  `@freezed, @Freezed, @unfreezed, @injectable, @singleton, @lazySingleton, @module, @HiveType,` alebo anotácie atribútov objektovJ `@JsonKey, @HiveField` je potrebné pregenerovať automaticky generované súbori pomocou príkazu **dart run  build_runner  build  --delete-conflicting-outputs**.

### Pridávanie nových knižníc

Po pridaní akejkoľvek novej knižnice do súboru `pubspec.yaml` nezabudnúť spustit jej načítanie pomocou **flutter pub  get**.

## Nastavenia a parametre aplikácie:

### Základné parametre:

V súbore `lib/utils/constants.dart` sa nachádzajú nasledujúce parametre:
|  Parametre | Význam |  Prednastavená hodnota |
|--|--|--|
|  autoSyncIntervalMinutes | Periodické načitávanie plánov na pozadí v minútach. |  15 |
| defaultLat / defaultLng | Prednastavená poloha (Praha), ktorá sa použije pri automatickom prepínaní režimu Light / Dark pri východe / západe slnka pokiaľ je  zakázané načítať polohu zariadenia. | 50.08804 / 14.42076 |
| clientSecret | Týka sa prihlasovania OAuth2 |'cqWFWo9zYQHFh38kS8VC'|
| clientId | Týka sa prihlasovania OAuth2 |'MobileApp' |
| scopes | Týka sa prihlasovania OAuth2 |[openid,..] |
|  redirectUrl | Týka sa prihlasovania OAuth2 |'cz.scalesoft.tlm://auth-callback' |
|  redirectUrl | Týka sa prihlasovania OAuth2 | |



### Manažment prostredí (nemocníc):

V `lib/utils/constants.dart` je zoznam prostredí `hospitals` do ktorého sa môžu pridať / upraviť existujúce prostredia.

### Manažment podporovaných zariadení:

V lib`/utils/constants.dart` je zoznam podporovaných zariadení `supportedDevices` do ktorého sa môžu neskôr pridať dalšie zariadenia.

Atribúty zariadenia `Device`:

 - **localId** - identifikácia podporovaného zariadenia,
 - **modelName** - to ako sa bude zariadenie zobrazovat v zozname,
 - **bluetoothName** - filtrácia dostupných zariadení v okolí na základe tohto mena,
 - **deviceModel** - podľa tohto modelu sa v prekladoch definuje popis umiestnenia tlačítka,
 - **supportedMeasurementTypes** - pri merani sa určuje podpora zariadenia na základe uvedených podporovaných typov meraní,
 -  **reqPairing** - ak zariadenie vyžaduje párovanie,
 - **askToActivateBt** - ak je potrebné na zariadení aktivovať Bluetooth režim pred meraním,
 - **askToConfirmMeasurement** - ak je po meraní potrebné na zariadení potvrdiť režim Bluetooth nato aby sa začala synchronizacia údajov,
 - **actionButtonType** - umiestnenie tlačídka (zobrazuje sa v manuály).

### Manažment podporovaných meraní :

V lib`/utils/constants.dart` je zoznam podporovaných zariadení `supportedMeasurements` ktoré je možné neskôr podľa potreby editovať. Napríklad nastaviť minimá, maximá a ohraničenia manuálne zapísaných hodnôt.

>  **Poznámka:** : Vzhľadom nato že nie všetky merania sa budú dávať vykonávať pomocou aktuálne podporovaných zariadení, napr. meranie počtu krokov, GPS, EWS. Tieto merania sa budú ukladať pomocou vlastného zápisu hodnôt.

  

## Verziovanie aplikácie:

1. Nastavenie poznámok, ktoré popisujú posledné zmeny v súbore `release_notes.json`,

2. Zvýšenie verzie v súbore `pubspec.yaml` napr, version: **1.0.99+99**, pričom prvé trojčíslie popisuje číslo verzie, a posledné čislo za **+** je číslo zostavy,

3. Tieto zmeny sa aktualizujú v repozitári **(git commit a git push)**,

4. V nástroji **Codemagic** sa spustí zostavenie novej verzie.

 