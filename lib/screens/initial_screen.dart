import 'package:flutter/material.dart';
import 'package:guardiao_de_senhas/services/user_service.dart';
import 'elf_intro_screen.dart';
import 'login_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isLoading = true;
  bool _hasSeenIntro = false;

  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
  }

  Future<void> _checkIntroStatus() async {
    try {
      final hasSeen = await UserService.hasSeenIntro();
      setState(() {
        _hasSeenIntro = hasSeen;
        _isLoading = false;
      });
    } catch (e) {
      // Em caso de erro, assume que o usuário não viu a introdução
      setState(() {
        _hasSeenIntro = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _hasSeenIntro ? const LoginScreen() : const ElfIntroScreen();
  }
}
