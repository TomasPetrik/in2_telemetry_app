#!/bin/bash

sudo rm -Rf /Users/tomaspetrik/.pub-cache

flutter clean

dart pub get

flutter pub get

flutter gen-l10n

dart run build_runner watch --delete-conflicting-outputs

