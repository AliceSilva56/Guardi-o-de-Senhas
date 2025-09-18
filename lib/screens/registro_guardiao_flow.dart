// Arquivo: lib/screens/registro_guardiao_flow.dart
// Esta tela é parte do fluxo de registro do Guardião de Senhas, onde o usuário
// é guiado por uma série de etapas para criar uma conta, definir uma senha mestra,
// escolher uma pergunta de segurança e decidir sobre o uso de biometria.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
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
  bool isEditandoPergunta =
      false; // Controla se está editando uma pergunta personalizada
  String pergunta = ""; // Guarda a pergunta escolhida ou personalizada

  // Lista de perguntas padrão
  final List<Map<String, String>> perguntasPadrao = [
    {"id": "pet", "texto": "Qual foi o nome do seu primeiro pet?"},
    {"id": "cidade", "texto": "Em que cidade você nasceu?"},
    {"id": "prof", "texto": "Qual era o nome do seu professor favorito?"},
  ];

// --- Função de validação ---
  bool _validarCampos() {
    bool isValid = true;

    if (isEditandoPergunta) {
      if (novaPerguntaCtrl.text.trim().isEmpty) {
        setState(() => perguntaErro = true);
        isValid = false;
      }
    } else if (pergunta.isEmpty) {
      setState(() => perguntaErro = true);
      isValid = false;
    }

    if (respostaCtrl.text.trim().isEmpty) {
      setState(() => respostaErro = true);
      isValid = false;
    }

    return isValid;
  }

  final PageController _controller = PageController(initialPage: 0);
  int pageIndex = 0;
  bool _isLoading = false;

  final nomeCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  bool biometriaEscolha = false;
  bool _obscurePassword = true;

  Future<void> nextPage() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Validação dos campos da tela de pergunta de segurança
      if (pageIndex == 3) {
        if (!_validarCampos()) {
          setState(() => _isLoading = false);
          return;
        }

        // Processa a pergunta
        if (isEditandoPergunta) {
          pergunta = novaPerguntaCtrl.text.trim();
        } else {
          var perguntaSelecionada = perguntasPadrao.firstWhere(
            (p) => p['id'] == pergunta,
            orElse: () => {'id': pergunta, 'texto': pergunta},
          );
          pergunta = perguntaSelecionada['texto']!;
        }

        // Salva a pergunta de segurança
        await SettingsService.setSecurityQuestion(
            pergunta, respostaCtrl.text.trim());
      }

      // Navega para a próxima tela
      if (pageIndex < 5) {
        final nextPage = pageIndex + 1;

        // Navega primeiro e depois atualiza o estado
        await _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // Atualiza o estado após a navegação
        if (mounted) {
          setState(() => pageIndex = nextPage);
        }
      }
    } catch (e) {
      debugPrint('Erro na navegação: $e');
      if (mounted) {
        // Garante que temos um contexto válido para o ScaffoldMessenger
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ocorreu um erro ao avançar')),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

// TELA 2 - Nome
  Widget _nome() {
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (nomeCtrl.text.trim().isEmpty) return;
              nextPage();
            },
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Seu nome",
              filled: true,
              fillColor: Colors.white12,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );
  }

// TELA 3 - Senha Mestra
  Widget _senha() {
    final nome = nomeCtrl.text.trim();
    final saudacao = nome.isEmpty ? "" : ", $nome";
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );
  }

