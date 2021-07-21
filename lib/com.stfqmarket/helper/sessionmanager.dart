
import 'package:qbsdonation/com.stfqmarket/helper/generator.dart';
import 'package:qbsdonation/com.stfqmarket/objects/sessiondata.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionManager {
  static const USER_EMAIL = 'session_user_email';
  static const USER_FULLNAME = 'session_user_fullname';
  static const USER_PHONE = 'session_user_phone';
  static const USER_REFERRAL = 'session_user_referral';
  static const USER_LEVEL = 'session_user_level';
  static const EXPIRES_IN = 'session_expires_in';
  static const TOKEN = 'session_token';
  static const LOGIN_STATE = 'session_login_state';

  static Future<bool> get loginState async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(LOGIN_STATE) ?? false;
  }

  static Future<SessionData> get sessionData async {
    try {
      final pref = await SharedPreferences.getInstance();
      return SessionData(
          pref.get(USER_EMAIL), pref.get(USER_FULLNAME), pref.get(USER_PHONE),
          pref.get(USER_REFERRAL), pref.get(USER_LEVEL), pref.get(EXPIRES_IN), pref.get(TOKEN));
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// Create temporary userId for anonymous customer. Return generated temporary UserId.
  static Future<String> createTempUserId() async {
    String tempUserId = Generator().generateRandomId();

    final pref = await SharedPreferences.getInstance();
    await pref.setString(USER_EMAIL, tempUserId);
    return tempUserId;
  }

  /// return true if session created successfully
  static Future<bool> createSession(SessionData sessionData) async {
    try {
      final pref = await SharedPreferences.getInstance();
      return await pref.setString(USER_EMAIL, sessionData.email)
          && await pref.setString(USER_FULLNAME, sessionData.fullName)
          && await pref.setString(USER_PHONE, sessionData.phone)
          && await pref.setString(USER_REFERRAL, sessionData.referral)
          && await pref.setInt(USER_LEVEL, sessionData.level)
          && await pref.setString(EXPIRES_IN, sessionData.expiresIn)
          && await pref.setString(TOKEN, sessionData.token)

          && await pref.setBool(LOGIN_STATE, true);
    } catch (e) {
      print(e);
    }
    return false;
  }

  static int _logoutTryCount = 0;
  static Future<void> logoutSession() async {
    try {
      final pref = await SharedPreferences.getInstance();
      pref.remove(USER_EMAIL);
      pref.remove(USER_FULLNAME);
      pref.remove(USER_PHONE);
      pref.remove(USER_REFERRAL);
      pref.remove(USER_LEVEL);
      pref.remove(EXPIRES_IN);
      pref.remove(TOKEN);

      pref.setBool(LOGIN_STATE, false);
      _logoutTryCount = 0;
    } catch (e) {
      print(e);
      _logoutTryCount++;
      if (_logoutTryCount < 3) logoutSession();
    }
  }
}