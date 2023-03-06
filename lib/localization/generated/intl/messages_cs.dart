// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a cs locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'cs';

  static String m0(version) => "Verze aplikace ${version}";

  static String m1(fromTime, atTime) =>
      "Plánované měření začíná ${fromTime} v ${atTime}";

  static String m2(atTime) => "v ${atTime}";

  static String m3(measurementTime) => "${Intl.select(measurementTime, {
            'yesterday': 'Včera',
            'today': 'Dnes',
            'next10': 'Nejbližší',
            'tomorrow': 'Zítra',
            'other': 'Jiný',
          })}";

  static String m4(measurementType) => "${Intl.select(measurementType, {
            'temperature': 'Teplota',
            'bloodPressure': 'Krevní tlak',
            'oxygenSaturation': 'Saturace Kyslíku',
            'steps': 'Kroky',
            'globalPosition': 'Pozice',
            'heartRate': 'Srdeční tep',
            'ews': 'Ews',
            'respiratoryRate': 'Dechová frekvence',
            'other': 'Jiný',
          })}";

  static String m5(measurementType) => "${Intl.select(measurementType, {
            'temperature': 'Teploty',
            'bloodPressure': 'Krevního tlaku',
            'oxygenSaturation': 'Saturace Kyslíku',
            'steps': 'Krokov',
            'globalPosition': 'Pozice',
            'heartRate': 'Srdečního tepu',
            'ews': 'Ews',
            'respiratoryRate': 'Dechovej frekvence',
            'other': 'Jiný',
          })}";

  static String m6(measurementUnitName) => "${Intl.select(measurementUnitName, {
            'systolic': 'Systolický',
            'diastolic': 'Diastolický',
            'temperature': 'Teplota',
            'pulse': 'Puls',
            'oxygenSaturation': 'Saturace Kyslíku',
            'respiratoryRate': 'Dechová frekvence',
            'steps': 'Kroky',
            'lat': 'Lat',
            'lng': 'Lng',
            'ews': 'Ews',
            'other': 'Jiný',
          })}";

  static String m7(count) =>
      "${Intl.plural(count, zero: 'Plnění plánu', one: 'Plnění plánu', other: 'Plnění plánů')}";

  static String m8(count) => "+ ${count} další";

  static String m9(whenCode) => "${Intl.select(whenCode, {
            'morning': 'Ráno',
            'earlyMorning': 'Brzké ráno',
            'lateMorning': 'Pozdní ráno',
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
            'other': 'Nedefinovano',
          })}";

  static String m10(whenDayName) => "${Intl.select(whenDayName, {
            'today': 'dnešek',
            'yesterday': 'včerejšek',
            'other': 'zvolené období',
          })}";

  static String m11(fromTime, toTime) => "Interval ${fromTime} - ${toTime}";

  static String m12(percentage) => "Dnešní plán byl splněn na ${percentage} %.";

  static String m13(date, time) => "Nejbližší měření je ${date} v ${time}.";

  static String m14(accountName) =>
      "Všechna data účtu ${accountName}\nbudou z aplikace nevratně\nodstraněna.";

  static String m15(deviceModel) => "${Intl.select(deviceModel, {
            'beurerBm77': 'Akční tlačítko je pod displejem',
            'omronM7': 'Akční tlačítko je vedle displeje',
            'other': 'Nedefinovano',
          })}";

  static String m16(label) => "Měření ${label}";

  static String m17(count) => "Dnes zbývají ${count} měření";

  static String m18(count) => "Celkem ${count} měření";

  static String m19(count) => "${count} čekajících měření";

  static String m20(measurementType) =>
      "Byl Vám upraven plán pro měření ${measurementType}.";

  static String m21(name, measurementType) =>
      "Uživateli ${name} byl upraven plán pro měření ${measurementType}.";

  static String m22(name) => "Uživatel ${name} byl úspěšně přidán.";

  static String m23(name) => "Výsledek měření ${name} bude nevratně odstraněn.";

  static String m24(percentage) => "Plán splněn na ${percentage}%";

  static String m25(name) =>
      "Je nám líto, ale výsledky pro účet ${name} nejsou dostupné.";

  static String m26(whenName) =>
      "Pro ${whenName} nejsou dostupné žádné výsledky.";

  static String m27(label) => "${label} nebylo plánované žádné měření";

  static String m28(name) =>
      "Je potřeba, aby se uživatel ${name} znovu přihlásil.";

  static String m29(date, time) => "Poslední synchronizace ${date} ${time}";

  static String m30(date, time) =>
      "Poslední úspěšná synchronizace ${date} ${time}";

  static String m31(fromDate) => "Platný od ${fromDate}";

  static String m32(fromDate, toDate) => "Platný od ${fromDate} do ${toDate}";

  static String m33(hospital) => "Měření v ${hospital} pro";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("ScelesoftApp"),
        "app_version": m0,
        "appearance_screen_title":
            MessageLookupByLibrary.simpleMessage("Vzhled"),
        "care_plan_detail_daily_times":
            MessageLookupByLibrary.simpleMessage("Denní doby"),
        "care_plan_detail_screen_active_from_date":
            MessageLookupByLibrary.simpleMessage("Platný od"),
        "care_plan_detail_screen_active_to_date":
            MessageLookupByLibrary.simpleMessage("Platný do"),
        "care_plan_detail_screen_fulfillment_evaluation":
            MessageLookupByLibrary.simpleMessage("Dosavadní plnění plánu"),
        "care_plan_detail_screen_fulfillment_evaluation_valid_from": m1,
        "care_plan_detail_screen_managed_by":
            MessageLookupByLibrary.simpleMessage("Spravuje"),
        "care_plan_detail_screen_measurement":
            MessageLookupByLibrary.simpleMessage("Měření"),
        "care_plan_detail_screen_plan_info":
            MessageLookupByLibrary.simpleMessage("Informace o plánu"),
        "care_plan_detail_screen_show_calendar":
            MessageLookupByLibrary.simpleMessage("Zobrazit kalendář"),
        "common_all_accounts":
            MessageLookupByLibrary.simpleMessage("Všechny účty"),
        "common_at_time": m2,
        "common_cancel": MessageLookupByLibrary.simpleMessage("Zrušit"),
        "common_close": MessageLookupByLibrary.simpleMessage("Zavřít"),
        "common_confirm": MessageLookupByLibrary.simpleMessage("Potvrdit"),
        "common_do_sync":
            MessageLookupByLibrary.simpleMessage("Synchronizovat"),
        "common_error_404":
            MessageLookupByLibrary.simpleMessage("Chyba servru"),
        "common_from": MessageLookupByLibrary.simpleMessage("Od"),
        "common_log_in": MessageLookupByLibrary.simpleMessage("Přihlásit se"),
        "common_manually": MessageLookupByLibrary.simpleMessage("Manuálně"),
        "common_measure": MessageLookupByLibrary.simpleMessage("Měřit"),
        "common_measure_now": MessageLookupByLibrary.simpleMessage("Měřit teď"),
        "common_measurement": MessageLookupByLibrary.simpleMessage("Měření"),
        "common_measurement_times": m3,
        "common_measurement_types": m4,
        "common_measurement_types_genitive": m5,
        "common_measurement_units_names": m6,
        "common_not_measured":
            MessageLookupByLibrary.simpleMessage("Nenaměřeno"),
        "common_overall": MessageLookupByLibrary.simpleMessage("Celkem"),
        "common_personal_measurement":
            MessageLookupByLibrary.simpleMessage("Vlastní měření"),
        "common_personal_record":
            MessageLookupByLibrary.simpleMessage("Vlastní zápis hodnot"),
        "common_plan_fulfillment":
            MessageLookupByLibrary.simpleMessage("Plnění plánu"),
        "common_plans_fulfillment_plural": m7,
        "common_plus_n_others": m8,
        "common_save": MessageLookupByLibrary.simpleMessage("Uložit"),
        "common_show_calendar":
            MessageLookupByLibrary.simpleMessage("Zobrazit kalendář"),
        "common_telemedicine":
            MessageLookupByLibrary.simpleMessage("Telemedicína"),
        "common_to": MessageLookupByLibrary.simpleMessage("Do"),
        "common_understand": MessageLookupByLibrary.simpleMessage("Rozumím"),
        "common_when_code": m9,
        "common_when_day_name": m10,
        "common_wrong_value":
            MessageLookupByLibrary.simpleMessage("Nesprávna hodnota"),
        "configuration_screen_add_account":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "configuration_screen_appearance_label":
            MessageLookupByLibrary.simpleMessage("Vzhled"),
        "configuration_screen_appearance_sublabel":
            MessageLookupByLibrary.simpleMessage("Téma dle systému"),
        "configuration_screen_auto_mode_desc":
            MessageLookupByLibrary.simpleMessage(
                "Světlý a tmavý režim se střídají dle západu a východu slunce."),
        "configuration_screen_auto_mode_title":
            MessageLookupByLibrary.simpleMessage("Automaticky"),
        "configuration_screen_dark":
            MessageLookupByLibrary.simpleMessage("Tmavý"),
        "configuration_screen_good_in_day":
            MessageLookupByLibrary.simpleMessage("Skvělý přes den"),
        "configuration_screen_good_in_night":
            MessageLookupByLibrary.simpleMessage("Skvělý v noci"),
        "configuration_screen_light":
            MessageLookupByLibrary.simpleMessage("Světlý"),
        "configuration_screen_logged_accounts":
            MessageLookupByLibrary.simpleMessage("Přihlášené účty"),
        "configuration_screen_notification_label":
            MessageLookupByLibrary.simpleMessage("Notifikace"),
        "configuration_screen_notification_sublabel":
            MessageLookupByLibrary.simpleMessage("Dle plánu měření"),
        "configuration_screen_settings":
            MessageLookupByLibrary.simpleMessage("Nastavení"),
        "configuration_screen_title":
            MessageLookupByLibrary.simpleMessage("Telemedicína"),
        "daily_when_time_reset_confirmation_confirm":
            MessageLookupByLibrary.simpleMessage("Resetovat na výchozí"),
        "daily_when_time_reset_confirmation_info":
            MessageLookupByLibrary.simpleMessage(
                "Upravovat denní doby můžete jenom ty, kterým tuto možnost přiřadil Váš lékař."),
        "daily_when_time_reset_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Denní doby"),
        "dashboard_screen_all": MessageLookupByLibrary.simpleMessage("Všechna"),
        "dashboard_screen_any_user_plan": MessageLookupByLibrary.simpleMessage(
            "Není nastaven žaden plán a historie měření neobsahuje žádná data."),
        "dashboard_screen_manual_measurement_info":
            MessageLookupByLibrary.simpleMessage(
                "Vlastní měření můžete spustit\ni mimo předepsaný plán."),
        "dashboard_screen_measurement_interval": m11,
        "dashboard_screen_no_more_measurements":
            MessageLookupByLibrary.simpleMessage(
                "Dnes plánované měření skončilo."),
        "dashboard_screen_no_todays_measurements":
            MessageLookupByLibrary.simpleMessage(
                "Dnes nemáte naplánované žádné měření."),
        "dashboard_screen_no_user_plan": MessageLookupByLibrary.simpleMessage(
            "Uživatel nemá nastaven plán a historie měření neobsahuje žádná data."),
        "dashboard_screen_todays_plan_finished": m12,
        "dashboard_screen_upcoming_measurement_info": m13,
        "device_selector_unsupported_devices": MessageLookupByLibrary.simpleMessage(
            "Pro tento typ měření není podporováno žádné zařízení. Hodnoty odečtěte z manuálního měření."),
        "dialog_account_removal_confirmation_button_positive_label":
            MessageLookupByLibrary.simpleMessage("Odstranit účet"),
        "dialog_account_removal_confirmation_description": m14,
        "dialog_account_removal_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Odstranit účet"),
        "hospital_selection_dialog_measurement_for":
            MessageLookupByLibrary.simpleMessage("Měření pro"),
        "hospital_selector_search_for_account":
            MessageLookupByLibrary.simpleMessage("Název účtu..."),
        "manual_measurement_screen_diasystolic":
            MessageLookupByLibrary.simpleMessage("Diastolický"),
        "manual_measurement_screen_measurement_time":
            MessageLookupByLibrary.simpleMessage("Čas odečtu"),
        "manual_measurement_screen_pulse":
            MessageLookupByLibrary.simpleMessage("Puls"),
        "manual_measurement_screen_systolic":
            MessageLookupByLibrary.simpleMessage("Systolický"),
        "manual_measurement_screen_title":
            MessageLookupByLibrary.simpleMessage("Vlastní zápis hodnot"),
        "manual_measurement_screen_type":
            MessageLookupByLibrary.simpleMessage("Typ"),
        "measurement_dialog_device_desc": m15,
        "measurement_dialog_title": m16,
        "measurement_screen_today_n_measurements": m17,
        "measurement_screen_tomorrow_n_measurements": m18,
        "measurement_screen_upcomming_n_measurements": m19,
        "not_found_screen_title":
            MessageLookupByLibrary.simpleMessage("Neznama obrazovka"),
        "notification_widget_plan_changed_desc": m20,
        "notification_widget_plan_changed_for_user_desc": m21,
        "notification_widget_plan_changed_for_user_title":
            MessageLookupByLibrary.simpleMessage("Změna plánu"),
        "notification_widget_plan_changed_title":
            MessageLookupByLibrary.simpleMessage("Změna plánu"),
        "notifications_screen_10_min_before_measurement":
            MessageLookupByLibrary.simpleMessage(
                "10 minut před každým měřením"),
        "notifications_screen_allow_notifications":
            MessageLookupByLibrary.simpleMessage("Povolit notifikace"),
        "notifications_screen_at_start_of_measurement":
            MessageLookupByLibrary.simpleMessage("V čase začátku měření"),
        "notifications_screen_measurements":
            MessageLookupByLibrary.simpleMessage("Měření"),
        "notifications_screen_title":
            MessageLookupByLibrary.simpleMessage("Notifikace"),
        "onboarding_account_added_screen_add_account_title":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "onboarding_account_added_screen_add_other_account":
            MessageLookupByLibrary.simpleMessage("Přidat další účet"),
        "onboarding_account_added_screen_continue_to_app":
            MessageLookupByLibrary.simpleMessage("Pokračovat do aplikace"),
        "onboarding_account_added_screen_user_added": m22,
        "onboarding_add_account_screen_add_account_button":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "onboarding_add_account_screen_add_account_how_it_works_button":
            MessageLookupByLibrary.simpleMessage("Jak to funguje?"),
        "onboarding_add_account_screen_add_account_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Pro používání aplikace musíte mít\naktivní alespoň jeden účet."),
        "onboarding_add_account_screen_add_account_text1":
            MessageLookupByLibrary.simpleMessage(
                "Vyhledejte místo kde jste evidován"),
        "onboarding_add_account_screen_add_account_text2":
            MessageLookupByLibrary.simpleMessage(
                "Přihlašte se přes 2-faktorové ověření"),
        "onboarding_add_account_screen_add_account_text3":
            MessageLookupByLibrary.simpleMessage("Můžete se začít měřit"),
        "onboarding_add_account_screen_add_account_title":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "result_removal_confirmation_desc": m23,
        "result_removal_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Odstranit výsledek"),
        "result_removal_confirmation_title_button_confirm":
            MessageLookupByLibrary.simpleMessage("Odstranit výsledek"),
        "results_measurements_when_selector_title":
            MessageLookupByLibrary.simpleMessage("Plnění plánu"),
        "results_plan_fulfilled_on": m24,
        "results_plan_no_measurement_needed":
            MessageLookupByLibrary.simpleMessage(
                "Plán nevyžadoval žádné měření"),
        "results_screen_no_results": m25,
        "results_screen_no_results_at_period": m26,
        "results_screen_no_results_in_plans": m27,
        "results_screen_results_title":
            MessageLookupByLibrary.simpleMessage("Výsledky"),
        "server_error_desc": MessageLookupByLibrary.simpleMessage(
            "Zde je něco v nepořádku. Zkuste akci opakovat později."),
        "server_error_title": MessageLookupByLibrary.simpleMessage("Ooops!"),
        "session_expired_description": m28,
        "session_expired_title":
            MessageLookupByLibrary.simpleMessage("Problém s přihlášením"),
        "sync_failed_screen_sub_title": m29,
        "sync_failed_screen_title":
            MessageLookupByLibrary.simpleMessage("Synchronizace"),
        "sync_failed_screen_waiting_on_sync":
            MessageLookupByLibrary.simpleMessage("Čeká na synchronizaci"),
        "sync_widget_sync_failed_desc": m30,
        "sync_widget_sync_failed_title":
            MessageLookupByLibrary.simpleMessage("Synchronizace se nepovedla"),
        "sync_widget_sync_in_progress":
            MessageLookupByLibrary.simpleMessage("Probíhá synchronizace..."),
        "sync_widget_sync_results_failed_desc":
            MessageLookupByLibrary.simpleMessage(
                "Některé výsledky se nepovedlo odeslat. Zkontrolujte připojení a zkuste synchronizaci spustit znovu"),
        "sync_widget_sync_results_failed_title":
            MessageLookupByLibrary.simpleMessage("Synchronizace se nepovedla"),
        "sync_widget_synced":
            MessageLookupByLibrary.simpleMessage("Synchronizováno"),
        "tabs_measurement": MessageLookupByLibrary.simpleMessage("Měření"),
        "tabs_more": MessageLookupByLibrary.simpleMessage("Více"),
        "tabs_results": MessageLookupByLibrary.simpleMessage("Výsledky"),
        "user_detail_screen_measurement_plans":
            MessageLookupByLibrary.simpleMessage("Plány měření"),
        "user_detail_screen_remove_account":
            MessageLookupByLibrary.simpleMessage("Odstranit účet"),
        "user_detail_screen_user_email":
            MessageLookupByLibrary.simpleMessage("Email"),
        "user_detail_screen_user_info":
            MessageLookupByLibrary.simpleMessage("Informace o uživateli"),
        "user_detail_screen_user_name":
            MessageLookupByLibrary.simpleMessage("Jméno"),
        "user_detail_screen_user_phone":
            MessageLookupByLibrary.simpleMessage("Telefon"),
        "user_detail_screen_user_surname":
            MessageLookupByLibrary.simpleMessage("Příjmení"),
        "user_details_screen_plan_active_from_date": m31,
        "user_details_screen_plan_active_from_to_date": m32,
        "user_selection_dialog_measurement_in_hospital": m33
      };
}
