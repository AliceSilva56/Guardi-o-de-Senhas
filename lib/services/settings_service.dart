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
  static const String _masterPasswordKey = 'master_password'; // TODO: ideal: criptografar
  static const String _confidentialPasswordKey = 'confidential_password'; // TODO: ideal: criptografar
  static const String _themeModeKey = 'theme_mode'; // 0: system, 1: light, 2: dark
  static const String settingsBoxName = 'guardiao_settings'; // Nome da box do Hive para configurações
  static const String biometryKey = 'biometry_enabled'; // Habilitar/desabilitar biometria
  static const String themeModeKey = 'theme_mode'; // Tema do aplicativo
  static const String backupStatusKey = 'backup_status'; // Status do último backup
  static const String profileKey = 'user_profile'; // Perfil do usuário
  static const String _boxName = 'settingsBox';
  static const String _keyMasterPassword = 'masterPassword';
  static const String _settingsBox = 'settingsBox'; // Nome da box do Hive para configurações
  static const String _loginPasswordKey = 'loginPassword'; // Chave para a senha de login
  static const String _accountDeletionKey = 'account_deletion_date'; // Chave para data de exclusão da conta

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  // Pega senha atual
  Future<String?> getMasterPassword() async {
    final box = await _openBox();
    return box.get(_keyMasterPassword);
  }

  // Define nova senha
  Future<void> setMasterPassword(String password) async {
    final box = await _openBox();
    await box.put(_keyMasterPassword, password);
  }

/// -----------------------------
  /// ---- LOGIN ---- 
  /// -----------------------------
Future<void> setLoginPassword(String password) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_loginPasswordKey, password);
  }

  Future<String?> getLoginPassword() async {
    final box = await Hive.openBox(_settingsBox);
    return box.get(_loginPasswordKey);
  }

  Future<bool> validateLoginPassword(String password) async {
    final box = await Hive.openBox(_settingsBox);
    final saved = box.get(_loginPasswordKey);
    return saved == password;
  }

  /// -----------------------------
  /// ---- SENHAS ----
  /// -----------------------------
  
static Future<void> setMasterPasswordStatic(String password) async {
  final box = await Hive.openBox(_boxName);
  await box.put('masterPassword', password);
}

static Future<String?> getMasterPasswordStatic() async {
  final box = await Hive.openBox(_boxName);
  return box.get('masterPassword');
}

static Future<bool> verifyMasterPassword(String password) async {
  final saved = await getMasterPasswordStatic();
  return saved != null && saved == password;
}

  // Agenda a exclusão da conta
  static Future<void> scheduleAccountDeletion() async {
    final box = await Hive.openBox(_settingsBox);
    final deletionDate = DateTime.now().add(const Duration(days: 30));
    await box.put(_accountDeletionKey, deletionDate.toIso8601String());
  }

  // Cancela a exclusão da conta
  static Future<void> cancelAccountDeletion() async {
    final box = await Hive.openBox(_settingsBox);
    await box.delete(_accountDeletionKey);
  }

  // Verifica se há uma exclusão de conta pendente
  static Future<DateTime?> getPendingDeletionDate() async {
    final box = await Hive.openBox(_settingsBox);
    final dateString = box.get(_accountDeletionKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Verifica se a conta deve ser excluída e executa a limpeza se necessário
  static Future<bool> checkAndProcessDeletion() async {
    final deletionDate = await getPendingDeletionDate();
    if (deletionDate == null) return false;
    
    if (DateTime.now().isAfter(deletionDate)) {
      // Tempo de espera expirado - limpar todos os dados
      final box = await Hive.openBox(_settingsBox);
      await box.clear();
      // Aqui você pode adicionar mais limpeza se necessário
      return true;
    }
    return false;
  }

  Future<void> saveMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_masterPasswordKey, password); ///TODO: ideal: criptografar
  }

  Future<String?> getMasterPasswordFromPrefs() async {
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

  /// ------------------
  /// ---- TEMA ----
  /// ------------------
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