// TELA 4 - Pergunta de segurança
  Widget _pergunta() {
    final nome = nomeCtrl.text.trim();
    final saudacao = nome.isEmpty ? "" : ", $nome";

    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),

          // Widget condicional: mostra dropdown ou campo de texto
          isEditandoPergunta
              ? TextFormField(
                  controller: novaPerguntaCtrl,
                  autofocus: true,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Sua pergunta personalizada",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          isEditandoPergunta = false;
                          pergunta = '';
                          novaPerguntaCtrl.clear();
                          perguntaErro = false;
                        });
                      },
                    ),
                    errorText: perguntaErro ? "Digite uma pergunta" : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      pergunta = value;
                      perguntaErro = false;
                    });
                  },
                )
              : DropdownButtonFormField<String>(
                  value: pergunta.isEmpty
                      ? null
                      : (perguntasPadrao.any((p) => p['id'] == pergunta)
                          ? pergunta
                          : null),
                  items: [
                    ...perguntasPadrao
                        .map((perg) => DropdownMenuItem(
                              value: perg['id'],
                              child: Text(perg['texto']!),
                            ))
                        .toList(),
                    const DropdownMenuItem(
                      value: "personalizar",
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text("Personalizar pergunta"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == "personalizar") {
                        isEditandoPergunta = true;
                        pergunta = '';
                      } else {
                        pergunta = value ?? '';
                        novaPerguntaCtrl.clear();
                      }
                      perguntaErro = false;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    hintText: "Selecione uma pergunta",
                    hintStyle: const TextStyle(color: Colors.white70),
                    errorText: perguntaErro ? "Selecione uma pergunta" : null,
                  ),
                  dropdownColor: const Color(0xFF2D2D2D),
                  style: const TextStyle(color: Colors.white),
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              errorText: respostaErro ? "Digite uma resposta" : null,
            ),
          ),

          const SizedBox(height: 20),

          // Botão próximo
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_validarCampos()) {
                        // Se estiver editando uma pergunta personalizada, usa o texto digitado
                        if (isEditandoPergunta) {
                          pergunta = novaPerguntaCtrl.text.trim();
                        }
                        await nextPage();
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Próximo",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

// TELA 5 - Biometria
  Widget _biometria() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _checkBiometricStatus(),
      builder: (context, snapshot) {
        // Mostra um indicador de carregamento enquanto verifica a biometria
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _wrapMagic(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Verificando biometria...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        // Trata erros na verificação
        if (snapshot.hasError) {
          return _buildBiometricError(
            context,
            'Erro ao verificar biometria',
            snapshot.error.toString(),
          );
        }

        // Se não tem dados, mostra erro
        if (!snapshot.hasData) {
          return _buildBiometricError(
            context,
            'Não foi possível verificar a biometria',
            'Tente novamente mais tarde.',
          );
        }

        final data = snapshot.data!;
        final bool isAvailable = data['isAvailable'] ?? false;
        final String? errorMessage = data['error'];
        final List<BiometricType> availableBiometrics =
            data['availableBiometrics'] ?? [];

        // Se a biometria não estiver disponível, mostra mensagem e botão para pular
        if (!isAvailable) {
          return _buildBiometricUnavailable(
              context, errorMessage ?? 'Biometria não disponível');
        }

        // Se chegou até aqui, a biometria está disponível
        return _buildBiometricScreen(context, availableBiometrics);
      },
    );
  }

// Verifica o status da biometria
  Future<Map<String, dynamic>> _checkBiometricStatus() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final availableBiometrics =
          await BiometricService.getAvailableBiometrics();

      return {
        'isAvailable': isAvailable,
        'availableBiometrics': availableBiometrics,
        'error':
            availableBiometrics.isEmpty ? 'Nenhuma biometria cadastrada' : null,
      };
    } catch (e) {
      return {
        'isAvailable': false,
        'availableBiometrics': [],
        'error': e.toString(),
      };
    }
  }

// Tela de erro de biometria
  Widget _buildBiometricError(
      BuildContext context, String title, String message) {
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildSkipButton(context),
        ],
      ),
    );
  }

// Tela quando a biometria não está disponível
  Widget _buildBiometricUnavailable(BuildContext context, String message) {
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fingerprint,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Biometria não disponível',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildSkipButton(context),
        ],
      ),
    );
  }

