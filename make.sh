#!/bin/bash

fvm flutter clean
fvm dart pub get
fvm flutter pub get
fvm flutter gen-l10n
fvm dart run build_runner build -d
