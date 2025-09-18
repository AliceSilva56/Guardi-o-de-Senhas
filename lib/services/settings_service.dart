// Arquivo: lib/services/settings_service.dart
// Criar As funcionalidades de salvar e editar o perfil do usuário, cofigurações de senhas, 
// backup e restauração de dados, temas e preferências do aplicativo.

// settings_service.dart
// Arquivo: lib/services/settings_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

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
  static const String _backupFolder = 'GuardiaoBackups'; // Pasta para armazenar backups
  static const String _backupExtension = '.gbackup'; // Extensão dos arquivos de backup
  static const String _lastBackupKey = 'last_backup_timestamp'; // Chave para armazenar o timestamp do último backup

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  // Pega senha atual
  static Future<String?> getMasterPassword() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_keyMasterPassword);
  }

  // Define nova senha
  static Future<void> setMasterPassword(String password) async {
    final box = await Hive.openBox(_boxName);
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
  // Garante que a senha também seja salva no SharedPreferences para compatibilidade
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_masterPasswordKey, password);
}

static Future<String?> getMasterPasswordStatic() async {
  final box = await Hive.openBox(_boxName);
  return box.get('masterPassword');
}

  static Future<bool> verifyMasterPassword(String password) async {
    try {
      // Primeiro tenta verificar na box do Hive
      final box = await Hive.openBox(_boxName);
      final savedInHive = box.get('masterPassword');
      
      // Se encontrou no Hive, verifica
      if (savedInHive != null) {
        return savedInHive == password;
      }
      
      // Se não encontrou no Hive, tenta no SharedPreferences (para compatibilidade com versões antigas)
      final prefs = await SharedPreferences.getInstance();
      final savedInPrefs = prefs.getString(_masterPasswordKey);
      
      // Se encontrou no SharedPreferences, verifica e migra para o Hive
      if (savedInPrefs != null) {
        if (savedInPrefs == password) {
          // Migra para o Hive
          await box.put('masterPassword', password);
          return true;
        }
        return false;
      }
      
      // Se não encontrou em nenhum lugar, retorna falso
      return false;
    } catch (e) {
      debugPrint('Erro ao verificar senha mestra: $e');
      return false;
    }
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

  // Pergunta de Segurança
  static const String _securityQuestionKey = 'security_question';
  static const String _securityAnswerKey = 'security_answer';

  // Salvar pergunta de segurança
  static Future<void> setSecurityQuestion(String question, String answer) async {
    final box = await Hive.openBox(_settingsBox);
    await box.put(_securityQuestionKey, question);
    await box.put(_securityAnswerKey, answer);
  }

  // Obter pergunta de segurança
  static Future<Map<String, String>?> getSecurityQuestion() async {
    final box = await Hive.openBox(_settingsBox);
    final question = box.get(_securityQuestionKey);
    if (question == null) return null;
    
    return {
      'question': question,
      'answer': box.get(_securityAnswerKey, defaultValue: '') as String,
    };
  }

  // Verificar resposta da pergunta de segurança
  static Future<bool> verifySecurityAnswer(String answer) async {
    final box = await Hive.openBox(_settingsBox);
    final savedAnswer = box.get(_securityAnswerKey);
    return savedAnswer != null && savedAnswer == answer;
  }

  // Verificar se existe pergunta de segurança definida
  static Future<bool> hasSecurityQuestion() async {
    final box = await Hive.openBox(_settingsBox);
    return box.containsKey(_securityQuestionKey);
  }

  // Verifica se há uma exclusão de conta pendente
  static Future<DateTime?> getPendingDeletionDate() async {
    final box = await Hive.openBox(_settingsBox);
    final dateString = box.get(_accountDeletionKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  // Configurações de biometria
  static Future<bool> isBiometricAvailable() async {
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Erro ao verificar disponibilidade de biometria: $e');
      return false;
    }
  }

  static Future<bool> getBiometryEnabled() async {
    try {
      final box = await Hive.openBox(settingsBoxName);
      return box.get(biometryKey, defaultValue: false);
    } catch (e) {
      debugPrint('Erro ao verificar biometria habilitada: $e');
      return false;
    }
  }

  static Future<void> setBiometryEnabled(bool enabled) async {
    try {
      final box = await Hive.openBox(settingsBoxName);
      await box.put(biometryKey, enabled);
    } catch (e) {
      debugPrint('Erro ao alterar status da biometria: $e');
      rethrow;
    }
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

  // Salva senha confidencial
  static Future<void> setConfidentialPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_confidentialPasswordKey, password);
  }

  static Future<String?> getConfidentialPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_confidentialPasswordKey);
  }

  /// Salva o timestamp do último backup realizado
  static Future<void> setLastBackupTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
  }

  /// Obtém a data do último backup realizado
  static Future<DateTime?> getLastBackupTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastBackupKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// ------------------
  /// ---- TEMA ----
  /// ------------------
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

  // Cria um arquivo de backup com os dados atuais
  static Future<File> createBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/$_backupFolder');
      
      debugPrint('Caminho do diretório de documentos: ${directory.path}');
      debugPrint('Caminho do diretório de backup: ${backupDir.path}');
      
      if (!await backupDir.exists()) {
        debugPrint('Diretório de backup não existe. Criando...');
        await backupDir.create(recursive: true);
        debugPrint('Diretório de backup criado com sucesso!');
      } else {
        debugPrint('Diretório de backup já existe.');
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File('${backupDir.path}/backup_$timestamp$_backupExtension');

      // Coletar todos os dados necessários
      final settingsBox = await Hive.openBox(settingsBoxName);
      final profile = await getProfile();
      
      final Map<String, dynamic> backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'settings': {
          'theme': settingsBox.get(themeModeKey, defaultValue: 'Sistema'),
          'biometry': settingsBox.get(biometryKey, defaultValue: false),
        },
        'masterPassword': await getMasterPassword(),
        'confidentialPassword': await getConfidentialPassword(),
        'profile': profile,
      };

      // Criptografar os dados antes de salvar
      final encryptedData = _encryptData(jsonEncode(backupData));
      await backupFile.writeAsString(encryptedData);
      
      return backupFile;
    } catch (e) {
      debugPrint('Erro ao criar backup: $e');
      rethrow;
    }
  }

  // Restaura dados a partir de um arquivo de backup
  static Future<bool> restoreBackup(File backupFile) async {
    try {
      final String filePath = backupFile.path.toLowerCase();
      
      // Se for um PDF, não podemos restaurar
      if (filePath.endsWith('.pdf')) {
        throw Exception('Não é possível restaurar de um arquivo PDF. Use a opção de exportação para gerar um arquivo .gbackup');
      }
      
      // Ler e descriptografar os dados
      final encryptedData = await backupFile.readAsString();
      final decryptedData = jsonDecode(_decryptData(encryptedData));
      
      if (decryptedData['version'] != 1) {
        throw Exception('Versão de backup não suportada');
      }

      final settingsBox = await Hive.openBox(settingsBoxName);
      final settings = decryptedData['settings'] as Map<String, dynamic>;
      
      // Restaurar configurações
      await settingsBox.putAll({
        themeModeKey: settings['theme'],
        biometryKey: settings['biometry'],
      });

      // Restaurar senhas
      if (decryptedData['masterPassword'] != null) {
        await setMasterPassword(decryptedData['masterPassword']);
      }
      
      if (decryptedData['confidentialPassword'] != null) {
        await setConfidentialPassword(decryptedData['confidentialPassword']);
      }

      // Restaurar perfil
      if (decryptedData['profile'] != null) {
        await setProfile(
          avatarPath: decryptedData['profile']['avatarPath'] ?? '',
          name: decryptedData['profile']['name'] ?? '',
          email: decryptedData['profile']['email'] ?? '',
        );
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao restaurar backup: $e');
      return false;
    }
  }

  // Lista os arquivos de backup disponíveis
  static Future<List<FileSystemEntity>> listBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/$_backupFolder');
      
      debugPrint('Procurando backups em: ${backupDir.path}');
      
      if (!await backupDir.exists()) {
        debugPrint('Diretório de backup não encontrado.');
        return [];
      }
      
      final files = await backupDir.list().where((file) => 
        file.path.endsWith(_backupExtension)
      ).toList();
      
      debugPrint('${files.length} arquivos de backup encontrados.');
      
      // Ordenar por data de modificação (mais recente primeiro)
      files.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
      
      return files;
    } catch (e) {
      debugPrint('Erro ao listar backups: $e');
      return [];
    }
  }

  // Funções auxiliares para criptografia básica (substitua por uma solução mais segura em produção)
  static String _encryptData(String data) {
    // Implementação básica - em produção, use um algoritmo de criptografia seguro
    return base64Encode(utf8.encode(data));
  }

  static String _decryptData(String encryptedData) {
    // Implementação básica - em produção, use um algoritmo de criptografia seguro
    return utf8.decode(base64Decode(encryptedData));
  }


  Future<void> importBackup(File file) async {
    final jsonData = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(jsonData);

    // Restaurar
    if (data["masterPassword"] != null) {
      await setMasterPassword(data["masterPassword"]);
    }
    if (data["confidentialPassword"] != null) {
      await setConfidentialPassword(data["confidentialPassword"]);
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
  // Os métodos getBiometryEnabled e setBiometryEnabled já estão definidos acima
  // com tratamento de erros adequado

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
      'avatarPath': avatarPath,
      'name': name,
      'email': email,
    });
  }

  // Obtém o perfil do usuário
  static Future<Map<String, dynamic>> getProfile() async {
    final box = await Hive.openBox(settingsBoxName);
    final profile = box.get(profileKey, defaultValue: {
      'avatarPath': '',
      'name': '',
      'email': '',
    });
    return Map<String, dynamic>.from(profile);
  }
}