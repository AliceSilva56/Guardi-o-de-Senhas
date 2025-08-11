import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/password_model.dart';
import 'package:crypto/crypto.dart'; // adicionar crypto se quiser hash mais tarde

class PasswordService {
  static const String passwordsBoxName = 'guardiao_passwords';
  static const String settingsBoxName = 'guardiao_settings';
  static const String masterKey = 'master_password_hash';
  static const String confidentialModeKey = 'confidential_mode_enabled';

  /// Inicializa o Hive - chame no main()
  static Future<void> init() async {
    await Hive.initFlutter.call(); // se estiver usando hive_flutter, caso contrário chame Hive.init
    await Hive.openBox(passwordsBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // ---------------- Master Password ----------------
  /// Define senha mestra (armazenada como hash básico; para produção usar PBKDF2/Argon2)
  static Future<void> setMasterPassword(String plain) async {
    final box = Hive.box(settingsBoxName);
    final hash = sha256.convert(utf8.encode(plain)).toString();
    await box.put(masterKey, hash);
  }

  /// Verifica senha mestra
  static bool verifyMasterPassword(String plain) {
    final box = Hive.box(settingsBoxName);
    final saved = box.get(masterKey);
    if (saved == null) return false;
    final hash = sha256.convert(utf8.encode(plain)).toString();
    return saved == hash;
  }

  /// Checa se já existe master
  static bool hasMasterPassword() {
    final box = Hive.box(settingsBoxName);
    return box.containsKey(masterKey);
  }

  // ---------------- Confidential Mode (global flag) ----------------
  static bool isConfidentialModeEnabled() {
    final box = Hive.box(settingsBoxName);
    return box.get(confidentialModeKey, defaultValue: false) as bool;
  }

  static Future<void> setConfidentialModeEnabled(bool enabled) async {
    final box = Hive.box(settingsBoxName);
    await box.put(confidentialModeKey, enabled);
  }

  // ---------------- CRUD ----------------
  static Future<void> addPassword(PasswordModel pwd) async {
    final box = Hive.box(passwordsBoxName);
    await box.put(pwd.id, pwd.toMap());
  }

  static Future<void> editPassword(String id, PasswordModel pwd) async {
    final box = Hive.box(passwordsBoxName);
    if (box.containsKey(id)) {
      await box.put(id, pwd.toMap());
    }
  }

  static Future<void> deletePassword(String id) async {
    final box = Hive.box(passwordsBoxName);
    await box.delete(id);
  }

  static List<PasswordModel> getAllPasswords({bool includeConfidential = false}) {
    final box = Hive.box(passwordsBoxName);
    return box.keys.map((k) => PasswordModel.fromMap(k.toString(), box.get(k))).where((p) {
      if (p.confidential && !includeConfidential) return false;
      return true;
    }).toList();
  }

  static List<PasswordModel> getByCategory(String category, {bool includeConfidential = false}) {
    if (category == 'all') return getAllPasswords(includeConfidential: includeConfidential);
    return getAllPasswords(includeConfidential: includeConfidential).where((p) => p.category == category).toList();
  }

  static List<PasswordModel> searchPasswords(String query, {bool includeConfidential = false}) {
    query = query.toLowerCase();
    return getAllPasswords(includeConfidential: includeConfidential).where((p) =>
      p.siteName.toLowerCase().contains(query) ||
      p.username.toLowerCase().contains(query) ||
      (p.notes?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  // ---------------- Generator & Strength ----------------
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += upper;
    if (includeLowercase) chars += lower;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) return '';

    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static Map<String, String> calculatePasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    if (password.split('').toSet().length >= password.length * 0.7) score++;

    if (score <= 3) return {'level': 'weak', 'text': 'Fraca'};
    if (score <= 5) return {'level': 'medium', 'text': 'Média'};
    return {'level': 'strong', 'text': 'Forte'};
  }

  // ---------------- Backup ----------------
  static String exportBackup() {
    final box = Hive.box(passwordsBoxName);
    final settings = Hive.box(settingsBoxName).toMap();
    final passwords = box.toMap().map((k, v) => MapEntry(k.toString(), v));
    final backupData = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'passwords': passwords,
      'settings': settings,
    };
    final jsonStr = jsonEncode(backupData);
    final encoded = base64Encode(utf8.encode(jsonStr));
    return encoded;
  }

  static Future<void> importBackup(String encodedData, {bool overwrite = false}) async {
    try {
      final decoded = utf8.decode(base64Decode(encodedData));
      final data = jsonDecode(decoded) as Map<String, dynamic>;
      final box = Hive.box(passwordsBoxName);

      if (overwrite) {
        await box.clear();
        (data['passwords'] as Map).forEach((k, v) => box.put(k, v));
      } else {
        (data['passwords'] as Map).forEach((k, v) {
          if (!box.containsKey(k)) box.put(k, v);
        });
      }

      final settingsBox = Hive.box(settingsBoxName);
      (data['settings'] as Map?)?.forEach((k, v) => settingsBox.put(k, v));
    } catch (e) {
      rethrow;
    }
  }
}
