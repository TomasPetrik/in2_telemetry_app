
# In2 Telemetry App

Mobilní aplikace pro Telemonitoring pacientů


## Všeobecné nastavenia:

### Pridávanie nových prostredí (nemocníc):

### Pridávanie nových podporovaných zariadení:

### Pridávanie podporovaných meraní :
> **Poznámka:** : Vzhľadom nato že nie všetky merania sa budú dávať vykonávať pomocou aktuálne podporovaných zariadení, napr. meranie počtu krokov, GPS, EWS. Tieto merania sa budú ukladať pomocou vlastného zápisu hodnôt.


## Verziovanie aplikácie:
 1. Nastavenie poznámok, ktoré popisujú posledné zmeny v súbore `release_notes.json`,
 2. Zvýšenie verzie v súbore `pubspec.yaml` napr, version: **1.0.99+99**, pričom prvé trojčíslie popisuje číslo verzie, a posledné čislo za **+** je číslo zostavy,
 3. Tieto zmeny sa aktualizujú v repozitári **(git commit a git push)**,
 4. V nástroji **Codemagic** sa spustí zostavenie novej verzie.



## SmartyPants

SmartyPants converts ASCII punctuation characters into "smart" typographic punctuation HTML entities. For example:

|                |ASCII                          |HTML                         |
|----------------|-------------------------------|-----------------------------|
|Single backticks|`'Isn't this fun?'`            |'Isn't this fun?'            |
|Quotes          |`"Isn't this fun?"`            |"Isn't this fun?"            |
|Dashes          |`-- is en-dash, --- is em-dash`|-- is en-dash, --- is em-dash|

