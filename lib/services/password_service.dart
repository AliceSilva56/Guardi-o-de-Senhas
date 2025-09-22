// Arquivo password_service.dart para o serviço de gerenciamento de senhas do Guardião de Senhas
// Este serviço utiliza o Hive para armazenar senhas de forma segura, incluindo funcionalidades para backup e restauração, geração de senhas, verificação de força de senha e modo confidencial.

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/password_model.dart';
import 'package:crypto/crypto.dart'; // adicionar crypto se quiser hash mais tarde

class PasswordService {
  static const String passwordsBoxName = 'guardiao_passwords';
  static const String settingsBoxName = 'settings';
  static const String masterKey = 'master_password_hash';
  static const String confidentialModeKey = 'confidential_mode_enabled';
  static const String confidentialPasswordKey = 'confidential_password_hash';

  static String? _masterPassword;

  // Helper methods to get boxes
  static Box _getPasswordsBox() => Hive.box(passwordsBoxName);
  static Box _getSettingsBox() => Hive.box(settingsBoxName);

  // ---------------- Master Password ----------------
  /// Define senha mestra (armazenada como hash básico; para produção usar PBKDF2/Argon2)
  static Future<void> setMasterPassword(String plain) async {
    try {
      _masterPassword = plain;
      final box = _getSettingsBox();
      final hash = sha256.convert(utf8.encode(plain)).toString();
      await box.put(masterKey, hash);
    } catch (e) {
      debugPrint('Error setting master password: $e');
      rethrow;
    }
  }

  /// Verifica senha mestra
  static bool verifyMasterPassword(String plain) {
    try {
      final box = _getSettingsBox();
      final saved = box.get(masterKey);
      if (saved == null) return false;
      final hash = sha256.convert(utf8.encode(plain)).toString();
      return saved == hash;
    } catch (e) {
      debugPrint('Error verifying master password: $e');
      return false;
    }
  }

  /// Checa se já existe master
  static bool hasMasterPassword() {
    try {
      final box = _getSettingsBox();
      return box.containsKey(masterKey);
    } catch (e) {
      debugPrint('Error checking master password: $e');
      return false;
    }
  }

