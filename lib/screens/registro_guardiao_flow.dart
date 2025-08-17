// Arquivo: lib/screens/registro_guardiao_flow.dart
// Esta tela é parte do fluxo de registro do Guardião de Senhas, onde o usuário
// é guiado por uma série de etapas para criar uma conta, definir uma senha mestra,
// escolher uma pergunta de segurança e decidir sobre o uso de biometria.
import 'package:flutter/material.dart';

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

  void nextPage() {
    if (pageIndex < 5) {
      setState(() => pageIndex++);
      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF2C1250)],
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
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    ),
  );

  // TELA 1 - Apresentação
  Widget _intro() {
    return _wrapMagic(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield, size: 120, color: Colors.amber),
        const SizedBox(height: 16),
        _title("Eu sou o elfo Guardião das Senhas. Meu nome é Sylas!"),
        const Text(
          "Minha missão é proteger todos os seus segredos. Mas antes, preciso conhecê-lo...",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
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
        _title("Me diga o seu nome"),
        TextField(
          controller: nomeCtrl,
          decoration: InputDecoration(
            hintText: "Seu nome",
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
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
    return _wrapMagic(Column(
      children: [
        _title("Escolha sua chave mestra"),
        TextField(
          controller: senhaCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Senha mestra",
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Dica: Use símbolos, números e letras. Uma chave forte mantém monstros afastados!"),
        const SizedBox(height: 20),
        ElevatedButton(
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
    return _wrapMagic(Column(
      children: [
        _title("Escolha uma pergunta de segurança"),
        DropdownButtonFormField<String>(
          value: pergunta.isEmpty ? null : pergunta,
          items: const [
            DropdownMenuItem(value: "pet", child: Text("Qual foi o nome do seu primeiro pet?")),
            DropdownMenuItem(value: "cidade", child: Text("Em que cidade você nasceu?")),
            DropdownMenuItem(value: "prof", child: Text("Qual era o nome do seu professor favorito?")),
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
          decoration: const InputDecoration(hintText: "Resposta"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
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
    return _wrapMagic(Column(
      children: [
        const Icon(Icons.fingerprint, size: 120),
        const SizedBox(height: 16),
        _title("Deseja usar biometria para acesso rápido?"),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  biometriaEscolha = true;
                  nextPage();
                },
                child: const Text("Sim, ativar"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  biometriaEscolha = false;
                  nextPage();
                },
                child: const Text("Não agora"),
              ),
            ),
          ],
        ),
      ],
    ));
  }

  // TELA 6 - Final
  Widget _finalizacao() {
    return _wrapMagic(Column(
      children: [
        const Icon(Icons.auto_awesome, size: 120, color: Colors.amber),
        const SizedBox(height: 16),
        _title("Perfeito! Agora você está pronto."), // Colocar para ele chamar o nome do usuário
        const Text(
          "Suas senhas estão seguras sob minha proteção. Vamos juntos nesta jornada!",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // TODO: Aqui você pode salvar os dados (Hive/secure storage) e navegar pra tela principal
            Navigator.of(context).pop(true);
          },
          child: const Text("Entrar no Cofre"),
        ),
      ],
    ));
  }
}
