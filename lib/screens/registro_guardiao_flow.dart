// Arquivo: lib/screens/registro_guardiao_flow.dart
// Esta tela é parte do fluxo de registro do Guardião de Senhas, onde o usuário
// é guiado por uma série de etapas para criar uma conta, definir uma senha mestra,
// escolher uma pergunta de segurança e decidir sobre o uso de biometria.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/settings_service.dart';
import '../services/biometric_service.dart';
import '../theme/app_colors.dart';
import 'main_screen.dart';
import 'package:flutter/services.dart';


final _settings = SettingsService();
class RegistroGuardiaoFlow extends StatefulWidget {
  const RegistroGuardiaoFlow({super.key});

  @override
  State<RegistroGuardiaoFlow> createState() => _RegistroGuardiaoFlowState();
}

class _RegistroGuardiaoFlowState extends State<RegistroGuardiaoFlow> {

  // --- Controllers ---
final TextEditingController respostaCtrl = TextEditingController();
final TextEditingController novaPerguntaCtrl = TextEditingController();

// --- Variáveis de estado ---
bool perguntaErro = false;
bool respostaErro = false;
bool novaPerguntaErro = false;

String pergunta = ""; // Guarda a pergunta escolhida ou personalizada

// --- Função de validação ---
bool _validarCampos() {
  setState(() {
    perguntaErro = pergunta.isEmpty && novaPerguntaCtrl.text.trim().isEmpty;
    novaPerguntaErro = pergunta.isEmpty && novaPerguntaCtrl.text.trim().isEmpty;
    respostaErro = respostaCtrl.text.trim().isEmpty;
  });

  return !(perguntaErro || respostaErro || novaPerguntaErro);
}

  final PageController _controller = PageController();
  int pageIndex = 0;

  final nomeCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  bool biometriaEscolha = false;
  bool _obscurePassword = true;

  void nextPage() {
    if (pageIndex < 5) {
      setState(() => pageIndex++);
      _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    nomeCtrl.dispose();
    senhaCtrl.dispose();
    respostaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _intro(),
          _nome(),
          _senha(),
          _pergunta(),
          _biometria(),
          _finalizacao(),
        ],
      ),
    );
  }

  Widget _wrapMagic(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBackground, AppColors.secondary]
              : [AppColors.lightBackground, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );

  // TELA 1 - Apresentação
  Widget _intro() {
    return _wrapMagic(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/animation/guardiao_apresentacao_transparente.png",
          height: 150,
        ),
        const SizedBox(height: 16),
        _title("Eu sou o elfo Guardião das Senhas. Meu nome é Sylas!"),
        const Text(
          "Minha missão é proteger todos os seus segredos. Mas antes, preciso conhecê-lo...",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
          ),
          onPressed: nextPage,
          child: const Text("Começar a Jornada"),
        ),
      ],
    ));
  }

  // TELA 2 - Nome
  Widget _nome() {
    return _wrapMagic(Column(
      children: [
        Image.asset(
          "assets/animation/guardiao_nome_transparente.png",
          height: 120,
        ),
        const SizedBox(height: 12),
        _title("Me diga o seu nome"),
        const Text(
          "Para que eu saiba quem eu devo proteger e deixar entrar.",
          textAlign: TextAlign.center,
        ),
        TextField(
          controller: nomeCtrl,
          textInputAction: TextInputAction.done, // <- adicionado
  onSubmitted: (_) { // <- adicionado
    if (nomeCtrl.text.trim().isEmpty) return;
    nextPage();
  },
   autofocus: true, // 🔹 Alteração: já inicia com foco neste campo
          decoration: InputDecoration(
            hintText: "Seu nome",
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
          ),
          onPressed: () {
            if (nomeCtrl.text.trim().isEmpty) return;
            nextPage();
          },
          child: const Text("Avançar"),
        ),
      ],
    ));
  }

  // TELA 3 - Senha Mestra
  Widget _senha() {
    final nome = nomeCtrl.text.trim();
    final saudacao = nome.isEmpty ? "" : ", $nome";
    return _wrapMagic(Column(
      children: [
        Image.asset(
          "assets/animation/guardiao_senhaMestra_transparente.png",
          height: 120,
        ),
        const SizedBox(height: 12),
        _title("Escolha sua chave mestra$saudacao"),
        TextField(
          controller: senhaCtrl,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (senhaCtrl.text.length < 6) return;
            nextPage();
          },
          autofocus: true,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: "Senha mestra",
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
            "Dica: Use símbolos, números e letras. Uma chave forte mantém monstros afastados!"),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
          ),
          onPressed: () {
            if (senhaCtrl.text.length < 6) return;
            nextPage();
          },
          child: const Text("Continuar"),
        ),
      ],
    ));
  }

