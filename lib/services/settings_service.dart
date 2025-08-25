// Arquivo: lib/services/settings_service.dart
// Criar As funcionalidades de salvar e editar o perfil do usuário, cofigurações de senhas, 
// backup e restauração de dados, temas e preferências do aplicativo.

// settings_service.dart
// Arquivo: lib/services/settings_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class SettingsService {
  static const String _masterPasswordKey = 'master_password';
  static const String _confidentialPasswordKey = 'confidential_password';
  static const String _themeModeKey = 'theme_mode';
  static const String settingsBoxName = 'guardiao_settings';
  static const String biometryKey = 'biometry_enabled';
  static const String themeModeKey = 'theme_mode';
  static const String backupStatusKey = 'backup_status';
  static const String profileKey = 'user_profile';

  /// ---- SENHAS ----
  Future<void> saveMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_masterPasswordKey, password); // ideal: criptografar
  }

  Future<String?> getMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_masterPasswordKey);
  }

  Future<void> saveConfidentialPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_confidentialPasswordKey, password);
  }

  Future<String?> getConfidentialPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_confidentialPasswordKey);
  }

  /// ---- TEMA ----
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  // Salva o tema escolhido
  static Future<void> setThemeMode(String mode) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put(themeModeKey, mode);
  }

  // Recupera o tema salvo
  static Future<String> getSavedThemeMode() async {
    final box = await Hive.openBox(settingsBoxName);
    return box.get(themeModeKey, defaultValue: '⚙️ Sistema') as String;
  }

  /// ---- BACKUP ----
  Future<File> createBackup() async {
    // Aqui você pode extrair do Hive todas as boxes que guardam senhas/config
    final Map<String, dynamic> data = {
      "masterPassword": await getMasterPassword(),
      "confidentialPassword": await getConfidentialPassword(),
      // exemplo, se tiver uma box de senhas:
      "passwords": Hive.box('passwords').values.toList(),
      "categories": Hive.box('categories').values.toList(),
    };

    final jsonData = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup_guardiao.json');
    return file.writeAsString(jsonData);
  }

  Future<void> importBackup(File file) async {
    final jsonData = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(jsonData);

    // Restaurar
    if (data["masterPassword"] != null) {
      await saveMasterPassword(data["masterPassword"]);
    }
    if (data["confidentialPassword"] != null) {
      await saveConfidentialPassword(data["confidentialPassword"]);
    }

    if (data["passwords"] != null) {
      final box = Hive.box('passwords');
      await box.clear();
      for (var p in data["passwords"]) {
        await box.add(p);
      }
    }

    if (data["categories"] != null) {
      final box = Hive.box('categories');
      await box.clear();
      for (var c in data["categories"]) {
        await box.add(c);
      }
    }
  }

  // -----------------------------
  // BIOMETRIA
  // -----------------------------

  static Future<bool> getBiometryEnabled() async {
    final box = await Hive.openBox(settingsBoxName);
    return box.get(biometryKey, defaultValue: false) as bool;
  }

  static Future<void> setBiometryEnabled(bool enabled) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put(biometryKey, enabled);
  }

  // Salva o status do backup
  static Future<void> setBackupStatus({required bool done, required String location}) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put(backupStatusKey, {
      'done': done,
      'location': location,
    });
  }

  // Recupera o status do backup
  static Future<Map<String, dynamic>> getBackupStatus() async {
    final box = await Hive.openBox(settingsBoxName);
    final status = box.get(backupStatusKey);
    if (status is Map) {
      return {
        'done': status['done'] ?? false,
        'location': status['location'] ?? '',
      };
    }
    return {'done': false, 'location': ''};
  }

  // Salva o perfil do usuário
  static Future<void> setProfile({
    required String avatarPath,
    required String name,
    required String email,
  }) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put(profileKey, {
      'avatar': avatarPath,
      'name': name,
      'email': email,
    });
  }

  // Recupera o perfil do usuário
  static Future<Map<String, String>> getProfile() async {
    final box = await Hive.openBox(settingsBoxName);
    final profile = box.get(profileKey, defaultValue: {});
    return {
      'avatar': profile?['avatar'] ?? '',
      'name': profile?['name'] ?? '',
      'email': profile?['email'] ?? '',
    };
  }
}