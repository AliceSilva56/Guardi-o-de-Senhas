// Arquivo category_screen.dart para a tela de categorias do Guardião de Senhas
// Esta tela exibe as senhas de uma categoria específica, permitindo adicionar, editar e excluir senhas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';
// import 'registro_guardiao_flow.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});
  

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<PasswordModel> categoryPasswords = [];

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
    loadCategoryPasswords();
  }

  void loadCategoryPasswords() {
    // Antes: trazia inclusive confidenciais
    // categoryPasswords = PasswordService.getByCategory(widget.category, includeConfidential: true);

    // Agora: pega apenas senhas normais, confidenciais ficam fora desta tela
    categoryPasswords = PasswordService.getByCategory(widget.category)
        .where((p) => !p.confidential)
        .toList();

    setState(() {});
  }

  Future<void> addPasswordInCategory({PasswordModel? editing}) async {
    final siteController = TextEditingController(text: editing?.siteName ?? '');
    final userController = TextEditingController(text: editing?.username ?? '');
    final passController = TextEditingController(text: editing?.password ?? '');
    final notesController = TextEditingController(text: editing?.notes ?? '');
    bool isConfidential = editing?.confidential ?? false;

    bool obscurePassword = true;
    String strengthText = '';
    String strengthLevel = '';

    String? errorUser;
    String? errorPassword;

    void updateStrength(String pwd, void Function(void Function()) innerSetState) {
      final res = PasswordService.calculatePasswordStrength(pwd);
      strengthText = res['text']!;
      strengthLevel = res['level']!;
      innerSetState(() {});
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, innerSetState) {
        return AlertDialog(
          title: Text(editing == null ? 'Adicionar Senha - ${widget.category}' : 'Editar Senha'),
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
                  decoration: InputDecoration(
                    labelText: 'Usuário/Email',
                    errorText: errorUser,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: passController,
                        obscureText: obscurePassword,
                        onChanged: (v) => updateStrength(v, innerSetState),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          errorText: errorPassword,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      onPressed: () {
                        final gen = PasswordService.generatePassword(length: 16);
                        passController.text = gen;
                        updateStrength(gen, innerSetState);
                      },
                    ),
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        innerSetState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

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

                TextFormField(
                  initialValue: widget.category,
                  readOnly: true,
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
                // Validação
                innerSetState(() {
                  errorUser = userController.text.trim().isEmpty ? 'Campo obrigatório' : null;
                  errorPassword = passController.text.trim().isEmpty ? 'Campo obrigatório' : null;
                });

                if (errorUser != null || errorPassword != null) {
                  return;
                }

                final id = editing?.id ?? const Uuid().v4();
                final model = PasswordModel(
                  id: id,
                  siteName: siteController.text,
                  username: userController.text,
                  password: passController.text,
                  category: widget.category,
                  notes: notesController.text,
                  confidential: isConfidential,
                  createdAt: editing?.createdAt ?? DateTime.now(),
                  lastModified: DateTime.now(),
                );

                final passwordService = PasswordService();
                if (editing == null) {
                  await passwordService.addPassword(model);
                } else {
                  await PasswordService.editPassword(id, model);
                }

                loadCategoryPasswords();
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
              loadCategoryPasswords();
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void showPasswordDetail(PasswordModel p) {
    showDialog(
      context: context,
      builder: (_) {
        bool obscure = true;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Detalhes da Senha'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.siteName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.username)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          obscure ? '••••••••' : p.password,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar senha',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: p.password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Senha copiada para área de transferência')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.folder, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.category)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (p.notes?.isNotEmpty ?? false)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p.notes ?? '')),
                      ],
                    ),
                  if (p.notes?.isNotEmpty ?? false) const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Criada: ${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.update, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Última modificação: ${p.lastModified.day}/${p.lastModified.month}/${p.lastModified.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadCategoryPasswords(),
        child: categoryPasswords.isEmpty
            ? ListView(
                children: const [
                  Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Nenhuma senha nessa pasta'))),
                ],
              )
            : ListView.builder(
                itemCount: categoryPasswords.length,
                itemBuilder: (context, i) {
                  final p = categoryPasswords[i];
                  return ListTile(
                    title: Text(p.siteName),
                    subtitle: Text(p.username),
                    leading: p.confidential ? const Icon(Icons.lock) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => addPasswordInCategory(editing: p)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(p.id)),
                      ],
                    ),
                    onTap: () => showPasswordDetail(p),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPasswordInCategory(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