// Tela principal de biometria
  Widget _buildBiometricScreen(
      BuildContext context, List<BiometricType> availableBiometrics) {
    // Removido o SingleChildScrollView duplicado: _wrapMagic já inclui um.
    return _wrapMagic(
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  "assets/animation/guardiao_biometria_transparente.png",
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ativar Biometria',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Deseja ativar a autenticação por biometria para um acesso mais rápido e seguro ao aplicativo?',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildBiometricTypeInfo(availableBiometrics),
                const SizedBox(height: 32),
                _buildBiometricButton(context, availableBiometrics),
                const SizedBox(height: 16),
                _buildSkipButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mostra informações sobre o tipo de biometria disponível
  Widget _buildBiometricTypeInfo(List<BiometricType> availableBiometrics) {
    final hasFingerprint =
        availableBiometrics.contains(BiometricType.fingerprint);
    final hasFace = availableBiometrics.contains(BiometricType.face);
    final hasIris = availableBiometrics.contains(BiometricType.iris);

    String message = '';
    IconData icon = Icons.fingerprint;

    if (hasFace) {
      message = 'Face ID';
      icon = Icons.face;
    } else if (hasFingerprint) {
      message = 'Impressão digital';
      icon = Icons.fingerprint;
    } else if (hasIris) {
      message = 'Reconhecimento de íris';
      icon = Icons.remove_red_eye;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Dispositivo com suporte a $message',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Botão para ativar biometria
  Widget _buildBiometricButton(
      BuildContext context, List<BiometricType> availableBiometrics) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () => _handleBiometricActivation(context, availableBiometrics),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Ativar Biometria',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // Botão para pular a ativação da biometria
  Widget _buildSkipButton(BuildContext context) {
    return TextButton(
      onPressed: _isLoading
          ? null
          : () async {
              // Não é necessário setar _isLoading = true aqui pois o nextPage() já faz isso
              if (mounted) {
                await nextPage();
              }
            },
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Pular e configurar depois'),
    );
  }

  // Manipula a ativação da biometria
  Future<void> _handleBiometricActivation(
      BuildContext context, List<BiometricType> availableBiometrics) async {
    setState(() => _isLoading = true);

    try {
      final authenticated = await BiometricService.authenticate();

      if (!mounted) return;

      if (authenticated) {
        setState(() {
          biometriaEscolha = true;
          _isLoading = false;
        });

        // Navega automaticamente após ativar a biometria
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await nextPage();
        }
      } else {
        setState(() => _isLoading = false); // 🔹 garante reset
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticação biométrica necessária para ativar.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: ${e.message}');
      if (mounted) {
        setState(() => _isLoading = false); // 🔹 garante reset
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro na biometria: ${e.message ?? 'Tente novamente mais tarde'}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      if (mounted) {
        setState(() => _isLoading = false); // 🔹 garante reset
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado. Tente novamente.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // TELA 6 - Finalização
  // TELA 6 - Finalização
  Widget _finalizacao() {
    final nome = nomeCtrl.text.trim();
    return _wrapMagic(
      Column(
        mainAxisSize: MainAxisSize.min,
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
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          // removido Spacer (causava erro quando dentro de SingleChildScrollView)
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);

                      try {
                        // Salvar senha mestra
                        await SettingsService.setMasterPasswordStatic(
                            senhaCtrl.text.trim());

                        // Salvar perfil
                        await SettingsService.setProfile(
                          avatarPath: "",
                          name: nome,
                          email: "",
                        );

                        // Salvar pergunta de segurança
                        final box =
                            await Hive.openBox(SettingsService.settingsBoxName);
                        await box.put("security_question", pergunta);
                        await box.put(
                            "security_answer", respostaCtrl.text.trim());

                        // Salvar preferência de biometria
                        if (biometriaEscolha) {
                          await SettingsService.setBiometryEnabled(true);
                        }

                        // Navegar para tela principal
                        if (!mounted) return;

                        // Pequeno atraso para mostrar a animação de carregamento
                        await Future.delayed(const Duration(milliseconds: 500));

                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                        );
                      } catch (e) {
                        debugPrint('Erro ao salvar configurações: $e');
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Erro ao salvar configurações. Tente novamente.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Acessar Meu Cofre",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
