import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'settings_service.dart';

class UserService {
  static const String _hasSeenIntroKey = 'has_seen_intro';
  static const String _userBoxName = 'user_preferences';
  static const String _firstLoginKey = 'is_first_login';
  static const String _userNameKey = 'user_name';
  static const String _lastLoginKey = 'last_login';

  // Verifica se é o primeiro login do usuário
  static Future<bool> isFirstLogin() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get(_firstLoginKey, defaultValue: true) as bool;
  }

  // Marca que o usuário já fez o primeiro login
  static Future<void> setFirstLoginDone() async {
    final box = await Hive.openBox(_userBoxName);
    await box.put(_firstLoginKey, false);
  }

  // Verifica se o usuário já viu a tela de introdução
  static Future<bool> hasSeenIntro() async {
    try {
      final box = await Hive.openBox(_userBoxName);
      return box.get(_hasSeenIntroKey, defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Erro ao verificar se viu a introdução: $e');
      return false;
    }
  }

  // Marca que o usuário já viu a tela de introdução
  static Future<void> setHasSeenIntro() async {
    try {
      final box = await Hive.openBox(_userBoxName);
      await box.put(_hasSeenIntroKey, true);
    } catch (e) {
      debugPrint('Erro ao salvar status da introdução: $e');
      rethrow;
    }
  }

  // Obtém o nome do usuário
  static Future<String?> getUserName() async {
    try {
      // Primeiro tenta obter do perfil no SettingsService
      final profile = await SettingsService.getProfile();
      final name = profile['name'] as String?;
      
      if (name != null && name.isNotEmpty) {
        return name;
      }
      
      // Se não encontrar no perfil, tenta obter do UserService (para compatibilidade)
      final box = await Hive.openBox(_userBoxName);
      final oldName = box.get(_userNameKey) as String?;
      
      // Se encontrar no UserService, migra para o perfil
      if (oldName != null && oldName.isNotEmpty) {
        await SettingsService.setProfile(
          avatarPath: '',
          name: oldName,
          email: '',
        );
        // Remove o nome antigo do UserService
        await box.delete(_userNameKey);
        return oldName;
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao obter nome do usuário: $e');
      return null;
    }
  }

  // Define o nome do usuário
  static Future<void> setUserName(String name) async {
    try {
      debugPrint('Salvando nome do usuário: $name');
      
      // Salva no perfil do SettingsService
      await SettingsService.setProfile(
        avatarPath: '',
        name: name,
        email: '',
      );
      
      debugPrint('Nome do usuário salvo com sucesso no perfil');
      
      // Verificar se o nome foi salvo corretamente
      final savedName = await getUserName();
      debugPrint('Nome recuperado após salvar: $savedName');
      
      // Remove o nome antigo do UserService se existir
      try {
        final box = await Hive.openBox(_userBoxName);
        if (await box.containsKey(_userNameKey)) {
          await box.delete(_userNameKey);
        }
      } catch (e) {
        debugPrint('Aviso: não foi possível limpar o nome antigo: $e');
      }
    } catch (e) {
      debugPrint('Erro ao salvar nome do usuário: $e');
      rethrow;
    }
  }

  // Obtém a data do último login
  static Future<DateTime?> getLastLogin() async {
    final box = await Hive.openBox(_userBoxName);
    final lastLogin = box.get(_lastLoginKey);
    return lastLogin != null ? DateTime.parse(lastLogin as String) : null;
  }

  // Atualiza a data do último login para agora
  static Future<void> updateLastLogin() async {
    final box = await Hive.openBox(_userBoxName);
    await box.put(_lastLoginKey, DateTime.now().toIso8601String());
  }

  // Retorna uma saudação personalizada baseada no horário do dia
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  // Retorna uma mensagem de boas-vindas personalizada
  static Future<String> getWelcomeMessage() async {
    final userName = await getUserName();
    final lastLogin = await getLastLogin();
    final greeting = getGreeting();
    
    // Mensagem base apenas com a saudação
    String message = greeting;
    
    // Adiciona o nome do usuário apenas uma vez
    if (userName != null && userName.isNotEmpty) {
      message += ', $userName';
    }
    
    message += '!';
    
    // Adiciona mensagem adicional baseada no último login
    if (lastLogin != null) {
      final now = DateTime.now();
      final difference = now.difference(lastLogin);
      
      if (difference.inDays > 7) {
        message += '\nQue bom te ver de volta! Sentimos sua falta.';
      } else if (difference.inDays > 1) {
        message += '\nBem-vindo(a) de volta!';
      } else if (difference.inHours > 12) {
        message += '\nQue bom te ver novamente!';
      }
    } else {
      message += '\nBem-vindo(a) ao Guardião de Senhas!';
    }
    
    return message;
  }
}
