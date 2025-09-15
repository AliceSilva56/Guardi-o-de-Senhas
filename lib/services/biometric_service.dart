import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart' as ios_auth;
import 'package:local_auth_darwin/local_auth_darwin.dart' as darwin_auth;
import 'package:hive/hive.dart';

// Nomes das chaves para armazenamento
const String _settingsBoxName = 'settings';
const String _biometryKey = 'biometry_enabled';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Verifica se o dispositivo tem suporte a biometria
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Erro ao verificar biometria: $e');
      return false;
    }
  }

  // Verifica quais tipos de biometria estão disponíveis
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Erro ao obter biometrias disponíveis: $e');
      return [];
    }
  }

  // Executa a autenticação biométrica
  static Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar o Guardião de Senhas',
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Autenticação necessária',
            biometricHint: 'Toque no sensor de impressão digital',
            cancelButton: 'Cancelar',
          ),
          const darwin_auth.IOSAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Configurações',
            goToSettingsDescription: 'Configure sua biometria',
            lockOut: 'Muitas tentativas. Tente novamente mais tarde.',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      
      return authenticated;
    } catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return false;
    }
  }

  // Verifica se a biometria está configurada
  static Future<bool> isBiometricEnrolled() async {
    try {
      return await _auth.canCheckBiometrics && 
             await _auth.getAvailableBiometrics().then((biometrics) => biometrics.isNotEmpty);
    } catch (e) {
      debugPrint('Erro ao verificar biometria configurada: $e');
      return false;
    }
  }

  // Verifica se a biometria está habilitada nas configurações do app
  static Future<bool> isBiometricEnabled() async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      return box.get(_biometryKey, defaultValue: false) ?? false;
    } catch (e) {
      debugPrint('Erro ao verificar biometria habilitada: $e');
      return false;
    }
  }

  // Habilita/desabilita a biometria
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final box = await Hive.openBox(_settingsBoxName);
      await box.put(_biometryKey, enabled);
    } catch (e) {
      debugPrint('Erro ao alterar status da biometria: $e');
      rethrow;
    }
  }
}
