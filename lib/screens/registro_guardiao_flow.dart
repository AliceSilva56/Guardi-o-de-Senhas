// Arquivo: lib/screens/registro_guardiao_flow.dart
// Esta tela é parte do fluxo de registro do Guardião de Senhas, onde o usuário
// é guiado por uma série de etapas para criar uma conta, definir uma senha mestra,
// escolher uma pergunta de segurança e decidir sobre o uso de biometria.
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import 'main_screen.dart';


final _settings = SettingsService();
class RegistroGuardiaoFlow extends StatefulWidget {
  const RegistroGuardiaoFlow({super.key});

  @override
  State<RegistroGuardiaoFlow> createState() => _RegistroGuardiaoFlowState();
}

class _RegistroGuardiaoFlowState extends State<RegistroGuardiaoFlow> {
  final PageController _controller = PageController();
  int pageIndex = 0;

  final nomeCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  String pergunta = "";
  final respostaCtrl = TextEditingController();
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
    return _wrapMagic(Column(
      children: [
        Image.asset(
          "assets/animation/guardiao_PerguntaSeguranca_transparente.png",
          height: 120,
        ),
        const SizedBox(height: 12),
        _title("Escolha uma pergunta de segurança$saudacao"),
        const Text(
          "Mesmos os guardiões precisam de um truque extra. Escolha uma pergunta que só você saiba a resposta.",
          textAlign: TextAlign.center,
        ),
        DropdownButtonFormField<String>(
          value: pergunta.isEmpty ? null : pergunta,
          items: const [
            DropdownMenuItem(
                value: "pet",
                child: Text("Qual foi o nome do seu primeiro pet?")),
            DropdownMenuItem(
                value: "cidade", child: Text("Em que cidade você nasceu?")),
            DropdownMenuItem(
                value: "prof",
                child: Text("Qual era o nome do seu professor favorito?")),
          ],
          onChanged: (v) => setState(() => pergunta = v ?? ""),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: respostaCtrl,
          textInputAction: TextInputAction.done, // <- adicionado
  onSubmitted: (_) { // <- adicionado
    if (pergunta.isEmpty || respostaCtrl.text.trim().isEmpty) return;
    nextPage();
  },
   autofocus: true, // 🔹 Alteração: já inicia com foco neste campo
          decoration: const InputDecoration(hintText: "Resposta"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
          ),
          onPressed: () {
            if (pergunta.isEmpty || respostaCtrl.text.trim().isEmpty) return;
            nextPage();
          },
          child: const Text("Próximo"),
        ),
      ],
    ));
  }

// TELA 5 - Biometria
Widget _biometria() {
  final nome = nomeCtrl.text.trim();
  final saudacao = nome.isEmpty ? "" : ", $nome";
  return _wrapMagic(Column(
    children: [
      Image.asset(
        "assets/animation/guardiao_biometria_transparente.png",
        height: 120,
      ),
      const SizedBox(height: 16),
      _title("Deseja usar biometria para acesso rápido$saudacao?"),
      const Text(
        "Vejo que sua magia é poderosa. Deseja usar sua própria marca (biometria) para acessar seu cofre mais rápido?",
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonSecondary,
                foregroundColor: AppColors.buttonText,
              ),
              onPressed: () {
                biometriaEscolha = false;
                nextPage();
              },
              child: const Text("Não agora"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
              ),
              onPressed: () {
                biometriaEscolha = true;
                // TODO: Implementar autenticação biométrica aqui
                nextPage();
              },
              child: const Text("Sim, eu quero"),
            ),
          ),
        ],
      ),
    ],
  ));
}


// TELA 6 - Final
Widget _finalizacao() {
  final nome = nomeCtrl.text.trim();
  return _wrapMagic(Column(
    children: [
      Image.asset(
        "assets/animation/guardiao_final_transparente.png",
        height: 150,
      ),
      const SizedBox(height: 16),
      _title(
          "Perfeito${nome.isEmpty ? "!" : ", $nome!"} Agora você está pronto."),
      const Text(
        "Suas senhas estão seguras sob minha proteção. Vamos juntos nesta jornada!",
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
        ),
        onPressed: () async {
          // 🔹 Persistir dados no SettingsService
          await _settings.setLoginPassword(senhaCtrl.text.trim());
          await SettingsService.setMasterPassword(senhaCtrl.text.trim()); // redundante mas garante  
          await SettingsService.setProfile(
            avatarPath: "",
            name: nome,
            email: "",
          );
          await SettingsService.setBiometryEnabled(biometriaEscolha);

          // ⚡ TODO: salvar pergunta/resposta de segurança também
          final box = await Hive.openBox(SettingsService.settingsBoxName);
          await box.put("security_question", pergunta);
          await box.put("security_answer", respostaCtrl.text.trim());

          // Navega para a tela principal já chamando pelo nome informado
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainScreen(userName: nome),
            ),
          );
        },
        child: const Text("Entrar no Cofre"),
        ),
      ],
    ));
  }
}
