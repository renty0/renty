import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SecureStorageService
//
// All SENSITIVE user data (JWTs, user PII) is stored here, backed by:
//   • Android: EncryptedSharedPreferences / Android Keystore (AES256)
//   • iOS: Keychain
//
// NON-SENSITIVE UI prefs (onboarding step, theme, language) remain in
// SharedPreferences as before — they carry no security risk.
// ─────────────────────────────────────────────────────────────────────────────
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // AES256 via Android Keystore
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Key constants ─────────────────────────────────────────────────────────
  static const _keyToken        = 'secure_token';
  static const _keyRefreshToken = 'secure_refresh_token';
  static const _keyUserId       = 'secure_user_id';
  static const _keyUserEmail    = 'secure_user_email';
  static const _keyUserName     = 'secure_user_name';
  static const _keyUserFirstName = 'secure_user_firstName';
  static const _keyUserLastName  = 'secure_user_lastName';
  static const _keyUserPhone    = 'secure_user_phone';

  // ── Token ─────────────────────────────────────────────────────────────────
  static Future<String?> getToken()        async => _storage.read(key: _keyToken);
  static Future<void>    setToken(String v) async => _storage.write(key: _keyToken, value: v);
  static Future<void>    deleteToken()     async => _storage.delete(key: _keyToken);

  // ── Refresh Token ─────────────────────────────────────────────────────────
  static Future<String?> getRefreshToken()        async => _storage.read(key: _keyRefreshToken);
  static Future<void>    setRefreshToken(String v) async => _storage.write(key: _keyRefreshToken, value: v);
  static Future<void>    deleteRefreshToken()     async => _storage.delete(key: _keyRefreshToken);

  // ── User ID ───────────────────────────────────────────────────────────────
  static Future<String?> getUserId()        async => _storage.read(key: _keyUserId);
  static Future<void>    setUserId(String v) async => _storage.write(key: _keyUserId, value: v);
  static Future<void>    deleteUserId()     async => _storage.delete(key: _keyUserId);

  // ── User Email ────────────────────────────────────────────────────────────
  static Future<String?> getUserEmail()        async => _storage.read(key: _keyUserEmail);
  static Future<void>    setUserEmail(String v) async => _storage.write(key: _keyUserEmail, value: v);
  static Future<void>    deleteUserEmail()     async => _storage.delete(key: _keyUserEmail);

  // ── User Name (firstName) ─────────────────────────────────────────────────
  static Future<String?> getUserName()        async => _storage.read(key: _keyUserName);
  static Future<void>    setUserName(String v) async => _storage.write(key: _keyUserName, value: v);
  static Future<void>    deleteUserName()     async => _storage.delete(key: _keyUserName);

  // ── User firstName (alias) ────────────────────────────────────────────────
  static Future<String?> getUserFirstName()        async => _storage.read(key: _keyUserFirstName);
  static Future<void>    setUserFirstName(String v) async => _storage.write(key: _keyUserFirstName, value: v);
  static Future<void>    deleteUserFirstName()     async => _storage.delete(key: _keyUserFirstName);

  // ── User Last Name ────────────────────────────────────────────────────────
  static Future<String?> getUserLastName()        async => _storage.read(key: _keyUserLastName);
  static Future<void>    setUserLastName(String v) async => _storage.write(key: _keyUserLastName, value: v);
  static Future<void>    deleteUserLastName()     async => _storage.delete(key: _keyUserLastName);

  // ── User Phone ────────────────────────────────────────────────────────────
  static Future<String?> getUserPhone()        async => _storage.read(key: _keyUserPhone);
  static Future<void>    setUserPhone(String v) async => _storage.write(key: _keyUserPhone, value: v);
  static Future<void>    deleteUserPhone()     async => _storage.delete(key: _keyUserPhone);

  // ── Convenience: clear ALL sensitive data (on logout) ────────────────────
  static Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteUserId(),
      deleteUserEmail(),
      deleteUserName(),
      deleteUserFirstName(),
      deleteUserLastName(),
      deleteUserPhone(),
    ]);
  }

  // ── Quick synchronous-style check (reads cached value or null) ────────────
  // NOTE: Because secure storage is always async, callers that MUST be
  // synchronous (e.g. isAuthenticated getter) should cache the token in
  // memory after the first async read.  See ApiService._cachedToken.
}
