// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class I10n {
  I10n();

  static I10n? _current;

  static I10n get current {
    assert(_current != null,
        'No instance of I10n was loaded. Try to initialize the I10n delegate before accessing I10n.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<I10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = I10n();
      I10n._current = instance;

      return instance;
    });
  }

  static I10n of(BuildContext context) {
    final instance = I10n.maybeOf(context);
    assert(instance != null,
        'No instance of I10n present in the widget tree. Did you add I10n.delegate in localizationsDelegates?');
    return instance!;
  }

  static I10n? maybeOf(BuildContext context) {
    return Localizations.of<I10n>(context, I10n);
  }

  /// `ScelesoftApp`
  String get appTitle {
    return Intl.message(
      'ScelesoftApp',
      name: 'appTitle',
      desc: 'The title of the application',
      args: [],
    );
  }

  /// `Verze aplikace {version}`
  String app_version(String version) {
    return Intl.message(
      'Verze aplikace $version',
      name: 'app_version',
      desc: '',
      args: [version],
    );
  }

  /// `Zrušit`
  String get common_cancel {
    return Intl.message(
      'Zrušit',
      name: 'common_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Potvrdit`
  String get common_confirm {
    return Intl.message(
      'Potvrdit',
      name: 'common_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Zavřít`
  String get common_close {
    return Intl.message(
      'Zavřít',
      name: 'common_close',
      desc: '',
      args: [],
    );
  }

  /// `Měření`
  String get common_measurement {
    return Intl.message(
      'Měření',
      name: 'common_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Měřit`
  String get common_measure {
    return Intl.message(
      'Měřit',
      name: 'common_measure',
      desc: '',
      args: [],
    );
  }

  /// `Měřit teď`
  String get common_measure_now {
    return Intl.message(
      'Měřit teď',
      name: 'common_measure_now',
      desc: '',
      args: [],
    );
  }

  /// `Vlastní měření`
  String get common_personal_measurement {
    return Intl.message(
      'Vlastní měření',
      name: 'common_personal_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Vlastní zápis hodnot`
  String get common_personal_record {
    return Intl.message(
      'Vlastní zápis hodnot',
      name: 'common_personal_record',
      desc: '',
      args: [],
    );
  }

  /// `Zobrazit kalendář`
  String get common_show_calendar {
    return Intl.message(
      'Zobrazit kalendář',
      name: 'common_show_calendar',
      desc: '',
      args: [],
    );
  }

  /// `FONS Care`
  String get common_app_name {
    return Intl.message(
      'FONS Care',
      name: 'common_app_name',
      desc: '',
      args: [],
    );
  }

  /// `Přihlásit se`
  String get common_log_in {
    return Intl.message(
      'Přihlásit se',
      name: 'common_log_in',
      desc: '',
      args: [],
    );
  }

  /// `Uložit`
  String get common_save {
    return Intl.message(
      'Uložit',
      name: 'common_save',
      desc: '',
      args: [],
    );
  }

  /// `Nesprávná hodnota`
  String get common_wrong_value {
    return Intl.message(
      'Nesprávná hodnota',
      name: 'common_wrong_value',
      desc: '',
      args: [],
    );
  }

  /// `Nenaměřeno`
  String get common_not_measured {
    return Intl.message(
      'Nenaměřeno',
      name: 'common_not_measured',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizovat`
  String get common_do_sync {
    return Intl.message(
      'Synchronizovat',
      name: 'common_do_sync',
      desc: '',
      args: [],
    );
  }

  /// `Všechny účty`
  String get common_all_accounts {
    return Intl.message(
      'Všechny účty',
      name: 'common_all_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Plnění plánu`
  String get common_plan_fulfillment {
    return Intl.message(
      'Plnění plánu',
      name: 'common_plan_fulfillment',
      desc: '',
      args: [],
    );
  }

  /// `Rozumím`
  String get common_understand {
    return Intl.message(
      'Rozumím',
      name: 'common_understand',
      desc: '',
      args: [],
    );
  }

  /// `Od`
  String get common_from {
    return Intl.message(
      'Od',
      name: 'common_from',
      desc: '',
      args: [],
    );
  }

  /// `Do`
  String get common_to {
    return Intl.message(
      'Do',
      name: 'common_to',
      desc: '',
      args: [],
    );
  }

  /// `Postup`
  String get common_procedure {
    return Intl.message(
      'Postup',
      name: 'common_procedure',
      desc: '',
      args: [],
    );
  }

  /// `Dnes`
  String get common_today {
    return Intl.message(
      'Dnes',
      name: 'common_today',
      desc: '',
      args: [],
    );
  }

  /// `v {atTime}`
  String common_at_time(String atTime) {
    return Intl.message(
      'v $atTime',
      name: 'common_at_time',
      desc: '',
      args: [atTime],
    );
  }

  /// `Přidáno {atTime}`
  String common_addded_at_time(String atTime) {
    return Intl.message(
      'Přidáno $atTime',
      name: 'common_addded_at_time',
      desc: '',
      args: [atTime],
    );
  }

  /// `{actionButtonType, select, regular{akčního tlačítka} startButton{tlačítka START} other{ }}`
  String common_action_button_label(Object actionButtonType) {
    return Intl.select(
      actionButtonType,
      {
        'regular': 'akčního tlačítka',
        'startButton': 'tlačítka START',
        'other': ' ',
      },
      name: 'common_action_button_label',
      desc: 'Action Button Type',
      args: [actionButtonType],
    );
  }

  /// `{count, plural, zero{Plnění plánu} one{Plnění plánu} other{Plnění plánů}}`
  String common_plans_fulfillment_plural(num count) {
    return Intl.plural(
      count,
      zero: 'Plnění plánu',
      one: 'Plnění plánu',
      other: 'Plnění plánů',
      name: 'common_plans_fulfillment_plural',
      desc: '',
      args: [count],
    );
  }

  /// `Celkem`
  String get common_overall {
    return Intl.message(
      'Celkem',
      name: 'common_overall',
      desc: '',
      args: [],
    );
  }

  /// `{whenDayName, select, today{dnešek} yesterday{včerejšek} other{zvolené období}}`
  String common_when_day_name(Object whenDayName) {
    return Intl.select(
      whenDayName,
      {
        'today': 'dnešek',
        'yesterday': 'včerejšek',
        'other': 'zvolené období',
      },
      name: 'common_when_day_name',
      desc: 'When day names',
      args: [whenDayName],
    );
  }

  /// `{measurementTime, select, yesterday{Včera} today{Dnes} next10{Nejbližší} tomorrow{Zítra} other{Jiný}}`
  String common_measurement_times(Object measurementTime) {
    return Intl.select(
      measurementTime,
      {
        'yesterday': 'Včera',
        'today': 'Dnes',
        'next10': 'Nejbližší',
        'tomorrow': 'Zítra',
        'other': 'Jiný',
      },
      name: 'common_measurement_times',
      desc: 'Measurement times',
      args: [measurementTime],
    );
  }

  /// `{day, select, monday{Po} tuesday{Út} wednesday{St} thursday{Čt} friday{Pá} saturday{So} sunday{Ne} other{Jiný}}`
  String common_days_in_week_short(Object day) {
    return Intl.select(
      day,
      {
        'monday': 'Po',
        'tuesday': 'Út',
        'wednesday': 'St',
        'thursday': 'Čt',
        'friday': 'Pá',
        'saturday': 'So',
        'sunday': 'Ne',
        'other': 'Jiný',
      },
      name: 'common_days_in_week_short',
      desc: 'Days in week',
      args: [day],
    );
  }

  /// `{month, select, jan{Leden} feb{Únor} march{Březen} april{Duben} may{Květen} june{Červen} july{Červenec} aug{Srpen} sept{Září} oct{Říjen} nov{Listopad} dec{Prosinec} other{Jiný}}`
  String common_months(Object month) {
    return Intl.select(
      month,
      {
        'jan': 'Leden',
        'feb': 'Únor',
        'march': 'Březen',
        'april': 'Duben',
        'may': 'Květen',
        'june': 'Červen',
        'july': 'Červenec',
        'aug': 'Srpen',
        'sept': 'Září',
        'oct': 'Říjen',
        'nov': 'Listopad',
        'dec': 'Prosinec',
        'other': 'Jiný',
      },
      name: 'common_months',
      desc: 'Months in year',
      args: [month],
    );
  }

  /// `Ooops!`
  String get server_error_title {
    return Intl.message(
      'Ooops!',
      name: 'server_error_title',
      desc: '',
      args: [],
    );
  }

  /// `Zde je něco v nepořádku. Zkuste akci opakovat později.`
  String get server_error_desc {
    return Intl.message(
      'Zde je něco v nepořádku. Zkuste akci opakovat později.',
      name: 'server_error_desc',
      desc: '',
      args: [],
    );
  }

  /// `{measurementType, select, temperature{Teplota} bloodPressure{Krevní tlak} oxygenSaturation{Saturace kyslíku} steps{Kroky} globalPosition{Pozice} heartRate{Srdeční tep} ews{Ews} respiratoryRate{Dechová frekvence} other{Jiný}}`
  String common_measurement_types(Object measurementType) {
    return Intl.select(
      measurementType,
      {
        'temperature': 'Teplota',
        'bloodPressure': 'Krevní tlak',
        'oxygenSaturation': 'Saturace kyslíku',
        'steps': 'Kroky',
        'globalPosition': 'Pozice',
        'heartRate': 'Srdeční tep',
        'ews': 'Ews',
        'respiratoryRate': 'Dechová frekvence',
        'other': 'Jiný',
      },
      name: 'common_measurement_types',
      desc: 'Measurement types',
      args: [measurementType],
    );
  }

  /// `{measurementType, select, temperature{Teploty} bloodPressure{Krevního tlaku} oxygenSaturation{Saturace kyslíku} steps{Kroků} globalPosition{Pozice} heartRate{Srdečního tepu} ews{Ews} respiratoryRate{Dechové frekvence} other{Jiný}}`
  String common_measurement_types_genitive(Object measurementType) {
    return Intl.select(
      measurementType,
      {
        'temperature': 'Teploty',
        'bloodPressure': 'Krevního tlaku',
        'oxygenSaturation': 'Saturace kyslíku',
        'steps': 'Kroků',
        'globalPosition': 'Pozice',
        'heartRate': 'Srdečního tepu',
        'ews': 'Ews',
        'respiratoryRate': 'Dechové frekvence',
        'other': 'Jiný',
      },
      name: 'common_measurement_types_genitive',
      desc: 'Measurement types',
      args: [measurementType],
    );
  }

  /// `{whenCode, select, morning{Ráno nebo dopoledne} earlyMorning{Ráno} lateMorning{Dopoledne} noon{Poledne} afternoon{Odpoledne} earlyAfternoon{Brzké odpoledne} lateAfternoon{Pozdní odpoledne} evening{Večer} earlyEvening{Brzký večer} lateEvening{Pozdní večer} night{Noc} afterSleep{Po spánku} beforeSleep{Před spánkem} afterWaking{Po probuzení} atBreakfast{Se snídaní} atLunch{S obědem} atDinner{S večeří} beforeBreakfast{Před snídaní} beforeLunch{Před obědem} beforeDinner{Před večeří} afterBreakfast{Po snídani} afterLunch{Po obědě} afterDinner{Po večeři} other{Nedefinováno}}`
  String common_when_code(Object whenCode) {
    return Intl.select(
      whenCode,
      {
        'morning': 'Ráno nebo dopoledne',
        'earlyMorning': 'Ráno',
        'lateMorning': 'Dopoledne',
        'noon': 'Poledne',
        'afternoon': 'Odpoledne',
        'earlyAfternoon': 'Brzké odpoledne',
        'lateAfternoon': 'Pozdní odpoledne',
        'evening': 'Večer',
        'earlyEvening': 'Brzký večer',
        'lateEvening': 'Pozdní večer',
        'night': 'Noc',
        'afterSleep': 'Po spánku',
        'beforeSleep': 'Před spánkem',
        'afterWaking': 'Po probuzení',
        'atBreakfast': 'Se snídaní',
        'atLunch': 'S obědem',
        'atDinner': 'S večeří',
        'beforeBreakfast': 'Před snídaní',
        'beforeLunch': 'Před obědem',
        'beforeDinner': 'Před večeří',
        'afterBreakfast': 'Po snídani',
        'afterLunch': 'Po obědě',
        'afterDinner': 'Po večeři',
        'other': 'Nedefinováno',
      },
      name: 'common_when_code',
      desc: 'When codes',
      args: [whenCode],
    );
  }

  /// `+ {count} další`
  String common_plus_n_others(int count) {
    return Intl.message(
      '+ $count další',
      name: 'common_plus_n_others',
      desc: '',
      args: [count],
    );
  }

  /// `Měření`
  String get tabs_measurement {
    return Intl.message(
      'Měření',
      name: 'tabs_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Výsledky`
  String get tabs_results {
    return Intl.message(
      'Výsledky',
      name: 'tabs_results',
      desc: '',
      args: [],
    );
  }

  /// `Více`
  String get tabs_more {
    return Intl.message(
      'Více',
      name: 'tabs_more',
      desc: '',
      args: [],
    );
  }

  /// `Přihlášené účty`
  String get configuration_screen_logged_accounts {
    return Intl.message(
      'Přihlášené účty',
      name: 'configuration_screen_logged_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Přidat účet`
  String get configuration_screen_add_account {
    return Intl.message(
      'Přidat účet',
      name: 'configuration_screen_add_account',
      desc: '',
      args: [],
    );
  }

  /// `Nastavení`
  String get configuration_screen_settings {
    return Intl.message(
      'Nastavení',
      name: 'configuration_screen_settings',
      desc: '',
      args: [],
    );
  }

  /// `Notifikace`
  String get configuration_screen_notification_label {
    return Intl.message(
      'Notifikace',
      name: 'configuration_screen_notification_label',
      desc: '',
      args: [],
    );
  }

  /// `Dle plánu měření`
  String get configuration_screen_notification_sublabel {
    return Intl.message(
      'Dle plánu měření',
      name: 'configuration_screen_notification_sublabel',
      desc: '',
      args: [],
    );
  }

  /// `Vzhled`
  String get configuration_screen_appearance_label {
    return Intl.message(
      'Vzhled',
      name: 'configuration_screen_appearance_label',
      desc: '',
      args: [],
    );
  }

  /// `Vzhled dle systému`
  String get configuration_screen_system_appearance_sublabel {
    return Intl.message(
      'Vzhled dle systému',
      name: 'configuration_screen_system_appearance_sublabel',
      desc: '',
      args: [],
    );
  }

  /// `Automaticky`
  String get configuration_screen_auto_appearance_sublabel {
    return Intl.message(
      'Automaticky',
      name: 'configuration_screen_auto_appearance_sublabel',
      desc: '',
      args: [],
    );
  }

  /// `Automaticky`
  String get configuration_screen_auto_mode_title {
    return Intl.message(
      'Automaticky',
      name: 'configuration_screen_auto_mode_title',
      desc: '',
      args: [],
    );
  }

  /// `Světlý a tmavý režim se střídají dle západu a východu slunce.`
  String get configuration_screen_auto_mode_desc {
    return Intl.message(
      'Světlý a tmavý režim se střídají dle západu a východu slunce.',
      name: 'configuration_screen_auto_mode_desc',
      desc: '',
      args: [],
    );
  }

  /// `Světlý`
  String get configuration_screen_light {
    return Intl.message(
      'Světlý',
      name: 'configuration_screen_light',
      desc: '',
      args: [],
    );
  }

  /// `Skvělý přes den`
  String get configuration_screen_good_in_day {
    return Intl.message(
      'Skvělý přes den',
      name: 'configuration_screen_good_in_day',
      desc: '',
      args: [],
    );
  }

  /// `Tmavý`
  String get configuration_screen_dark {
    return Intl.message(
      'Tmavý',
      name: 'configuration_screen_dark',
      desc: '',
      args: [],
    );
  }

  /// `Skvělý v noci`
  String get configuration_screen_good_in_night {
    return Intl.message(
      'Skvělý v noci',
      name: 'configuration_screen_good_in_night',
      desc: '',
      args: [],
    );
  }

  /// `Vzhled`
  String get appearance_screen_title {
    return Intl.message(
      'Vzhled',
      name: 'appearance_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Odstranit účet`
  String get user_detail_screen_remove_account {
    return Intl.message(
      'Odstranit účet',
      name: 'user_detail_screen_remove_account',
      desc: '',
      args: [],
    );
  }

  /// `Plány měření`
  String get user_detail_screen_measurement_plans {
    return Intl.message(
      'Plány měření',
      name: 'user_detail_screen_measurement_plans',
      desc: '',
      args: [],
    );
  }

  /// `Informace o uživateli`
  String get user_detail_screen_user_info {
    return Intl.message(
      'Informace o uživateli',
      name: 'user_detail_screen_user_info',
      desc: '',
      args: [],
    );
  }

  /// `Jméno`
  String get user_detail_screen_user_name {
    return Intl.message(
      'Jméno',
      name: 'user_detail_screen_user_name',
      desc: '',
      args: [],
    );
  }

  /// `Příjmení`
  String get user_detail_screen_user_surname {
    return Intl.message(
      'Příjmení',
      name: 'user_detail_screen_user_surname',
      desc: '',
      args: [],
    );
  }

  /// `Telefon`
  String get user_detail_screen_user_phone {
    return Intl.message(
      'Telefon',
      name: 'user_detail_screen_user_phone',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get user_detail_screen_user_email {
    return Intl.message(
      'Email',
      name: 'user_detail_screen_user_email',
      desc: '',
      args: [],
    );
  }

  /// `Registrovat zařízení`
  String get user_detail_screen_register_device_button {
    return Intl.message(
      'Registrovat zařízení',
      name: 'user_detail_screen_register_device_button',
      desc: '',
      args: [],
    );
  }

  /// `Název účtu...`
  String get hospital_selector_search_for_account {
    return Intl.message(
      'Název účtu...',
      name: 'hospital_selector_search_for_account',
      desc: '',
      args: [],
    );
  }

  /// `Měření pro`
  String get hospital_selection_dialog_measurement_for {
    return Intl.message(
      'Měření pro',
      name: 'hospital_selection_dialog_measurement_for',
      desc: '',
      args: [],
    );
  }

  /// `Měření v {hospital} pro`
  String user_selection_dialog_measurement_in_hospital(String hospital) {
    return Intl.message(
      'Měření v $hospital pro',
      name: 'user_selection_dialog_measurement_in_hospital',
      desc: '',
      args: [hospital],
    );
  }

  /// `{count} čekajících měření`
  String measurement_screen_upcomming_n_measurements(int count) {
    return Intl.message(
      '$count čekajících měření',
      name: 'measurement_screen_upcomming_n_measurements',
      desc: '',
      args: [count],
    );
  }

  /// `Dnes zbývají {count} měření`
  String measurement_screen_today_n_measurements(int count) {
    return Intl.message(
      'Dnes zbývají $count měření',
      name: 'measurement_screen_today_n_measurements',
      desc: '',
      args: [count],
    );
  }

  /// `Celkem {count} měření`
  String measurement_screen_tomorrow_n_measurements(int count) {
    return Intl.message(
      'Celkem $count měření',
      name: 'measurement_screen_tomorrow_n_measurements',
      desc: '',
      args: [count],
    );
  }

  /// `Přidat účet`
  String get onboarding_add_account_screen_add_account_title {
    return Intl.message(
      'Přidat účet',
      name: 'onboarding_add_account_screen_add_account_title',
      desc: '',
      args: [],
    );
  }

  /// `Pro používání aplikace musíte mít\naktivní alespoň jeden účet.`
  String get onboarding_add_account_screen_add_account_subtitle {
    return Intl.message(
      'Pro používání aplikace musíte mít\naktivní alespoň jeden účet.',
      name: 'onboarding_add_account_screen_add_account_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Vyhledejte místo kde jste evidován`
  String get onboarding_add_account_screen_add_account_text1 {
    return Intl.message(
      'Vyhledejte místo kde jste evidován',
      name: 'onboarding_add_account_screen_add_account_text1',
      desc: '',
      args: [],
    );
  }

  /// `Přihlaste se přes dvoufaktorové ověření`
  String get onboarding_add_account_screen_add_account_text2 {
    return Intl.message(
      'Přihlaste se přes dvoufaktorové ověření',
      name: 'onboarding_add_account_screen_add_account_text2',
      desc: '',
      args: [],
    );
  }

  /// `Můžete se začít měřit`
  String get onboarding_add_account_screen_add_account_text3 {
    return Intl.message(
      'Můžete se začít měřit',
      name: 'onboarding_add_account_screen_add_account_text3',
      desc: '',
      args: [],
    );
  }

  /// `Přidat účet`
  String get onboarding_add_account_screen_add_account_button {
    return Intl.message(
      'Přidat účet',
      name: 'onboarding_add_account_screen_add_account_button',
      desc: '',
      args: [],
    );
  }

  /// `Jak to funguje?`
  String get onboarding_add_account_screen_add_account_how_it_works_button {
    return Intl.message(
      'Jak to funguje?',
      name: 'onboarding_add_account_screen_add_account_how_it_works_button',
      desc: '',
      args: [],
    );
  }

  /// `Přidat účet`
  String get onboarding_account_added_screen_add_account_title {
    return Intl.message(
      'Přidat účet',
      name: 'onboarding_account_added_screen_add_account_title',
      desc: '',
      args: [],
    );
  }

  /// `Uživatel {name} byl úspěšně přidán.`
  String onboarding_account_added_screen_user_added(String name) {
    return Intl.message(
      'Uživatel $name byl úspěšně přidán.',
      name: 'onboarding_account_added_screen_user_added',
      desc: '',
      args: [name],
    );
  }

  /// `Pokračovat do aplikace`
  String get onboarding_account_added_screen_continue_to_app {
    return Intl.message(
      'Pokračovat do aplikace',
      name: 'onboarding_account_added_screen_continue_to_app',
      desc: '',
      args: [],
    );
  }

  /// `Přidat další účet`
  String get onboarding_account_added_screen_add_other_account {
    return Intl.message(
      'Přidat další účet',
      name: 'onboarding_account_added_screen_add_other_account',
      desc: '',
      args: [],
    );
  }

  /// `Povolení notifikací`
  String get dialog_req_notifications_title {
    return Intl.message(
      'Povolení notifikací',
      name: 'dialog_req_notifications_title',
      desc: '',
      args: [],
    );
  }

  /// `Aplikace vyžaduje povolení notifikací, pokud chcete dostávat upozornění.`
  String get dialog_req_notifications_description {
    return Intl.message(
      'Aplikace vyžaduje povolení notifikací, pokud chcete dostávat upozornění.',
      name: 'dialog_req_notifications_description',
      desc: '',
      args: [],
    );
  }

  /// `Přejít do nastavení`
  String get dialog_req_notifications_go_to_settings {
    return Intl.message(
      'Přejít do nastavení',
      name: 'dialog_req_notifications_go_to_settings',
      desc: '',
      args: [],
    );
  }

  /// `Odstranit účet`
  String get dialog_account_removal_confirmation_title {
    return Intl.message(
      'Odstranit účet',
      name: 'dialog_account_removal_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `Všechna data účtu {accountName}\nbudou z aplikace nevratně\nodstraněna.`
  String dialog_account_removal_confirmation_description(String accountName) {
    return Intl.message(
      'Všechna data účtu $accountName\nbudou z aplikace nevratně\nodstraněna.',
      name: 'dialog_account_removal_confirmation_description',
      desc: '',
      args: [accountName],
    );
  }

  /// `Platný od {fromDate}`
  String user_details_screen_plan_active_from_date(String fromDate) {
    return Intl.message(
      'Platný od $fromDate',
      name: 'user_details_screen_plan_active_from_date',
      desc: '',
      args: [fromDate],
    );
  }

  /// `Platný od {fromDate} do {toDate}`
  String user_details_screen_plan_active_from_to_date(
      String fromDate, String toDate) {
    return Intl.message(
      'Platný od $fromDate do $toDate',
      name: 'user_details_screen_plan_active_from_to_date',
      desc: '',
      args: [fromDate, toDate],
    );
  }

  /// `Dosavadní plnění plánu`
  String get care_plan_detail_screen_fulfillment_evaluation {
    return Intl.message(
      'Dosavadní plnění plánu',
      name: 'care_plan_detail_screen_fulfillment_evaluation',
      desc: '',
      args: [],
    );
  }

  /// `Plánované měření začíná {fromTime} v {atTime}`
  String care_plan_detail_screen_fulfillment_evaluation_valid_from(
      String fromTime, String atTime) {
    return Intl.message(
      'Plánované měření začíná $fromTime v $atTime',
      name: 'care_plan_detail_screen_fulfillment_evaluation_valid_from',
      desc: '',
      args: [fromTime, atTime],
    );
  }

  /// `Zobrazit kalendář`
  String get care_plan_detail_screen_show_calendar {
    return Intl.message(
      'Zobrazit kalendář',
      name: 'care_plan_detail_screen_show_calendar',
      desc: '',
      args: [],
    );
  }

  /// `Informace o plánu`
  String get care_plan_detail_screen_plan_info {
    return Intl.message(
      'Informace o plánu',
      name: 'care_plan_detail_screen_plan_info',
      desc: '',
      args: [],
    );
  }

  /// `Spravuje`
  String get care_plan_detail_screen_managed_by {
    return Intl.message(
      'Spravuje',
      name: 'care_plan_detail_screen_managed_by',
      desc: '',
      args: [],
    );
  }

  /// `Platný od`
  String get care_plan_detail_screen_active_from_date {
    return Intl.message(
      'Platný od',
      name: 'care_plan_detail_screen_active_from_date',
      desc: '',
      args: [],
    );
  }

  /// `Platný do`
  String get care_plan_detail_screen_active_to_date {
    return Intl.message(
      'Platný do',
      name: 'care_plan_detail_screen_active_to_date',
      desc: '',
      args: [],
    );
  }

  /// `Měření`
  String get care_plan_detail_screen_measurement {
    return Intl.message(
      'Měření',
      name: 'care_plan_detail_screen_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Denní doby`
  String get care_plan_detail_daily_times {
    return Intl.message(
      'Denní doby',
      name: 'care_plan_detail_daily_times',
      desc: '',
      args: [],
    );
  }

  /// `Uživatel nemá nastaven plán a historie měření neobsahuje žádná data.`
  String get dashboard_screen_no_user_plan {
    return Intl.message(
      'Uživatel nemá nastaven plán a historie měření neobsahuje žádná data.',
      name: 'dashboard_screen_no_user_plan',
      desc: '',
      args: [],
    );
  }

  /// `Není nastaven žádný plán a historie měření neobsahuje žádná data.`
  String get dashboard_screen_any_user_plan {
    return Intl.message(
      'Není nastaven žádný plán a historie měření neobsahuje žádná data.',
      name: 'dashboard_screen_any_user_plan',
      desc: '',
      args: [],
    );
  }

  /// `Vše`
  String get dashboard_screen_all {
    return Intl.message(
      'Vše',
      name: 'dashboard_screen_all',
      desc: '',
      args: [],
    );
  }

  /// `Interval {fromTime} - {toTime}`
  String dashboard_screen_measurement_interval(String fromTime, String toTime) {
    return Intl.message(
      'Interval $fromTime - $toTime',
      name: 'dashboard_screen_measurement_interval',
      desc: '',
      args: [fromTime, toTime],
    );
  }

  /// `Začíná {fromTime}\nKončí {toTime}`
  String dashboard_screen_measurement_periodical_interval(
      String fromTime, String toTime) {
    return Intl.message(
      'Začíná $fromTime\nKončí $toTime',
      name: 'dashboard_screen_measurement_periodical_interval',
      desc: '',
      args: [fromTime, toTime],
    );
  }

  /// `Zbývá {currentCount} z {reqCount} měření`
  String dashboard_screen_measurements_left(int currentCount, int reqCount) {
    return Intl.message(
      'Zbývá $currentCount z $reqCount měření',
      name: 'dashboard_screen_measurements_left',
      desc: '',
      args: [currentCount, reqCount],
    );
  }

  /// `Vlastní měření můžete spustit\ni mimo předepsaný plán.`
  String get dashboard_screen_manual_measurement_info {
    return Intl.message(
      'Vlastní měření můžete spustit\ni mimo předepsaný plán.',
      name: 'dashboard_screen_manual_measurement_info',
      desc: '',
      args: [],
    );
  }

  /// `Nejbližší měření je {date} v {time}.`
  String dashboard_screen_upcoming_measurement_info(String date, String time) {
    return Intl.message(
      'Nejbližší měření je $date v $time.',
      name: 'dashboard_screen_upcoming_measurement_info',
      desc: '',
      args: [date, time],
    );
  }

  /// `Dnes plánované měření skončilo.`
  String get dashboard_screen_no_more_measurements {
    return Intl.message(
      'Dnes plánované měření skončilo.',
      name: 'dashboard_screen_no_more_measurements',
      desc: '',
      args: [],
    );
  }

  /// `Žádné další plánované měření.`
  String get dashboard_screen_no_more_future_measurements {
    return Intl.message(
      'Žádné další plánované měření.',
      name: 'dashboard_screen_no_more_future_measurements',
      desc: '',
      args: [],
    );
  }

  /// `Dnešní plán byl splněn na {percentage}%.`
  String dashboard_screen_todays_plan_finished(int percentage) {
    return Intl.message(
      'Dnešní plán byl splněn na $percentage%.',
      name: 'dashboard_screen_todays_plan_finished',
      desc: '',
      args: [percentage],
    );
  }

  /// `Dnes nemáte naplánované žádné měření.`
  String get dashboard_screen_no_todays_measurements {
    return Intl.message(
      'Dnes nemáte naplánované žádné měření.',
      name: 'dashboard_screen_no_todays_measurements',
      desc: '',
      args: [],
    );
  }

  /// `Periodické měření`
  String get dashboard_screen_periodical_measurements {
    return Intl.message(
      'Periodické měření',
      name: 'dashboard_screen_periodical_measurements',
      desc: '',
      args: [],
    );
  }

  /// `{deviceModel, select, beurerBm77{Akční tlačítko je pod displejem} omronM7{Akční tlačítko je vedle displeje} other{Nedefinováno}}`
  String measurement_dialog_device_desc(Object deviceModel) {
    return Intl.select(
      deviceModel,
      {
        'beurerBm77': 'Akční tlačítko je pod displejem',
        'omronM7': 'Akční tlačítko je vedle displeje',
        'other': 'Nedefinováno',
      },
      name: 'measurement_dialog_device_desc',
      desc: 'Device model',
      args: [deviceModel],
    );
  }

  /// `Problém s přihlášením`
  String get session_expired_title {
    return Intl.message(
      'Problém s přihlášením',
      name: 'session_expired_title',
      desc: '',
      args: [],
    );
  }

  /// `Je potřeba, aby se uživatel {name} znovu přihlásil.`
  String session_expired_description(String name) {
    return Intl.message(
      'Je potřeba, aby se uživatel $name znovu přihlásil.',
      name: 'session_expired_description',
      desc: '',
      args: [name],
    );
  }

  /// `Přidat zařízení`
  String get metering_screen_add_device {
    return Intl.message(
      'Přidat zařízení',
      name: 'metering_screen_add_device',
      desc: '',
      args: [],
    );
  }

  /// `Před prvním měřením je potřeba spárovat aplikaci s odpovídajícím zařízením.`
  String get metering_screen_no_added_device_yet {
    return Intl.message(
      'Před prvním měřením je potřeba spárovat aplikaci s odpovídajícím zařízením.',
      name: 'metering_screen_no_added_device_yet',
      desc: '',
      args: [],
    );
  }

  /// `Na měření bez zapůjčeného přístroje nemáte oprávnění`
  String get metering_screen_no_eligible_to_measure_with_uknow_device {
    return Intl.message(
      'Na měření bez zapůjčeného přístroje nemáte oprávnění',
      name: 'metering_screen_no_eligible_to_measure_with_uknow_device',
      desc: '',
      args: [],
    );
  }

  /// `Odstranit zařízení`
  String get metering_screen_device_removal_title {
    return Intl.message(
      'Odstranit zařízení',
      name: 'metering_screen_device_removal_title',
      desc: '',
      args: [],
    );
  }

  /// `Odstranit zařízení`
  String get metering_screen_device_removal_button_confirm {
    return Intl.message(
      'Odstranit zařízení',
      name: 'metering_screen_device_removal_button_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení bude odstraněno. Pro opětovné používání ho budete muset znovu spárovat s aplikací.`
  String get metering_screen_device_removal_message {
    return Intl.message(
      'Zařízení bude odstraněno. Pro opětovné používání ho budete muset znovu spárovat s aplikací.',
      name: 'metering_screen_device_removal_message',
      desc: '',
      args: [],
    );
  }

  /// `Přidat zařízení`
  String get add_device_screen_title {
    return Intl.message(
      'Přidat zařízení',
      name: 'add_device_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Vlastní zápis hodnot`
  String get manual_measurement_screen_title {
    return Intl.message(
      'Vlastní zápis hodnot',
      name: 'manual_measurement_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Typ`
  String get manual_measurement_screen_type {
    return Intl.message(
      'Typ',
      name: 'manual_measurement_screen_type',
      desc: '',
      args: [],
    );
  }

  /// `Čas odečtu`
  String get manual_measurement_screen_measurement_time {
    return Intl.message(
      'Čas odečtu',
      name: 'manual_measurement_screen_measurement_time',
      desc: '',
      args: [],
    );
  }

  /// `{measurementUnitName, select, systolic{Systolický} diastolic{Diastolický} temperature{Teplota} pulse{Puls} oxygenSaturation{Saturace kyslíku} respiratoryRate{Dechová frekvence} steps{Kroky} lat{Lat} lng{Lng} ews{Ews} other{Jiný}}`
  String common_measurement_units_names(Object measurementUnitName) {
    return Intl.select(
      measurementUnitName,
      {
        'systolic': 'Systolický',
        'diastolic': 'Diastolický',
        'temperature': 'Teplota',
        'pulse': 'Puls',
        'oxygenSaturation': 'Saturace kyslíku',
        'respiratoryRate': 'Dechová frekvence',
        'steps': 'Kroky',
        'lat': 'Lat',
        'lng': 'Lng',
        'ews': 'Ews',
        'other': 'Jiný',
      },
      name: 'common_measurement_units_names',
      desc: 'Measurement unit names',
      args: [measurementUnitName],
    );
  }

  /// `{measurementType, select, temperature{°C} bloodPressure{mmHg} oxygenSaturation{%} heartRate{TF} other{ }}`
  String common_measurement_units_types(Object measurementType) {
    return Intl.select(
      measurementType,
      {
        'temperature': '°C',
        'bloodPressure': 'mmHg',
        'oxygenSaturation': '%',
        'heartRate': 'TF',
        'other': ' ',
      },
      name: 'common_measurement_units_types',
      desc: 'Measurement units',
      args: [measurementType],
    );
  }

  /// `tepů/min`
  String get common_heart_rate_unit {
    return Intl.message(
      'tepů/min',
      name: 'common_heart_rate_unit',
      desc: '',
      args: [],
    );
  }

  /// `Probíhá synchronizace...`
  String get sync_widget_sync_in_progress {
    return Intl.message(
      'Probíhá synchronizace...',
      name: 'sync_widget_sync_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizováno`
  String get sync_widget_synced {
    return Intl.message(
      'Synchronizováno',
      name: 'sync_widget_synced',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizace se nepovedla`
  String get sync_widget_sync_failed_title {
    return Intl.message(
      'Synchronizace se nepovedla',
      name: 'sync_widget_sync_failed_title',
      desc: '',
      args: [],
    );
  }

  /// `Poslední úspěšná synchronizace {date} {time}`
  String sync_widget_sync_failed_desc(String date, String time) {
    return Intl.message(
      'Poslední úspěšná synchronizace $date $time',
      name: 'sync_widget_sync_failed_desc',
      desc: '',
      args: [date, time],
    );
  }

  /// `Synchronizace se nepovedla`
  String get sync_widget_sync_results_failed_title {
    return Intl.message(
      'Synchronizace se nepovedla',
      name: 'sync_widget_sync_results_failed_title',
      desc: '',
      args: [],
    );
  }

  /// `Některé výsledky se nepovedlo odeslat. Zkontrolujte připojení a zkuste synchronizaci spustit znovu`
  String get sync_widget_sync_results_failed_desc {
    return Intl.message(
      'Některé výsledky se nepovedlo odeslat. Zkontrolujte připojení a zkuste synchronizaci spustit znovu',
      name: 'sync_widget_sync_results_failed_desc',
      desc: '',
      args: [],
    );
  }

  /// `Změna plánu`
  String get notification_widget_plan_changed_title {
    return Intl.message(
      'Změna plánu',
      name: 'notification_widget_plan_changed_title',
      desc: '',
      args: [],
    );
  }

  /// `Byl Vám upraven plán pro měření {measurementType}.`
  String notification_widget_plan_changed_desc(String measurementType) {
    return Intl.message(
      'Byl Vám upraven plán pro měření $measurementType.',
      name: 'notification_widget_plan_changed_desc',
      desc: '',
      args: [measurementType],
    );
  }

  /// `Uživateli {name} byl upraven plán pro měření {measurementType}.`
  String notification_widget_plan_changed_for_user_desc(
      String name, String measurementType) {
    return Intl.message(
      'Uživateli $name byl upraven plán pro měření $measurementType.',
      name: 'notification_widget_plan_changed_for_user_desc',
      desc: '',
      args: [name, measurementType],
    );
  }

  /// `Pro tento typ měření není podporováno žádné zařízení. Hodnoty odečtěte z manuálního měření.`
  String get device_selector_unsupported_devices {
    return Intl.message(
      'Pro tento typ měření není podporováno žádné zařízení. Hodnoty odečtěte z manuálního měření.',
      name: 'device_selector_unsupported_devices',
      desc: '',
      args: [],
    );
  }

  /// `Výsledky`
  String get results_screen_results_title {
    return Intl.message(
      'Výsledky',
      name: 'results_screen_results_title',
      desc: '',
      args: [],
    );
  }

  /// `Je nám líto, ale výsledky pro účet {name} nejsou dostupné.`
  String results_screen_no_results(String name) {
    return Intl.message(
      'Je nám líto, ale výsledky pro účet $name nejsou dostupné.',
      name: 'results_screen_no_results',
      desc: '',
      args: [name],
    );
  }

  /// `Na zobrazení údajů nemáte potřebné oprávnění`
  String get results_screen_no_permission_to_see_results {
    return Intl.message(
      'Na zobrazení údajů nemáte potřebné oprávnění',
      name: 'results_screen_no_permission_to_see_results',
      desc: '',
      args: [],
    );
  }

  /// `Historie měření neobsahuje žádná data.`
  String get results_screen_no_historic_data {
    return Intl.message(
      'Historie měření neobsahuje žádná data.',
      name: 'results_screen_no_historic_data',
      desc: '',
      args: [],
    );
  }

  /// `{label} nebylo plánované žádné měření`
  String results_screen_no_results_in_plans(String label) {
    return Intl.message(
      '$label nebylo plánované žádné měření',
      name: 'results_screen_no_results_in_plans',
      desc: '',
      args: [label],
    );
  }

  /// `{currentCount} z {reqCount} měření`
  String results_screen_measurements_completed(int currentCount, int reqCount) {
    return Intl.message(
      '$currentCount z $reqCount měření',
      name: 'results_screen_measurements_completed',
      desc: '',
      args: [currentCount, reqCount],
    );
  }

  /// `Plnění plánu`
  String get results_measurements_when_selector_title {
    return Intl.message(
      'Plnění plánu',
      name: 'results_measurements_when_selector_title',
      desc: '',
      args: [],
    );
  }

  /// `Plán splněn na {percentage}%`
  String results_plan_fulfilled_on(int percentage) {
    return Intl.message(
      'Plán splněn na $percentage%',
      name: 'results_plan_fulfilled_on',
      desc: '',
      args: [percentage],
    );
  }

  /// `Plán nevyžadoval žádné měření`
  String get results_plan_no_measurement_needed {
    return Intl.message(
      'Plán nevyžadoval žádné měření',
      name: 'results_plan_no_measurement_needed',
      desc: '',
      args: [],
    );
  }

  /// `Synchronizace`
  String get sync_failed_screen_title {
    return Intl.message(
      'Synchronizace',
      name: 'sync_failed_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Poslední synchronizace {date} {time}`
  String sync_failed_screen_sub_title(String date, String time) {
    return Intl.message(
      'Poslední synchronizace $date $time',
      name: 'sync_failed_screen_sub_title',
      desc: '',
      args: [date, time],
    );
  }

  /// `Odstranit výsledek`
  String get result_removal_confirmation_title {
    return Intl.message(
      'Odstranit výsledek',
      name: 'result_removal_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `Výsledek měření {name} bude nevratně odstraněn.`
  String result_removal_confirmation_desc(String name) {
    return Intl.message(
      'Výsledek měření $name bude nevratně odstraněn.',
      name: 'result_removal_confirmation_desc',
      desc: '',
      args: [name],
    );
  }

  /// `Odstranit výsledek`
  String get result_removal_confirmation_title_button_confirm {
    return Intl.message(
      'Odstranit výsledek',
      name: 'result_removal_confirmation_title_button_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Čeká na synchronizaci`
  String get sync_failed_screen_waiting_on_sync {
    return Intl.message(
      'Čeká na synchronizaci',
      name: 'sync_failed_screen_waiting_on_sync',
      desc: '',
      args: [],
    );
  }

  /// `Denní doby`
  String get daily_when_time_reset_confirmation_title {
    return Intl.message(
      'Denní doby',
      name: 'daily_when_time_reset_confirmation_title',
      desc: '',
      args: [],
    );
  }

  /// `Můžete upravovat pouze ty denní doby, u kterých Váš lékař úpravy povolil.`
  String get daily_when_time_reset_confirmation_info {
    return Intl.message(
      'Můžete upravovat pouze ty denní doby, u kterých Váš lékař úpravy povolil.',
      name: 'daily_when_time_reset_confirmation_info',
      desc: '',
      args: [],
    );
  }

  /// `Resetovat na výchozí`
  String get daily_when_time_reset_confirmation_confirm {
    return Intl.message(
      'Resetovat na výchozí',
      name: 'daily_when_time_reset_confirmation_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Notifikace`
  String get notifications_screen_title {
    return Intl.message(
      'Notifikace',
      name: 'notifications_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Povolit notifikace`
  String get notifications_screen_allow_notifications {
    return Intl.message(
      'Povolit notifikace',
      name: 'notifications_screen_allow_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Měření`
  String get notifications_screen_measurements {
    return Intl.message(
      'Měření',
      name: 'notifications_screen_measurements',
      desc: '',
      args: [],
    );
  }

  /// `V čase začátku měření`
  String get notifications_screen_at_start_of_measurement {
    return Intl.message(
      'V čase začátku měření',
      name: 'notifications_screen_at_start_of_measurement',
      desc: '',
      args: [],
    );
  }

  /// `10 minut před každým měřením`
  String get notifications_screen_10_min_before_measurement {
    return Intl.message(
      '10 minut před každým měřením',
      name: 'notifications_screen_10_min_before_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Hledání zařízení...`
  String get find_device_screen_searching_device {
    return Intl.message(
      'Hledání zařízení...',
      name: 'find_device_screen_searching_device',
      desc: '',
      args: [],
    );
  }

  /// `Čekáme až se změříte...`
  String get find_device_screen_waiting_on_measurement {
    return Intl.message(
      'Čekáme až se změříte...',
      name: 'find_device_screen_waiting_on_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení připojeno`
  String get find_device_screen_device_connected {
    return Intl.message(
      'Zařízení připojeno',
      name: 'find_device_screen_device_connected',
      desc: '',
      args: [],
    );
  }

  /// `Probíhá synchronizace výsledků...`
  String get find_device_screen_sync_results {
    return Intl.message(
      'Probíhá synchronizace výsledků...',
      name: 'find_device_screen_sync_results',
      desc: '',
      args: [],
    );
  }

  /// `Probíhá párování zařízení...`
  String get find_device_screen_pairing_device {
    return Intl.message(
      'Probíhá párování zařízení...',
      name: 'find_device_screen_pairing_device',
      desc: '',
      args: [],
    );
  }

  /// `Zapněte {deviceName} v režimu párování`
  String find_device_screen_step1_p(String deviceName) {
    return Intl.message(
      'Zapněte $deviceName v režimu párování',
      name: 'find_device_screen_step1_p',
      desc: '',
      args: [deviceName],
    );
  }

  /// `Počkejte, až vás zařízení vyzve k párování`
  String get find_device_screen_step2_p {
    return Intl.message(
      'Počkejte, až vás zařízení vyzve k párování',
      name: 'find_device_screen_step2_p',
      desc: '',
      args: [],
    );
  }

  /// `Párování zařízení`
  String get find_device_screen_step3_p {
    return Intl.message(
      'Párování zařízení',
      name: 'find_device_screen_step3_p',
      desc: '',
      args: [],
    );
  }

  /// `Spusťte na zařízení měření pomocí {actionButtonLabel} a počkejte na konec měření`
  String find_device_screen_step4_p(String actionButtonLabel) {
    return Intl.message(
      'Spusťte na zařízení měření pomocí $actionButtonLabel a počkejte na konec měření',
      name: 'find_device_screen_step4_p',
      desc: '',
      args: [actionButtonLabel],
    );
  }

  /// `Počkejte na synchronizaci výsledků`
  String get find_device_screen_step5_p {
    return Intl.message(
      'Počkejte na synchronizaci výsledků',
      name: 'find_device_screen_step5_p',
      desc: '',
      args: [],
    );
  }

  /// `Ujistěte se, že máte aktivován Bluetooth na {deviceName}`
  String find_device_screen_step1(String deviceName) {
    return Intl.message(
      'Ujistěte se, že máte aktivován Bluetooth na $deviceName',
      name: 'find_device_screen_step1',
      desc: '',
      args: [deviceName],
    );
  }

  /// `Spusťte na zařízení měření pomocí {actionButtonLabel} a počkejte na konec měření`
  String find_device_screen_step2(String actionButtonLabel) {
    return Intl.message(
      'Spusťte na zařízení měření pomocí $actionButtonLabel a počkejte na konec měření',
      name: 'find_device_screen_step2',
      desc: '',
      args: [actionButtonLabel],
    );
  }

  /// `Po meření stiskněte opět akční tlačítko`
  String get find_device_screen_step3 {
    return Intl.message(
      'Po meření stiskněte opět akční tlačítko',
      name: 'find_device_screen_step3',
      desc: '',
      args: [],
    );
  }

  /// `Počkejte na synchronizaci výsledků`
  String get find_device_screen_step4 {
    return Intl.message(
      'Počkejte na synchronizaci výsledků',
      name: 'find_device_screen_step4',
      desc: '',
      args: [],
    );
  }

  /// `Stránky nemocnice o zařízení`
  String get find_device_screen_device_reference {
    return Intl.message(
      'Stránky nemocnice o zařízení',
      name: 'find_device_screen_device_reference',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth je vypnutý`
  String get find_device_screen_disabled_bt_title {
    return Intl.message(
      'Bluetooth je vypnutý',
      name: 'find_device_screen_disabled_bt_title',
      desc: '',
      args: [],
    );
  }

  /// `Pro spojení s přístrojem je potřeba mít Bluetooth zapnutý.`
  String get find_device_screen_disabled_bt_desc {
    return Intl.message(
      'Pro spojení s přístrojem je potřeba mít Bluetooth zapnutý.',
      name: 'find_device_screen_disabled_bt_desc',
      desc: '',
      args: [],
    );
  }

  /// `Nastavení`
  String get find_device_screen_disabled_bt_btn_settings {
    return Intl.message(
      'Nastavení',
      name: 'find_device_screen_disabled_bt_btn_settings',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth zakázán `
  String get find_device_screen_not_granted_bt_title {
    return Intl.message(
      'Bluetooth zakázán ',
      name: 'find_device_screen_not_granted_bt_title',
      desc: '',
      args: [],
    );
  }

  /// `Aplikace vyžaduje povolení používat Bluetooth pro komunikaci se zařízeními.`
  String get find_device_screen_not_granted_bt_desc {
    return Intl.message(
      'Aplikace vyžaduje povolení používat Bluetooth pro komunikaci se zařízeními.',
      name: 'find_device_screen_not_granted_bt_desc',
      desc: '',
      args: [],
    );
  }

  /// `Povolit`
  String get find_device_screen_not_granted_bt_btn_settings {
    return Intl.message(
      'Povolit',
      name: 'find_device_screen_not_granted_bt_btn_settings',
      desc: '',
      args: [],
    );
  }

  /// `Měření bylo úspěšně dokončeno`
  String get measurement_summary_screen_success_title {
    return Intl.message(
      'Měření bylo úspěšně dokončeno',
      name: 'measurement_summary_screen_success_title',
      desc: '',
      args: [],
    );
  }

  /// `Výsledky budou automaticky odeslány`
  String get measurement_summary_screen_success_subtitle {
    return Intl.message(
      'Výsledky budou automaticky odeslány',
      name: 'measurement_summary_screen_success_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Máte hotovo! Výsledek se připsal k ostatním.`
  String get measurement_summary_screen_result_success_desc {
    return Intl.message(
      'Máte hotovo! Výsledek se připsal k ostatním.',
      name: 'measurement_summary_screen_result_success_desc',
      desc: '',
      args: [],
    );
  }

  /// `Nastala chyba synchronizace.`
  String get measurement_summary_screen_sync_error_desc {
    return Intl.message(
      'Nastala chyba synchronizace.',
      name: 'measurement_summary_screen_sync_error_desc',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení nedodalo žádné výsledky měření.`
  String get measurement_summary_screen_no_data_desc {
    return Intl.message(
      'Zařízení nedodalo žádné výsledky měření.',
      name: 'measurement_summary_screen_no_data_desc',
      desc: '',
      args: [],
    );
  }

  /// `Opakovat měření`
  String get measurement_summary_screen_no_data_repeat_measurement {
    return Intl.message(
      'Opakovat měření',
      name: 'measurement_summary_screen_no_data_repeat_measurement',
      desc: '',
      args: [],
    );
  }

  /// `Plán měření dne`
  String get results_history_screen_plan_of_day {
    return Intl.message(
      'Plán měření dne',
      name: 'results_history_screen_plan_of_day',
      desc: '',
      args: [],
    );
  }

  /// `Výsledky měření {measurementType} v {unitType}`
  String chart_screen_title(String measurementType, String unitType) {
    return Intl.message(
      'Výsledky měření $measurementType v $unitType',
      name: 'chart_screen_title',
      desc: '',
      args: [measurementType, unitType],
    );
  }

  /// `Zde je něco v nepořádku. Zkuste akci opakovat později.`
  String get chart_placeholder_error_loading_data {
    return Intl.message(
      'Zde je něco v nepořádku. Zkuste akci opakovat později.',
      name: 'chart_placeholder_error_loading_data',
      desc: '',
      args: [],
    );
  }

  /// `Historie měření neobsahuje žádná data.`
  String get chart_placeholder_no_data_in_month {
    return Intl.message(
      'Historie měření neobsahuje žádná data.',
      name: 'chart_placeholder_no_data_in_month',
      desc: '',
      args: [],
    );
  }

  /// `Registrovat zařízení`
  String get register_device_search_screen_title {
    return Intl.message(
      'Registrovat zařízení',
      name: 'register_device_search_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Pro registraci je potřeba mít v režimu Bluetooth aktivní jenom zařízení, které chcete registrovat.`
  String get register_device_search_screen_desc {
    return Intl.message(
      'Pro registraci je potřeba mít v režimu Bluetooth aktivní jenom zařízení, které chcete registrovat.',
      name: 'register_device_search_screen_desc',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení k registraci`
  String get register_device_detail_screen_title {
    return Intl.message(
      'Zařízení k registraci',
      name: 'register_device_detail_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení`
  String get register_device_detail_screen_device {
    return Intl.message(
      'Zařízení',
      name: 'register_device_detail_screen_device',
      desc: '',
      args: [],
    );
  }

  /// `Označení`
  String get register_device_detail_screen_assigned_id {
    return Intl.message(
      'Označení',
      name: 'register_device_detail_screen_assigned_id',
      desc: '',
      args: [],
    );
  }

  /// `Například zařízení v kuchyni`
  String get register_device_detail_screen_assigned_id_hint {
    return Intl.message(
      'Například zařízení v kuchyni',
      name: 'register_device_detail_screen_assigned_id_hint',
      desc: '',
      args: [],
    );
  }

  /// `Technický Identifikátor`
  String get register_device_detail_screen_identificator {
    return Intl.message(
      'Technický Identifikátor',
      name: 'register_device_detail_screen_identificator',
      desc: '',
      args: [],
    );
  }

  /// `Registrovat`
  String get register_device_detail_screen_button_register {
    return Intl.message(
      'Registrovat',
      name: 'register_device_detail_screen_button_register',
      desc: '',
      args: [],
    );
  }

  /// `Nevyplněné pole`
  String get register_device_detail_screen_not_filled_field {
    return Intl.message(
      'Nevyplněné pole',
      name: 'register_device_detail_screen_not_filled_field',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení bylo úspěšně registrováno.`
  String get register_device_success_screen_desc {
    return Intl.message(
      'Zařízení bylo úspěšně registrováno.',
      name: 'register_device_success_screen_desc',
      desc: '',
      args: [],
    );
  }

  /// `Chyba`
  String get register_device_detail_registration_fail_title {
    return Intl.message(
      'Chyba',
      name: 'register_device_detail_registration_fail_title',
      desc: '',
      args: [],
    );
  }

  /// `Zařízení s technickým identifikátorem {macAddress} již existuje.`
  String register_device_detail_registration_fail_message(String macAddress) {
    return Intl.message(
      'Zařízení s technickým identifikátorem $macAddress již existuje.',
      name: 'register_device_detail_registration_fail_message',
      desc: '',
      args: [macAddress],
    );
  }

  /// `{frequency} krát od {fromTime} do {toTime}`
  String notification_periodical_frequency_from_to(
      int frequency, String fromTime, String toTime) {
    return Intl.message(
      '$frequency krát od $fromTime do $toTime',
      name: 'notification_periodical_frequency_from_to',
      desc: '',
      args: [frequency, fromTime, toTime],
    );
  }

  /// `Jak to funguje`
  String get how_it_works_screen_title {
    return Intl.message(
      'Jak to funguje',
      name: 'how_it_works_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.`
  String get how_it_works_screen_desc {
    return Intl.message(
      '• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n• Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
      name: 'how_it_works_screen_desc',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<I10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'cs'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<I10n> load(Locale locale) => I10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
