// Arquivo main_screen.dart para a tela principal do Guardião de Senhas
// Esta tela exibe as "pastas" (categorias) que contêm as senhas, permitindo ao usuário navegar entre elas.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';
import 'category_screen.dart';
import 'settings_screen.dart';

/// Tela principal que agora mostra apenas as "pastas" (categorias).
/// As pastas só aparecem se houver pelo menos 1 senha naquela categoria.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<PasswordModel> passwords = [];
  String searchQuery = '';
  bool showConfidential = false;

  // mapa com categorias pré-definidas e suas descrições.
  // essas descrições serão exibidas SOMENTE no diálogo de adicionar/editar senha.
  final Map<String, String> categoryInfo = {
    'Pessoal': 'Documentos, cadastros gerais, compras online',
    'Profissional': 'Email corporativo, sistemas de trabalho, intranet, cursos',
    'Bancos e Finanças': 'Contas bancárias, cartões, investimentos, PayPal, Pix',
    'Redes Sociais': 'Instagram, Facebook, Twitter, etc.',
    'Jogos': 'Steam, PlayStation, Xbox, Nintendo, jogos mobile',
    'Streaming e Assinaturas': 'Netflix, Spotify, Amazon Prime, Disney+, etc.',
    'Compras Online': 'Mercado Livre, Shopee, Amazon, Shein, etc.',
    'Serviços': 'Conta de luz, água, telefone, internet, provedores',
    'Saúde': 'Planos de saúde, apps de treino, farmácias',
    'Segurança': 'Autenticadores, cofres de senha, backups',
  };

  @override
  void initState() {
    super.initState();
    loadPasswords();
    showConfidential = false;
  }

  /// Carrega todas as senhas (filtradas por confidencial conforme flag).
  void loadPasswords() {
    passwords = PasswordService.searchPasswords(searchQuery, includeConfidential: showConfidential);
    setState(() {});
  }

  /// Alterna visibilidade das senhas confidenciais
  void toggleShowConfidential() async {
    if (!showConfidential) {
      final result = await _askMasterPassword();
      if (!result) return;
      setState(() => showConfidential = true);
    } else {
      setState(() => showConfidential = false);
    }
    loadPasswords();
  }

  /// Pede a senha mestra e retorna true se ok.
  Future<bool> _askMasterPassword() async {
    final controller = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verificar Senha Mestra'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Senha Mestra'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final ok = PasswordService.verifyMasterPassword(controller.text.trim());
              Navigator.pop(context, ok);
            },
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  /// Retorna o conjunto de categorias existentes (apenas categorias que já possuem senhas).
  /// Isso garante que "pastas" só aparecem depois que uma senha for criada nessa categoria.
  Set<String> _existingCategories() {
    return passwords.map((p) => p.category).toSet();
  }

  /// Conta quantas senhas existem numa categoria.
  int _countForCategory(String category) {
    return passwords.where((p) => p.category == category).length;
  }

  /// Diálogo para adicionar senha (usado também pela CategoryScreen).
  /// Aqui incluímos seleção de categoria com descrição exibida quando selecionada.
  Future<void> addPasswordDialog({PasswordModel? editing, String? forceCategory}) async {
    final siteController = TextEditingController(text: editing?.siteName ?? '');
    final userController = TextEditingController(text: editing?.username ?? '');
    final passController = TextEditingController(text: editing?.password ?? '');
    // se chamado a partir de uma categoria específica, preenche e bloqueia
    final categoryController = TextEditingController(text: editing?.category ?? (forceCategory ?? 'Pessoal'));
    final notesController = TextEditingController(text: editing?.notes ?? '');
    bool isConfidential = editing?.confidential ?? false;

    bool obscurePassword = true; // controla mostrar/ocultar senha no diálogo
    String strengthText = '';
    String strengthLevel = '';

    // função que calcula força e atualiza variáveis (vai chamar setState do StatefulBuilder)
    void updateStrength(String pwd, void Function(void Function()) innerSetState) {
      final res = PasswordService.calculatePasswordStrength(pwd);
      strengthText = res['text']!;
      strengthLevel = res['level']!;
      innerSetState(() {}); // atualiza apenas o diálogo
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, innerSetState) {
        // lista de categorias para o dropdown: usamos as categorias pré-definidas
        // + as categorias já existentes (para garantir cobertura).
        final existing = _existingCategories().toList();
        final predefined = categoryInfo.keys.toList();
        // unir mantendo ordem: predefined primeiro, depois extras que não estão em predefined
        final union = [
          ...predefined,
          ...existing.where((c) => !predefined.contains(c)).toList(),
          'Outra...'
        ];

        // se "Outra..." for selecionado o usuário pode digitar nova categoria
        final isCustomCategory = !categoryInfo.containsKey(categoryController.text) && categoryController.text != 'Personal';

        return AlertDialog(
          title: Text(editing == null ? 'Adicionar Senha' : 'Editar Senha'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Site/Serviço (começa com maiúscula automaticamente)
                TextField(
                  controller: siteController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Site/Serviço'),
                ),
                const SizedBox(height: 8),

                // Usuário/Email
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: 'Usuário/Email'),
                ),
                const SizedBox(height: 8),

                // Linha da senha: campo + gerar + mostrar/ocultar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passController,
                        obscureText: obscurePassword,
                        onChanged: (v) => updateStrength(v, innerSetState),
                        decoration: const InputDecoration(labelText: 'Senha'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      tooltip: 'Gerar Senha',
                      onPressed: () {
                        final gen = PasswordService.generatePassword(length: 16);
                        passController.text = gen;
                        updateStrength(gen, innerSetState);
                      },
                    ),
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                      tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () {
                        innerSetState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Indicador de força - aparece sempre que o campo não estiver vazio
                if (passController.text.isNotEmpty || strengthText.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Força: ${strengthText.isEmpty ? PasswordService.calculatePasswordStrength(passController.text)['text'] : strengthText}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (PasswordService.calculatePasswordStrength(passController.text)['level'] == 'weak')
                            ? 0.33
                            : (PasswordService.calculatePasswordStrength(passController.text)['level'] == 'medium')
                                ? 0.66
                                : 1.0,
                        minHeight: 6,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),

                // Dropdown de categorias: mostra descrição quando uma categoria pré-definida for selecionada.
                // Se forceCategory foi passada (vindo do CategoryScreen), deixamos bloqueado.
                if (forceCategory == null) ...[
                  // Campo para escolher categoria (dropdown)
                  DropdownButtonFormField<String>(
                    value: union.contains(categoryController.text) ? categoryController.text : union.first,
                    items: union.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      innerSetState(() {
                        if (val == 'Outra...') {
                          categoryController.text = '';
                        } else {
                          categoryController.text = val;
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoria'),
                  ),
                  const SizedBox(height: 8),

                  // Se usuário escolheu uma categoria pré-definida, mostramos a descrição.
                  if (categoryController.text.isNotEmpty && categoryInfo.containsKey(categoryController.text))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Descrição: ${categoryInfo[categoryController.text]}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                      ],
                    ),

                  // Se escolheu "Outra..." ou digitou algo que não é pré-definido, mostrar um campo de texto
                  if (categoryController.text.isEmpty)
                    TextField(
                      controller: categoryController,
                      textCapitalization: TextCapitalization.sentences, // começa com maiúscula
                      decoration: const InputDecoration(labelText: 'Nova categoria'),
                    ),
                ] else ...[
                  // Se estamos adicionando a partir de uma CategoryScreen, bloqueamos o campo
                  TextField(
                    controller: categoryController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                  ),
                ],

                const SizedBox(height: 8),

                // Notas (capitalização de frases)
                TextField(
                  controller: notesController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),

                // Checkbox de confidencialidade (mantido)
                Row(
                  children: [
                    Checkbox(
                      value: isConfidential,
                      onChanged: (v) {
                        innerSetState(() => isConfidential = v ?? false);
                      },
                    ),
                    const Expanded(child: Text('Marcar como confidencial (requer senha para visualizar)')),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                // normalizar: se o campo estiver vazio, usar "Personal" por padrão
                final chosenCategory = categoryController.text.isEmpty ? 'Personal' : categoryController.text;
                final id = editing?.id ?? const Uuid().v4();
                final model = PasswordModel(
                  id: id,
                  siteName: siteController.text,
                  username: userController.text,
                  password: passController.text,
                  category: chosenCategory,
                  notes: notesController.text,
                  confidential: isConfidential,
                  createdAt: editing?.createdAt ?? DateTime.now(),
                  lastModified: DateTime.now(),
                );

                if (editing == null) {
                  await PasswordService.addPassword(model);
                } else {
                  await PasswordService.editPassword(id, model);
                }

                loadPasswords();
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      }),
    );
  }

  /// Abre CategoryScreen com a categoria escolhida
  void openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryScreen(category: category)),
    ).then((_) {
      // quando voltar da tela de categoria, recarrega a lista
      loadPasswords();
    });
  }

  /// Exclui senha com confirmação
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Confirma exclusão?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await PasswordService.deletePassword(id);
              loadPasswords();
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = passwords;
    final existingCategories = _existingCategories().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardião de Senhas'),
        actions: [
          IconButton(
            icon: Icon(showConfidential ? Icons.visibility : Icons.visibility_off),
            tooltip: showConfidential ? 'Ocultar confidenciais' : 'Mostrar confidenciais',
            onPressed: toggleShowConfidential,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),

      // corpo: mostra apenas as pastas (categorias que já existem)
      body: RefreshIndicator(
        onRefresh: () async => loadPasswords(),
        child: existingCategories.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('Nenhuma pasta ainda. Adicione senhas para criar pastas.'),
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: existingCategories.length,
                itemBuilder: (context, i) {
                  final cat = existingCategories[i];
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(cat),
                    // mostra número de senhas na pasta
                    trailing: CircleAvatar(
                      radius: 14,
                      child: Text(_countForCategory(cat).toString()),
                    ),
                    onTap: () => openCategory(cat), // abre CategoryScreen
                  );
                },
              ),
      ),

      // floating action: abre diálogo de adicionar sem forçar categoria (o usuário escolhe)
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPasswordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
