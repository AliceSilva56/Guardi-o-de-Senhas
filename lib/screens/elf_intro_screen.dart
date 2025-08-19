// Arquivo: lib/screens/elf_intro_screen.dart
// Esta tela de introdução é exibida quando o aplicativo é aberto pela primeira vez,
// permitindo que o usuário escolha entre fazer login ou se registrar como novo usuário.
// Ela apresenta uma imagem de um elfo (ou mascote do aplicativo) e dois botões:
// um para login e outro para registro.
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
//import 'register_screen.dart';
import 'registro_guardiao_flow.dart';

class ElfIntroScreen extends StatelessWidget {
  const ElfIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, drawerScrimColor: const Color.fromARGB(255, 69, 9, 153),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Elfo (troca pelo asset da sua logo/mascote)
              Image.asset(
                "assets/logo/guardiao_transparente.png",
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                "Olá viajante! Você já tem login?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Botões de escolha
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 104, 24, 233), // roxo para o botão de login
                  foregroundColor: Colors.white, // Texto branco
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Sim, já tenho login"),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.blue, // azul para o botão de registro
                  foregroundColor: Colors.white, // Texto branco
                  // modo escuro
                  // backgroundColor: AppColors.primaryDark,
                  
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistroGuardiaoFlow()),
                  );
                },
                child: const Text("Não, quero me registrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