// TELA 4 - Pergunta de segurança
Widget _pergunta() {
  final nome = nomeCtrl.text.trim();
  final saudacao = nome.isEmpty ? "" : ", $nome";

  return _wrapMagic(
    Column(
      children: [
        Image.asset(
          "assets/animation/guardiao_PerguntaSeguranca_transparente.png",
          height: 120,
        ),
        const SizedBox(height: 12),

        _title("Escolha uma pergunta de segurança$saudacao"),
        const Text(
          "Mesmo os guardiões precisam de um truque extra. Escolha ou crie uma pergunta que só você saiba a resposta.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Dropdown com perguntas padrão
        DropdownButtonFormField<String>(
          value: pergunta.isEmpty ? null : pergunta,
          items: const [
            DropdownMenuItem(
              value: "pet",
              child: Text("Qual foi o nome do seu primeiro pet?"),
            ),
            DropdownMenuItem(
              value: "cidade",
              child: Text("Em que cidade você nasceu?"),
            ),
            DropdownMenuItem(
              value: "prof",
              child: Text("Qual era o nome do seu professor favorito?"),
            ),
          ],
          onChanged: (v) => setState(() {
            pergunta = v ?? "";
            perguntaErro = false;
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            errorText: perguntaErro ? "Escolha ou crie uma pergunta" : null,
          ),
        ),

        const SizedBox(height: 16),

        // Campo para criar pergunta personalizada
        TextFormField(
          controller: novaPerguntaCtrl,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Criar nova pergunta",
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            errorText: novaPerguntaErro ? "Digite uma pergunta" : null,
          ),
          onChanged: (_) {
            setState(() {
              novaPerguntaErro = false;
            });
          },
        ),

        const SizedBox(height: 16),

        // Campo de resposta
        TextFormField(
          controller: respostaCtrl,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: Colors.white),
          onFieldSubmitted: (_) {
            if (_validarCampos()) nextPage();
          },
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Resposta",
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            errorText: respostaErro ? "Digite uma resposta" : null,
          ),
        ),

        const SizedBox(height: 20),

        // Botão próximo
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
          ),
          onPressed: () {
            if (_validarCampos()) {
              // Se o usuário digitou pergunta personalizada, ela substitui a default
              if (novaPerguntaCtrl.text.trim().isNotEmpty) {
                pergunta = novaPerguntaCtrl.text.trim();
              }
              nextPage();
            }
          },
          child: const Text("Próximo"),
        ),
      ],
    ),
  );
}


  // TELA 5 - Biometria
  Widget _biometria() {
    return FutureBuilder<bool>(
      future: BiometricService.isBiometricAvailable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _wrapMagic(const Center(child: CircularProgressIndicator()));
        }

        final isAvailable = snapshot.data ?? false;
        
        return _wrapMagic(Column(
          children: [
            Image.asset(
              "assets/animation/guardiao_biometria_transparente.png",
              height: 120,
            ),
            const SizedBox(height: 12),
            _title(isAvailable 
              ? "Deseja ativar a biometria?" 
              : "Biometria não disponível"),
            
            if (isAvailable) ...[
              const Text(
                "Você pode usar sua impressão digital ou reconhecimento facial para fazer login mais rapidamente.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text("Ativar biometria"),
                value: biometriaEscolha,
                onChanged: (value) async {
                  if (value) {
                    try {
                      final authenticated = await BiometricService.authenticate();
                      if (authenticated) {
                        setState(() {
                          biometriaEscolha = value;
                        });
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Autenticação biométrica necessária para ativar.'),
                            ),
                          );
                        }
                      }
                    } on PlatformException catch (e) {
                      debugPrint('Erro na autenticação biométrica: ${e.message}');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro na biometria: ${e.message ?? 'Tente novamente mais tarde'}')
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Erro inesperado: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao configurar biometria. Tente novamente.')
                          ),
                        );
                      }
                    }
                  } else {
                    setState(() {
                      biometriaEscolha = value;
                    });
                  }
                },
              ),
            ] else ...[
              const Text(
                "Seu dispositivo não possui recursos biométricos configurados ou não são compatíveis.",
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
            ],
            
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
              ),
              onPressed: nextPage,
              child: const Text("Continuar"),
            ),
          ],
        ));
      },
    );
  }


  // TELA 6 - Finalização
  Widget _finalizacao() {
    final nome = nomeCtrl.text.trim();
    return _wrapMagic(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/animation/guardiao_final_transparente.png",
          height: 150,
        ),
        const SizedBox(height: 24),
        _title("Tudo pronto!"),
        Text(
          "Parabéns, ${nome.isNotEmpty ? nome : 'Guardião'}! Sua conta foi criada com sucesso.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (biometriaEscolha) ...[
          const Icon(Icons.fingerprint, size: 48, color: Colors.green),
          const Text(
            "Biometria ativada com sucesso!",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () async {
            // Salvar senha mestra
            await SettingsService.setMasterPasswordStatic(senhaCtrl.text.trim());
            
            // Salvar perfil
            await SettingsService.setProfile(
              avatarPath: "",
              name: nome,
              email: "",
            );
            
            // Salvar pergunta de segurança
            final box = await Hive.openBox(SettingsService.settingsBoxName);
            await box.put("security_question", pergunta);
            await box.put("security_answer", respostaCtrl.text.trim());
            
            // Salvar preferência de biometria
            if (biometriaEscolha) {
              await SettingsService.setBiometryEnabled(true);
            }
            
            // Navegar para tela principal
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          child: const Text("Acessar Meu Cofre"),
        ),
      ],
    ));
  }
}
