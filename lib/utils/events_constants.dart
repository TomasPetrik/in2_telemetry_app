class EventsConstants {
  /* OMRON CONNECTION BLOC */
  static const eventBluetoothDisabled = 'EVENT_BLUETOOTH_DISABLED';
  static const eventNoBTPermissionsGranted = 'EVENT_NO_BT_PERMISSIONS_GRANTED';
  static const eventDeviceSearchingStart = 'EVENT_DEVICE_SEARCHING_START';
  static const eventDeviceSearchingStop = 'EVENT_DEVICE_SEARCHING_STOP';
  static const eventDeviceFound = 'EVENT_DEVICE_FOUND';
  static const eventDeviceConnected = 'EVENT_DEVICE_CONNECTED';
  static const eventDeviceVerified = 'EVENT_DEVICE_VERIFIED';
  static const eventDeviceVerificationFailed =
      'EVENT_DEVICE_VERIFICATION_FAILED';
  static const eventDevicePairing = 'EVENT_DEVICE_PAIRING';
  static const eventDeviceSyncing = 'EVENT_DEVICE_SYNCING';
  static const eventDevicePaired = 'EVENT_DEVICE_PAIRED';
  static const eventDeviceSynced = 'EVENT_DEVICE_SYNCED';

  /* OAUTH WEB SCREEN */
  static const eventOAuthWebPageStarted = 'EVENT_OAUTH_WEB_PAGE_STARTED';
  static const eventOAuthWebPageLoaded = 'EVENT_OAUTH_WEB_PAGE_LOADED';
  static const eventOAuthWebErr = 'EVENT_OAUTH_WEB_ERR';
  static const eventOAuthOpenEGoverment = 'EVENT_OAUTH_OIPEN_EGOVERMENT';
  static const eventOAuthWebPageCancelled = 'EVENT_OAUTH_WEB_PAGE_CANCELLED';

  /* AUTH BLOC, CONTENT BLOC */

  static const eventUserOpenAuthReqInBrowser =
      'EVENT_USER_OPEN_AUTH_REQ_IN_BROWSER';

  static const eventUserAuthenticating = 'EVENT_USER_AUTHENTICATICATING';
  static const eventUserUnauthenticated = 'EVENT_USER_UNAUTHENTICATED';
  static const eventUserAuthenticated = 'EVENT_USER_AUTHENTICATED';
  static const eventUserLoadingInfo = 'EVENT_USER_LOADING_INFO';
  static const eventUserLoaded = 'EVENT_USER_LOADED';
  static const eventUserAuthCancelled = 'EVENT_USER_AUTH_CANCELLED';
  static const eventUserErrorDataLoaded = 'EVENT_USER_ERROR_DATA_LOADED';
  static const eventUserRemoved = 'EVENT_USER_REMOVED';
  static const eventUserSwitchedToActive = 'EVENT_USER_SWITCHED_TO_ACTIVE';
  static const eventUserContentDefaultAutoSet = 'EVENT_USER_AUTO_DEFAULT_SET';
  static const eventUserAdded = 'EVENT_USER_ADDED';

  /* MISC */
  static const eventAppearanceChanged = 'EVENT_APPEARANCE_CHANGED';
  static const eventDaylightAppearanceChanged =
      'EVENT_DAYLIGHT_APPEARANCE_CHANGED';
  static const eventNoUserContent = 'EVENT_NO_USER_CONTENT';
  static const eventNoLastUserDetected = 'EVENT_NO_LAST_USER_DETECTED';
  static const eventSwitchToMultiuser = 'EVENT_SWITCH_TO_MULTIUSER';
  static const eventAutoRefreshDashboard = 'EVENT_AUTO_REFRESH_DASHBOARD';

  /* REGISTER DEVICE BLOC */
  static const eventDeviceRegistering = 'EVENT_DEVICE_REGISTERING';
  static const eventDeviceRegistered = 'EVENT_DEVICE_REGISTERED';
  static const eventDeviceAlreadyRegistered = 'EVENT_DEVICE_ALREADY_REGISTERED';
  static const eventDeviceRegistrationFailed =
      'EVENT_DEVICE_REGISTRATION_FAILED';

  /* MEASUREMENT SUMMARY  */
  static const eventMeasurementSent = 'EVENT_MEASUREMENT_SENT';
  static const eventMeasurementRepeat = 'EVENT_MEASUREMENT_REPEAT';
  static const eventMeasurementWontSend = 'EVENT_MEASUREMENT_WONT_SEND';

  /* NOTIFICATION PERMISSION STATUS  */
  static const eventNotificationPermissionStatus =
      'EVENT_NOTIFICATION_PERMISSION_STATUS';
}