  // ---------------- Confidential Mode (global flag) ----------------
  static bool isConfidentialModeEnabled() {
    try {
      final box = _getSettingsBox();
      return box.get(confidentialModeKey, defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Error checking confidential mode: $e');
      return false;
    }
  }

  static Future<void> setConfidentialModeEnabled(bool enabled) async {
    try {
      final box = _getSettingsBox();
      await box.put(confidentialModeKey, enabled);
    } catch (e) {
      debugPrint('Error setting confidential mode: $e');
      rethrow;
    }
  }

  // ---------------- Confidential Password ----------------
  /// Define senha do modo confidencial
  static Future<void> setConfidentialPassword(String plain) async {
    try {
      final box = _getSettingsBox();
      final hash = sha256.convert(utf8.encode(plain)).toString();
      await box.put(confidentialPasswordKey, hash);
    } catch (e) {
      debugPrint('Error setting confidential password: $e');
      rethrow;
    }
  }

  /// Verifica senha do modo confidencial
  static bool verifyConfidentialPassword(String plain) {
    try {
      final box = _getSettingsBox();
      final saved = box.get(confidentialPasswordKey);
      if (saved == null) return false;
      final hash = sha256.convert(utf8.encode(plain)).toString();
      return saved == hash;
    } catch (e) {
      debugPrint('Error verifying confidential password: $e');
      return false;
    }
  }

  /// Checa se já existe senha do modo confidencial
  static bool hasConfidentialPassword() {
    try {
      final box = _getSettingsBox();
      return box.containsKey(confidentialPasswordKey);
    } catch (e) {
      debugPrint('Error checking confidential password: $e');
      return false;
    }
  }

  // ---------------- CRUD ----------------
  /// Adiciona uma nova senha ao Hive
  static Future<void> addPassword(PasswordModel pwd) async {
    try {
      final box = _getPasswordsBox();
      await box.put(pwd.id, pwd.toMap());
    } catch (e) {
      debugPrint('Error adding password: $e');
      rethrow;
    }
  }

  static Future<void> editPassword(String id, PasswordModel pwd) async {
    try {
      final box = _getPasswordsBox();
      if (box.containsKey(id)) {
        await box.put(id, pwd.toMap());
      } else {
        throw Exception('Password with id $id not found');
      }
    } catch (e) {
      debugPrint('Error editing password: $e');
      rethrow;
    }
  }

  static Future<void> deletePassword(String id) async {
    try {
      final box = _getPasswordsBox();
      if (box.containsKey(id)) {
        await box.delete(id);
      } else {
        throw Exception('Password with id $id not found');
      }
    } catch (e) {
      debugPrint('Error deleting password: $e');
      rethrow;
    }
  }

  static Future<bool> backupPasswords(String backupPath) async {
    try {
      final box = _getPasswordsBox();
      final backupFile = File(backupPath);
      await backupFile.writeAsString(jsonEncode(box.toMap()));
      return true;
    } catch (e) {
      debugPrint('Error backing up passwords: $e');
      return false;
    }
  }

  static Future<bool> restorePasswords(String backupPath) async {
    try {
      final box = _getPasswordsBox();
      final backupFile = File(backupPath);
      final data = await backupFile.readAsString();
      final Map<String, dynamic> passwords = jsonDecode(data);

      await box.clear();
      await box.putAll(passwords);

      return true;
    } catch (e) {
      debugPrint('Error restoring passwords: $e');
      return false;
    }
  }

  static List<PasswordModel> getAllPasswords({bool includeConfidential = false}) {
    try {
      final box = _getPasswordsBox();
      final List<PasswordModel> passwords = [];

      box.toMap().forEach((key, value) {
        try {
          final password = PasswordModel.fromMap(key.toString(), value);
          passwords.add(password);
        } catch (e) {
          debugPrint('Error parsing password $key: $e');
        }
      });

      debugPrint('Total de senhas no banco de dados: ${passwords.length}');
      debugPrint('Senhas confidenciais: ${passwords.where((p) => p.confidential || p.isConfidential).length}');
      debugPrint('Senhas normais: ${passwords.where((p) => !p.confidential && !p.isConfidential).length}');

      return passwords;
    } catch (e) {
      debugPrint('Error getting all passwords: $e');
      return [];
    }
  }

  static List<PasswordModel> getByCategory(String category, {bool includeConfidential = false}) {
    final allPasswords = getAllPasswords();
    
    if (category == 'all') {
      return includeConfidential 
          ? allPasswords 
          : allPasswords.where((p) => !p.confidential && !p.isConfidential).toList();
    }
    
    final filtered = allPasswords.where((p) => p.category == category).toList();
    
    return includeConfidential 
        ? filtered 
        : filtered.where((p) => !p.confidential && !p.isConfidential).toList();
  }

  static List<PasswordModel> searchPasswords(String query, {bool includeConfidential = false}) {
    try {
      final allPasswords = getAllPasswords();
      final queryLower = query.toLowerCase();
      
      // Filtra as senhas que correspondem à pesquisa
      var results = allPasswords.where((password) =>
        password.siteName.toLowerCase().contains(queryLower) ||
        password.username.toLowerCase().contains(queryLower) ||
        (password.notes?.toLowerCase().contains(queryLower) ?? false)
      ).toList();
      
      // Aplica o filtro de confidencialidade se necessário
      if (!includeConfidential) {
        results = results.where((p) => !p.confidential && !p.isConfidential).toList();
      }
      
      debugPrint('Resultados da busca: ${results.length} senhas encontradas');
      
      return results;
    } catch (e) {
      debugPrint('Error searching passwords: $e');
      return [];
    }
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

  // ---------------- Backup e Restauração ----------------
  /// Verifica se uma senha com os mesmos dados já existe
  Future<bool> passwordExists({
    required String siteName,
    required String username,
    required String password,
  }) async {
    try {
      final box = Hive.box<Map<dynamic, dynamic>>(passwordsBoxName);
      final allPasswords = box.values.toList();
      
      return allPasswords.any((p) {
        final pwdSiteName = p['siteName']?.toString().toLowerCase() ?? '';
        final pwdUsername = p['username']?.toString().toLowerCase() ?? '';
        final pwdPassword = p['password']?.toString() ?? '';
        
        return pwdSiteName == siteName.toLowerCase() &&
               pwdUsername == username.toLowerCase() &&
               pwdPassword == password;
      });
    } catch (e) {
      debugPrint('Erro ao verificar senha existente: $e');
      return true; // Em caso de erro, assume que já existe para evitar duplicação
    }
  }

  /// Exporta todas as senhas para um mapa (pode ser convertido para JSON)
  static Map<String, dynamic> exportPasswords() {
    final box = Hive.box(passwordsBoxName);
    final all = box.values.toList();
    return {'passwords': all};
  }

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
