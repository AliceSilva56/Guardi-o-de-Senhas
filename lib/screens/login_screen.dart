import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final masterPasswordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🛡️ Guardião de Senhas',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: masterPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha Mestra',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Linha com Entrar e Cadastrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (masterPasswordController.text.trim() == '1234') {
                        Navigator.pushReplacementNamed(context, '/main');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha incorreta')),
                        );
                      }
                    },
                    child: const Text('Entrar'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  // Aqui simulação de login biométrico
                },
                child: const Text('Acesso Biométrico 👆'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
