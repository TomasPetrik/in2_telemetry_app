#!/bin/bash

flutter clean

dart pub get

flutter pub get

flutter gen-l10n

dart run build_runner build -d

