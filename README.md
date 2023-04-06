
  

# In2 Telemetry App

  

## Vybuildenie aplikácie

V koreňovom adresári stačí spustiť súbor`./make.sh` ktorý pripravý projekt funkčného stavu pred spustením. Tento skript obsahuje nasledujúce príkazy:

**flutter clean** - vymaže adresáre `build/` and `.dart_tool/`,
**dart pub  get** - získa všetky potrebné Dart knižnice uvedené v súbore pubspec.yaml,
**flutter pub  get** - získa všetky potrebné Flutter knižnice uvedené v súbore pubspec.yaml,
**flutter gen-l10n** - vygenerovanie prekladov,
**dart run  build_runner  build  --delete-conflicting-outputs** - vygenerovanie podporných auto-generujúcich sa súborov.
  
### Editácia prekladov
Po každej zmene prekladov v súbore `lib/l10n/intl_cs.arb` je potrebné pregenerovať preklady pomocou príkazu **flutter gen-l10n**.

### Rozšírenie objektov o nové atribúty
Po každej zmene objektov, ktoré sú anotované pomocou `@freezed, @Freezed, @unfreezed, @injectable, @singleton, @lazySingleton, @module, @HiveType,` alebo atribúty súborov sú anotované pomocou `@HiveField` je potrebné pregenerovať generované súbori pomocou príkazu **dart run  build_runner  build  --delete-conflicting-outputs**.

### Pridávanie nových knižníc

Po pridaní akejkoľvek novej knižnice do súboru `pubspec.yaml` nezabudnúť spustit jej načítanie pomocou **flutter pub  get**.

## Všeobecné nastavenia:

 

### Pridávanie nových prostredí (nemocníc):

V lib`/utils/constants.dart` je zoznam prostredí `hospitals` do ktorého sa pridajú dalšie položky.

### Pridávanie nových podporovaných zariadení:

V lib`/utils/constants.dart` je zoznam podporovaných zariadení `supportedDevices` do ktorého sa pridajú dalšie položky.

Atribúty zariadenia `Device`:

**localId** - identifikácia podporovaného zariadenia,
**modelName** - to ako sa bude zariadenie zobrazovat v zozname,
**bluetoothName** - filtrácia dostupných zariadení v okolí na základe tohto mena,
**deviceModel** - podľa tohto modelu sa v prekladoch definuje popis umiestnenia tlačítka,
**supportedMeasurementTypes** - pri merani sa určuje podpora zariadenia na základe uvedených podporovaných typov meraní,
**reqPairing** - ak zariadenie vyžaduje párovanie,
**askToActivateBt** - ak je potrebné na zariadení aktivovať Bluetooth režim pred meraním,
**askToConfirmMeasurement** - ak je po meraní potrebné na zariadení potvrdiť režim Bluetooth nato aby sa začala synchronizacia údajov,
**actionButtonType** - umiestnenie tlačídka (zobrazuje sa v manuály).







### Pridávanie podporovaných meraní :

>  **Poznámka:** : Vzhľadom nato že nie všetky merania sa budú dávať vykonávať pomocou aktuálne podporovaných zariadení, napr. meranie počtu krokov, GPS, EWS. Tieto merania sa budú ukladať pomocou vlastného zápisu hodnôt.

  
  

## Verziovanie aplikácie:

1. Nastavenie poznámok, ktoré popisujú posledné zmeny v súbore `release_notes.json`,

2. Zvýšenie verzie v súbore `pubspec.yaml` napr, version: **1.0.99+99**, pričom prvé trojčíslie popisuje číslo verzie, a posledné čislo za **+** je číslo zostavy,

3. Tieto zmeny sa aktualizujú v repozitári **(git commit a git push)**,

4. V nástroji **Codemagic** sa spustí zostavenie novej verzie.

  
  
  

## SmartyPants

  

SmartyPants converts ASCII punctuation characters into "smart" typographic punctuation HTML entities. For example:

  

| |ASCII |HTML |

|----------------|-------------------------------|-----------------------------|

|Single backticks|`'Isn't this fun?'` |'Isn't this fun?' |

|Quotes |`"Isn't this fun?"` |"Isn't this fun?" |

|Dashes |`-- is en-dash, --- is em-dash`|-- is en-dash, --- is em-dash|