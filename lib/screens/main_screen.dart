import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<PasswordModel> passwords = [];
  String searchQuery = '';
  bool showConfidential = false;

  @override
  void initState() {
    super.initState();
    loadPasswords();
    showConfidential = false;
  }

  void loadPasswords() {
    passwords = PasswordService.searchPasswords(searchQuery, includeConfidential: showConfidential);
    setState(() {});
  }

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

  void addPasswordDialog({PasswordModel? editing}) {
    final siteController = TextEditingController(text: editing?.siteName ?? '');
    final userController = TextEditingController(text: editing?.username ?? '');
    final passController = TextEditingController(text: editing?.password ?? '');
    final categoryController = TextEditingController(text: editing?.category ?? 'personal');
    final notesController = TextEditingController(text: editing?.notes ?? '');
    bool isConfidential = editing?.confidential ?? false;

    bool obscurePassword = true; // controla mostrar/ocultar senha
    String strengthText = '';
    String strengthLevel = '';

    void updateStrength(String pwd) {
      final res = PasswordService.calculatePasswordStrength(pwd);
      strengthText = res['text']!;
      strengthLevel = res['level']!;
      setState(() {});
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(editing == null ? 'Adicionar Senha' : 'Editar Senha'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: siteController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Site/Serviço'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: 'Usuário/Email'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passController,
                        obscureText: obscurePassword,
                        onChanged: (v) => updateStrength(v),
                        decoration: const InputDecoration(labelText: 'Senha'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      tooltip: 'Gerar Senha',
                      onPressed: () {
                        final gen = PasswordService.generatePassword(length: 16);
                        passController.text = gen;
                        updateStrength(gen);
                      },
                    ),
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                      tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (passController.text.isNotEmpty)
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
                TextField(
                  controller: categoryController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isConfidential,
                      onChanged: (v) {
                        setState(() => isConfidential = v ?? false);
                      },
                    ),
                    const Text('Marcar como confidencial (requer senha para visualizar)'),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final id = editing?.id ?? const Uuid().v4();
                final model = PasswordModel(
                  id: id,
                  siteName: siteController.text,
                  username: userController.text,
                  password: passController.text,
                  category: categoryController.text.isEmpty ? 'Personal' : categoryController.text,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardião de Senhas'),
        actions: [
          IconButton(
            icon: Icon(showConfidential ? Icons.visibility : Icons.visibility_off),
            tooltip: showConfidential ? 'Ocultar confidenciais' : 'Mostrar confidenciais',
            onPressed: toggleShowConfidential,
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/backup')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadPasswords(),
        child: list.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('Nenhuma senha'),
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final p = list[i];
                  return ListTile(
                    title: Text(p.siteName),
                    subtitle: Text(p.username),
                    leading: p.confidential ? const Icon(Icons.lock) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => addPasswordDialog(editing: p)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(p.id)),
                      ],
                    ),
                    onTap: () {
                      if (p.confidential && !showConfidential) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha confidencial — verifique modo confidencial')),
                        );
                        return;
                      }
                      Clipboard.setData(ClipboardData(text: p.password));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha copiada')));
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPasswordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
