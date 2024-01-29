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

  static String m2(measurementType, unitType) =>
      "Výsledky měření ${measurementType} ${unitType}";

  static String m3(actionButtonType) => "${Intl.select(actionButtonType, {
            'regular': 'akčního tlačítka',
            'startButton': 'START|STOP',
            'other': ' ',
          })}";

  static String m4(atTime) => "Přidáno ${atTime}";

  static String m5(atTime) => "v ${atTime}";

  static String m6(day) => "${Intl.select(day, {
            'monday': 'Po',
            'tuesday': 'Út',
            'wednesday': 'St',
            'thursday': 'Čt',
            'friday': 'Pá',
            'saturday': 'So',
            'sunday': 'Ne',
            'other': 'Jiný',
          })}";

  static String m7(measurementTime) => "${Intl.select(measurementTime, {
            'yesterday': 'Včera',
            'today': 'Dnes',
            'next10': 'Nejbližší',
            'tomorrow': 'Zítra',
            'other': 'Jiný',
          })}";

  static String m8(measurementType) => "${Intl.select(measurementType, {
            'temperature': 'Teplota',
            'bloodPressure': 'Krevní tlak',
            'oxygenSaturation': 'Saturace kyslíku',
            'steps': 'Kroky',
            'globalPosition': 'Pozice',
            'heartRate': 'Srdeční tep',
            'ews': 'Ews',
            'respiratoryRate': 'Dechová frekvence',
            'shortnessOfBreath': 'Dušnost',
            'overallHealth': 'Celkový zdravotní stav',
            'other': 'Jiný',
          })}";

  static String m9(measurementType) => "${Intl.select(measurementType, {
            'temperature': 'Teploty',
            'bloodPressure': 'Krevního tlaku',
            'oxygenSaturation': 'Saturace kyslíku',
            'steps': 'Kroků',
            'globalPosition': 'Pozice',
            'heartRate': 'Srdečního tepu',
            'ews': 'Ews',
            'respiratoryRate': 'Dechové frekvence',
            'shortnessOfBreath': 'Dušnosti',
            'overallHealth': 'Celkového zdravotního stavu',
            'other': 'Jiný',
          })}";

  static String m10(measurementUnitName) =>
      "${Intl.select(measurementUnitName, {
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
            'shortnessOfBreath': 'Dušnost',
            'overallHealth': 'Celkový zdravotní stav',
            'other': 'Jiný',
          })}";

  static String m11(measurementType) => "${Intl.select(measurementType, {
            'temperature': '°C',
            'bloodPressure': 'mmHg',
            'oxygenSaturation': '%',
            'heartRate': 'tepů/min',
            'other': '',
          })}";

  static String m12(month) => "${Intl.select(month, {
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
          })}";

  static String m13(count) =>
      "${Intl.plural(count, zero: 'Plnění plánu', one: 'Plnění plánu', other: 'Plnění plánů')}";

  static String m14(count) => "+ ${count} další";

  static String m15(whenCode) => "${Intl.select(whenCode, {
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
          })}";

  static String m16(whenDayName) => "${Intl.select(whenDayName, {
            'today': 'dnešek',
            'yesterday': 'včerejšek',
            'other': 'zvolené období',
          })}";

  static String m17(fromTime, toTime) => "Interval ${fromTime} - ${toTime}";

  static String m18(fromTime, toTime) => "Začíná ${fromTime}\nKončí ${toTime}";

  static String m19(currentCount, reqCount) =>
      "Zbývá ${currentCount} z ${reqCount} měření";

  static String m20(percentage) => "Dnešní plán byl splněn na ${percentage}%.";

  static String m21(date, time) => "Nejbližší měření je ${date} v ${time}.";

  static String m22(devicePurposeName) => "${Intl.select(devicePurposeName, {
            'addDevice':
                'Pro přidání zařízení je potřeba mít Bluetooth v režimu párovaní jenom zařízení, které chcete přidat.',
            'registerDevice':
                'Pro registraci je potřeba mít v režimu Bluetooth aktivní jenom zařízení, které chcete registrovat.',
            'other': 'Jiný',
          })}";

  static String m23(devicePurposeName) => "${Intl.select(devicePurposeName, {
            'addDevice': 'Přidat zařízení',
            'registerDevice': 'Registrovat zařízení',
            'other': 'Jiný',
          })}";

  static String m24(accountName) =>
      "Všechna data účtu ${accountName}\nbudou z aplikace nevratně\nodstraněna.";

  static String m25(deviceName) =>
      "Ujistěte se, že máte aktivován Bluetooth na ${deviceName}";

  static String m26(deviceName) => "Zapněte ${deviceName} v režimu párování";

  static String m27(actionButtonLabel) =>
      "Spusťte na tlakoměru měření pomocí tlačítka ${actionButtonLabel} a počkejte na jeho dokončení";

  static String m28(actionButtonLabel) =>
      "Vypněte tlakoměr pomocí tlačítka ${actionButtonLabel}, poté spusťte měření dalším stisknutím tlačítka ${actionButtonLabel} a počkejte na jeho dokončení";

  static String m29(deviceModel) => "${Intl.select(deviceModel, {
            'beurerBm77': 'Akční tlačítko je pod displejem',
            'omronM7': 'Akční tlačítko je vedle displeje',
            'other': 'Nedefinováno',
          })}";

  static String m30(count) => "Dnes zbývají ${count} měření";

  static String m31(count) => "Celkem ${count} měření";

  static String m32(count) => "${count} čekajících měření";

  static String m33(frequency, fromTime, toTime) =>
      "${frequency} krát od ${fromTime} do ${toTime}";

  static String m34(measurementType) =>
      "Byl Vám upraven plán pro měření ${measurementType}.";

  static String m35(name, measurementType) =>
      "Uživateli ${name} byl upraven plán pro měření ${measurementType}.";

  static String m36(name) => "Uživatel ${name} byl úspěšně přidán.";

  static String m37(overallHealthValue) => "${Intl.select(overallHealthValue, {
            'good': 'Velmi dobrý',
            'variable': 'Mírné/občasné zhoršení při fyzické námaze',
            'bad': 'Setrvalé zhoršení bez příčiny',
            'veryBad': 'Cítím se velmi špatně',
            'other': '',
          })}";

  static String m38(permission) => "${Intl.select(permission, {
            'notification':
                'Oprávnění odesílat oznámení je nutné pro průběžnou komunikaci aplikace s hodinkami.',
            'bluetoothConnect':
                'Oprávnění připojovat se k Bluetooth zařízením je nutné pro přenos měření z hodinek.',
            'ignoreBatteryOptimizations':
                'Oprávnění běžet na pozadí nám pomáhá zajistit, aby přenos dat správně pracoval, i když aplikace není spuštěná.',
            'other': ' ',
          })}";

  static String m39(permission) => "${Intl.select(permission, {
            'notification': 'Odesílání oznámení',
            'bluetoothConnect': 'Připojování k Bluetooth zařízením',
            'ignoreBatteryOptimizations': 'Běh aplikace na pozadí',
            'other': ' ',
          })}";

  static String m40(macAddress) =>
      "Zařízení s technickým identifikátorem ${macAddress} již existuje.";

  static String m41(name) => "Výsledek měření ${name} bude nevratně odstraněn.";

  static String m42(percentage) => "Plán splněn na ${percentage}%";

  static String m43(currentCount, reqCount) =>
      "${currentCount} z ${reqCount} měření";

  static String m44(name) =>
      "Je nám líto, ale výsledky pro účet ${name} nejsou dostupné.";

  static String m45(label) => "${label} nebylo plánované žádné měření";

  static String m46(name) =>
      "Je potřeba, aby se uživatel ${name} znovu přihlásil.";

  static String m47(shortnessOfBreathValue) =>
      "${Intl.select(shortnessOfBreathValue, {
            'none': 'Dýchání bez problémů',
            'low': 'Občasná dušnost při fyzické námaze',
            'medium': 'Častější problémy s dušností',
            'high': 'Velmi špatně se mi dýchá',
            'other': '',
          })}";

  static String m48(date, time) => "Poslední synchronizace ${date} ${time}";

  static String m49(date, time) =>
      "Poslední úspěšná synchronizace ${date} ${time}";

  static String m50(fromDate) => "Platný od ${fromDate}";

  static String m51(fromDate, toDate) => "Platný od ${fromDate} do ${toDate}";

  static String m52(hospital) => "Měření v ${hospital} pro";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_device_screen_title":
            MessageLookupByLibrary.simpleMessage("Přidat zařízení"),
        "appTitle": MessageLookupByLibrary.simpleMessage("FONS Care"),
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
        "chart_placeholder_error_loading_data":
            MessageLookupByLibrary.simpleMessage(
                "Zde je něco v nepořádku. Zkuste akci opakovat později."),
        "chart_placeholder_no_data_in_month":
            MessageLookupByLibrary.simpleMessage(
                "Historie měření neobsahuje žádná data."),
        "chart_screen_title": m2,
        "common_action_button_label": m3,
        "common_addded_at_time": m4,
        "common_all_accounts":
            MessageLookupByLibrary.simpleMessage("Všechny účty"),
        "common_app_name": MessageLookupByLibrary.simpleMessage("FONS Care"),
        "common_at_time": m5,
        "common_cancel": MessageLookupByLibrary.simpleMessage("Zrušit"),
        "common_close": MessageLookupByLibrary.simpleMessage("Zavřít"),
        "common_confirm": MessageLookupByLibrary.simpleMessage("Potvrdit"),
        "common_continue": MessageLookupByLibrary.simpleMessage("Pokračovat"),
        "common_days_in_week_short": m6,
        "common_diastolic_gt_systolic":
            MessageLookupByLibrary.simpleMessage("Vyšší než systolický"),
        "common_do_sync":
            MessageLookupByLibrary.simpleMessage("Synchronizovat"),
        "common_from": MessageLookupByLibrary.simpleMessage("Od"),
        "common_heart_rate_unit":
            MessageLookupByLibrary.simpleMessage("tepů/min"),
        "common_log_in": MessageLookupByLibrary.simpleMessage("Přihlásit se"),
        "common_measure": MessageLookupByLibrary.simpleMessage("Měřit"),
        "common_measure_now": MessageLookupByLibrary.simpleMessage("Měřit teď"),
        "common_measurement": MessageLookupByLibrary.simpleMessage("Měření"),
        "common_measurement_times": m7,
        "common_measurement_types": m8,
        "common_measurement_types_genitive": m9,
        "common_measurement_units_names": m10,
        "common_measurement_units_types": m11,
        "common_months": m12,
        "common_not_measured":
            MessageLookupByLibrary.simpleMessage("Nenaměřeno"),
        "common_overall": MessageLookupByLibrary.simpleMessage("Celkem"),
        "common_personal_measurement":
            MessageLookupByLibrary.simpleMessage("Vlastní měření"),
        "common_personal_record":
            MessageLookupByLibrary.simpleMessage("Vlastní zápis hodnot"),
        "common_plan_fulfillment":
            MessageLookupByLibrary.simpleMessage("Plnění plánu"),
        "common_plans_fulfillment_plural": m13,
        "common_plus_n_others": m14,
        "common_procedure": MessageLookupByLibrary.simpleMessage("Postup"),
        "common_save": MessageLookupByLibrary.simpleMessage("Uložit"),
        "common_show_calendar":
            MessageLookupByLibrary.simpleMessage("Zobrazit kalendář"),
        "common_to": MessageLookupByLibrary.simpleMessage("Do"),
        "common_today": MessageLookupByLibrary.simpleMessage("Dnes"),
        "common_understand": MessageLookupByLibrary.simpleMessage("Rozumím"),
        "common_when_code": m15,
        "common_when_day_name": m16,
        "common_wrong_value":
            MessageLookupByLibrary.simpleMessage("Nesprávná hodnota"),
        "configuration_screen_add_account":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "configuration_screen_appearance_label":
            MessageLookupByLibrary.simpleMessage("Vzhled"),
        "configuration_screen_auto_appearance_sublabel":
            MessageLookupByLibrary.simpleMessage("Automaticky"),
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
        "configuration_screen_setup_watch":
            MessageLookupByLibrary.simpleMessage(
                "Nastavit synchronizaci hodinek"),
        "configuration_screen_system_appearance_sublabel":
            MessageLookupByLibrary.simpleMessage("Vzhled dle systému"),
        "daily_when_time_reset_confirmation_confirm":
            MessageLookupByLibrary.simpleMessage("Resetovat na výchozí"),
        "daily_when_time_reset_confirmation_info":
            MessageLookupByLibrary.simpleMessage(
                "Můžete upravovat pouze ty denní doby, u kterých Váš lékař úpravy povolil."),
        "daily_when_time_reset_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Denní doby"),
        "dashboard_screen_all": MessageLookupByLibrary.simpleMessage("Vše"),
        "dashboard_screen_any_user_plan": MessageLookupByLibrary.simpleMessage(
            "Není nastaven žádný plán a historie měření neobsahuje žádná data."),
        "dashboard_screen_manual_measurement_info":
            MessageLookupByLibrary.simpleMessage(
                "Vlastní měření můžete spustit\ni mimo předepsaný plán."),
        "dashboard_screen_measurement_interval": m17,
        "dashboard_screen_measurement_periodical_interval": m18,
        "dashboard_screen_measurements_left": m19,
        "dashboard_screen_no_more_future_measurements":
            MessageLookupByLibrary.simpleMessage(
                "Žádné další plánované měření."),
        "dashboard_screen_no_more_measurements":
            MessageLookupByLibrary.simpleMessage(
                "Dnes plánované měření skončilo."),
        "dashboard_screen_no_todays_measurements":
            MessageLookupByLibrary.simpleMessage(
                "Dnes nemáte naplánované žádné měření."),
        "dashboard_screen_no_user_plan": MessageLookupByLibrary.simpleMessage(
            "Uživatel nemá nastaven plán a historie měření neobsahuje žádná data."),
        "dashboard_screen_periodical_measurements":
            MessageLookupByLibrary.simpleMessage("Periodické měření"),
        "dashboard_screen_todays_plan_finished": m20,
        "dashboard_screen_upcoming_measurement_info": m21,
        "device_search_screen_purpose_desc": m22,
        "device_search_screen_purpose_title": m23,
        "device_selector_unsupported_devices": MessageLookupByLibrary.simpleMessage(
            "Pro tento typ měření není podporováno žádné zařízení. Hodnoty odečtěte z manuálního měření."),
        "dialog_account_removal_confirmation_description": m24,
        "dialog_account_removal_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Odstranit účet z aplikace"),
        "dialog_req_localization_service_description":
            MessageLookupByLibrary.simpleMessage(
                "Aplikace vyžaduje povolení používat lokalizační službu na vyhledávaní zažírení v okolí."),
        "dialog_req_localization_service_go_to_settings":
            MessageLookupByLibrary.simpleMessage("Přejít do nastavení"),
        "dialog_req_localization_service_title":
            MessageLookupByLibrary.simpleMessage("Povolení lokalizační služby"),
        "dialog_req_notifications_description":
            MessageLookupByLibrary.simpleMessage(
                "Aplikace vyžaduje povolení notifikací, pokud chcete dostávat upozornění."),
        "dialog_req_notifications_go_to_settings":
            MessageLookupByLibrary.simpleMessage("Přejít do nastavení"),
        "dialog_req_notifications_title":
            MessageLookupByLibrary.simpleMessage("Povolení notifikací"),
        "find_device_not_found_desc": MessageLookupByLibrary.simpleMessage(
            "Pro opětovné vyhledávání stisknete na tlačítko opakovat"),
        "find_device_not_found_title":
            MessageLookupByLibrary.simpleMessage("Zařízení nenalezeno"),
        "find_device_repeat_search":
            MessageLookupByLibrary.simpleMessage("Opakovat"),
        "find_device_screen_device_connected":
            MessageLookupByLibrary.simpleMessage("Tlakoměr připojen"),
        "find_device_screen_device_reference":
            MessageLookupByLibrary.simpleMessage(
                "Stránky nemocnice o tlakoměru"),
        "find_device_screen_disabled_bt_btn_settings":
            MessageLookupByLibrary.simpleMessage("Nastavení"),
        "find_device_screen_disabled_bt_desc":
            MessageLookupByLibrary.simpleMessage(
                "Pro spojení s přístrojem je potřeba mít Bluetooth zapnutý."),
        "find_device_screen_disabled_bt_title":
            MessageLookupByLibrary.simpleMessage("Bluetooth je vypnutý"),
        "find_device_screen_not_granted_bt_btn_settings":
            MessageLookupByLibrary.simpleMessage("Povolit"),
        "find_device_screen_not_granted_bt_desc":
            MessageLookupByLibrary.simpleMessage(
                "Aplikace vyžaduje povolení používat Bluetooth pro komunikaci se zařízeními."),
        "find_device_screen_not_granted_bt_title":
            MessageLookupByLibrary.simpleMessage("Bluetooth zakázán "),
        "find_device_screen_pairing_device":
            MessageLookupByLibrary.simpleMessage(
                "Probíhá párování s tlakoměrem..."),
        "find_device_screen_searching_device":
            MessageLookupByLibrary.simpleMessage("Hledání zařízení..."),
        "find_device_screen_searching_tonometer":
            MessageLookupByLibrary.simpleMessage("Hledání tlakoměru..."),
        "find_device_screen_step1": m25,
        "find_device_screen_step1_p": m26,
        "find_device_screen_step2": m27,
        "find_device_screen_step2_p": MessageLookupByLibrary.simpleMessage(
            "Počkejte, na výzvu k párování"),
        "find_device_screen_step3": MessageLookupByLibrary.simpleMessage(
            "Po meření stiskněte opět akční tlačítko"),
        "find_device_screen_step3_p":
            MessageLookupByLibrary.simpleMessage("Párování s tlakoměrem"),
        "find_device_screen_step4": MessageLookupByLibrary.simpleMessage(
            "Počkejte na přenesení výsledků z tlakoměru"),
        "find_device_screen_step4_p": m28,
        "find_device_screen_step5_p": MessageLookupByLibrary.simpleMessage(
            "Počkejte na přenesení výsledků z tlakoměru"),
        "find_device_screen_sync_results": MessageLookupByLibrary.simpleMessage(
            "Probíhá přenos dat z tlakoměru..."),
        "find_device_screen_waiting_on_measurement":
            MessageLookupByLibrary.simpleMessage("Čekáme až se změříte..."),
        "hospital_selection_dialog_measurement_for":
            MessageLookupByLibrary.simpleMessage("Měření pro"),
        "hospital_selector_search_for_account":
            MessageLookupByLibrary.simpleMessage("Název účtu..."),
        "license_detail_screen_title":
            MessageLookupByLibrary.simpleMessage("Detail licence"),
        "licenses_menu_subtitle":
            MessageLookupByLibrary.simpleMessage("Licence použitých knihoven"),
        "licenses_menu_title":
            MessageLookupByLibrary.simpleMessage("Použité licence"),
        "licenses_screen_title":
            MessageLookupByLibrary.simpleMessage("Použité licence"),
        "manual_measurement_screen_measurement_time":
            MessageLookupByLibrary.simpleMessage("Čas odečtu"),
        "manual_measurement_screen_title":
            MessageLookupByLibrary.simpleMessage("Vlastní zápis hodnot"),
        "manual_measurement_screen_type":
            MessageLookupByLibrary.simpleMessage("Typ"),
        "manual_screen_title": MessageLookupByLibrary.simpleMessage("Příručka"),
        "measurement_dialog_device_desc": m29,
        "measurement_screen_today_n_measurements": m30,
        "measurement_screen_tomorrow_n_measurements": m31,
        "measurement_screen_upcomming_n_measurements": m32,
        "measurement_summary_screen_disallow_to_send":
            MessageLookupByLibrary.simpleMessage("Neodeslat výsledky"),
        "measurement_summary_screen_exceeded_values":
            MessageLookupByLibrary.simpleMessage(
                "Pozor, vaše naměřené hodnoty překročily nastavené meze, kontaktujte vašeho lékaře!"),
        "measurement_summary_screen_no_data_desc":
            MessageLookupByLibrary.simpleMessage(
                "Zařízení nedodalo žádné výsledky měření."),
        "measurement_summary_screen_no_data_repeat_measurement":
            MessageLookupByLibrary.simpleMessage("Opakovat měření"),
        "measurement_summary_screen_result_success_desc":
            MessageLookupByLibrary.simpleMessage(
                "Máte hotovo! Výsledek se připíše po potvrzení."),
        "measurement_summary_screen_send_results":
            MessageLookupByLibrary.simpleMessage("Odeslat výsledek měření"),
        "measurement_summary_screen_success_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Výsledky budou odeslány po potvrzení"),
        "measurement_summary_screen_success_title":
            MessageLookupByLibrary.simpleMessage(
                "Měření bylo úspěšně dokončeno"),
        "measurement_summary_screen_sync_error_desc":
            MessageLookupByLibrary.simpleMessage(
                "Nastala chyba synchronizace."),
        "metering_screen_add_device":
            MessageLookupByLibrary.simpleMessage("Přidat zařízení"),
        "metering_screen_device_removal_button_confirm":
            MessageLookupByLibrary.simpleMessage("Odstranit zařízení"),
        "metering_screen_device_removal_message":
            MessageLookupByLibrary.simpleMessage(
                "Zařízení bude odstraněno. Pro opětovné používání ho budete muset znovu spárovat s aplikací."),
        "metering_screen_device_removal_title":
            MessageLookupByLibrary.simpleMessage("Odstranit zařízení"),
        "metering_screen_lended_devices":
            MessageLookupByLibrary.simpleMessage("Zapůjčené zařízení"),
        "metering_screen_no_added_device_yet": MessageLookupByLibrary.simpleMessage(
            "Před prvním měřením je potřeba spárovat aplikaci s odpovídajícím zařízením."),
        "metering_screen_no_eligible_to_measure_with_uknow_device":
            MessageLookupByLibrary.simpleMessage(
                "Na měření bez zapůjčeného přístroje nemáte oprávnění"),
        "metering_screen_personal_devices":
            MessageLookupByLibrary.simpleMessage("Vlastní zařízení"),
        "new_watch_assigned_description": MessageLookupByLibrary.simpleMessage(
            "Máte přiřazené hodinky. Aktivujte prosím automatický přenos naměřených dat z hodinek v nastavení aplikace."),
        "new_watch_assigned_title":
            MessageLookupByLibrary.simpleMessage("Konfigurace hodinek"),
        "notification_periodical_frequency_from_to": m33,
        "notification_widget_plan_changed_desc": m34,
        "notification_widget_plan_changed_for_user_desc": m35,
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
        "onboarding_account_added_screen_user_added": m36,
        "onboarding_add_account_screen_add_account_button":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "onboarding_add_account_screen_add_account_subtitle":
            MessageLookupByLibrary.simpleMessage(
                "Pro používání aplikace musíte mít\naktivní alespoň jeden účet."),
        "onboarding_add_account_screen_add_account_text1":
            MessageLookupByLibrary.simpleMessage(
                "Vyhledejte místo kde jste evidován"),
        "onboarding_add_account_screen_add_account_text2":
            MessageLookupByLibrary.simpleMessage(
                "Přihlaste se přes dvoufaktorové ověření"),
        "onboarding_add_account_screen_add_account_text3":
            MessageLookupByLibrary.simpleMessage("Můžete se začít měřit"),
        "onboarding_add_account_screen_add_account_title":
            MessageLookupByLibrary.simpleMessage("Přidat účet"),
        "open_manual_button": MessageLookupByLibrary.simpleMessage(
            "Otevřít uživatelskou příručku"),
        "overall_health_values": m37,
        "permission_explanations": m38,
        "permission_names": m39,
        "register_device_detail_registration_fail_message": m40,
        "register_device_detail_registration_fail_title":
            MessageLookupByLibrary.simpleMessage("Chyba"),
        "register_device_detail_screen_assigned_id":
            MessageLookupByLibrary.simpleMessage("Označení"),
        "register_device_detail_screen_assigned_id_hint":
            MessageLookupByLibrary.simpleMessage(
                "Například zařízení v kuchyni"),
        "register_device_detail_screen_bluetooth_address":
            MessageLookupByLibrary.simpleMessage("Bluetooth adresa"),
        "register_device_detail_screen_button_register":
            MessageLookupByLibrary.simpleMessage("Registrovat"),
        "register_device_detail_screen_device":
            MessageLookupByLibrary.simpleMessage("Zařízení"),
        "register_device_detail_screen_identifier":
            MessageLookupByLibrary.simpleMessage("Technický Identifikátor"),
        "register_device_detail_screen_not_filled_field":
            MessageLookupByLibrary.simpleMessage("Nevyplněné pole"),
        "register_device_detail_screen_title":
            MessageLookupByLibrary.simpleMessage("Zařízení k registraci"),
        "register_device_success_screen_desc":
            MessageLookupByLibrary.simpleMessage(
                "Zařízení bylo úspěšně registrováno."),
        "result_removal_confirmation_desc": m41,
        "result_removal_confirmation_title":
            MessageLookupByLibrary.simpleMessage("Odstranit výsledek"),
        "result_removal_confirmation_title_button_confirm":
            MessageLookupByLibrary.simpleMessage("Odstranit výsledek"),
        "results_history_screen_plan_of_day":
            MessageLookupByLibrary.simpleMessage("Plán měření dne"),
        "results_measurements_when_selector_title":
            MessageLookupByLibrary.simpleMessage("Plnění plánu"),
        "results_plan_fulfilled_on": m42,
        "results_plan_no_measurement_needed":
            MessageLookupByLibrary.simpleMessage(
                "Plán nevyžadoval žádné měření"),
        "results_screen_measurements_completed": m43,
        "results_screen_no_historic_data": MessageLookupByLibrary.simpleMessage(
            "Historie měření neobsahuje žádná data."),
        "results_screen_no_permission_to_see_results":
            MessageLookupByLibrary.simpleMessage(
                "Na zobrazení údajů nemáte potřebné oprávnění"),
        "results_screen_no_results": m44,
        "results_screen_no_results_in_plans": m45,
        "results_screen_results_title":
            MessageLookupByLibrary.simpleMessage("Výsledky"),
        "server_error_desc": MessageLookupByLibrary.simpleMessage(
            "Zde je něco v nepořádku. Zkuste akci opakovat později."),
        "server_error_title": MessageLookupByLibrary.simpleMessage("Chyba"),
        "session_expired_description": m46,
        "session_expired_title":
            MessageLookupByLibrary.simpleMessage("Problém s přihlášením"),
        "shortness_of_breath_values": m47,
        "sync_failed_screen_sub_title": m48,
        "sync_failed_screen_title":
            MessageLookupByLibrary.simpleMessage("Synchronizace"),
        "sync_failed_screen_waiting_on_sync":
            MessageLookupByLibrary.simpleMessage("Čeká na synchronizaci"),
        "sync_widget_sync_failed_desc": m49,
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
        "user_detail_screen_debug_logs_sent":
            MessageLookupByLibrary.simpleMessage(
                "Vývojářská data byla úspěšně odeslána"),
        "user_detail_screen_measurement_plans":
            MessageLookupByLibrary.simpleMessage("Plány měření"),
        "user_detail_screen_register_device_button":
            MessageLookupByLibrary.simpleMessage("Registrovat zařízení"),
        "user_detail_screen_remove_account":
            MessageLookupByLibrary.simpleMessage("Odstranit účet z aplikace"),
        "user_detail_screen_send_debug_logs":
            MessageLookupByLibrary.simpleMessage("Odeslat vývojářská data"),
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
        "user_details_screen_plan_active_from_date": m50,
        "user_details_screen_plan_active_from_to_date": m51,
        "user_selection_dialog_measurement_in_hospital": m52,
        "watch_setup_explanation": MessageLookupByLibrary.simpleMessage(
            "Pro správnou funkčnost přenosu dat z hodinek je nutné udělit aplikaci následující oprávnění:"),
        "watch_setup_failed": MessageLookupByLibrary.simpleMessage(
            "Nastavení hodinek se nezdařilo. Ujistěte se, že aplikace má potřebná oprávnění, je aktivní bluetooth telefonu a hodinky jsou zapnuté a v dosahu. Potom zkuste akci opakovat."),
        "watch_setup_menu_title": MessageLookupByLibrary.simpleMessage(
            "Nastavit přenos dat z hodinek"),
        "watch_setup_partial": MessageLookupByLibrary.simpleMessage(
            "Je aktivní přenos dat pouze z některých hodinek. Zkuste prosím aktivaci provést znovu. Ujistěte se, že všechny Vaše přiřazené hodinky jsou v dosahu."),
        "watch_setup_screen_title":
            MessageLookupByLibrary.simpleMessage("Nastavení hodinek"),
        "watch_setup_turn_on_devices": MessageLookupByLibrary.simpleMessage(
            "Pro aktivaci přenosu dat musí být přiřazené zařízení zapnuté a v dosahu telefonu."),
        "watch_setup_turn_on_synchronization":
            MessageLookupByLibrary.simpleMessage(
                "Po udělení oprávnění prosím aktivujte periodický přenos dat:"),
        "watch_synchronization_failed": MessageLookupByLibrary.simpleMessage(
            "Přenos dat z hodinek se nezdařil. Je aktivní bluetooth telefonu, jsou hodinky zapnuté a v dosahu?"),
        "watch_synchronization_toggle_label":
            MessageLookupByLibrary.simpleMessage(
                "Aktivovat periodický přenos dat")
      };
}
