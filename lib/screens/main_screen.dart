// Arquivo main_screen.dart para a tela principal do Guardião de Senhas
// Esta tela exibe as "pastas" (categorias) que contêm as senhas, permitindo ao usuário navegar entre elas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';
import 'category_screen.dart';
import 'settings_screen.dart';
import '../theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<PasswordModel> passwords = [];
  String searchQuery = '';
  bool showConfidential = false;

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

  void loadPasswords() {
    passwords = PasswordService.searchPasswords(
      searchQuery,
      includeConfidential: showConfidential,
    );
    setState(() {});
  }

  Future<void> toggleShowConfidential() async {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
        title: Text('Verificar Senha Mestra', style: TextStyle(color: textColor)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Senha Mestra',
            labelStyle: TextStyle(color: secondaryTextColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonText,
            ),
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

  Set<String> _existingCategories() => passwords.map((p) => p.category).toSet();
  int _countForCategory(String category) => passwords.where((p) => p.category == category).length;

  void openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryScreen(category: category)),
    ).then((_) => loadPasswords());
  }

  void confirmDelete(String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
        title: Text('Excluir', style: TextStyle(color: textColor)),
        content: Text('Confirma exclusão?', style: TextStyle(color: secondaryTextColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: TextStyle(color: textColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonText,
            ),
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

  Future<void> addPasswordDialog({PasswordModel? editing, String? forceCategory}) async {
    final siteController = TextEditingController(text: editing?.siteName ?? '');
    final userController = TextEditingController(text: editing?.username ?? '');
    final passController = TextEditingController(text: editing?.password ?? '');
    final categoryController = TextEditingController(text: editing?.category ?? (forceCategory ?? 'Pessoal'));
    final notesController = TextEditingController(text: editing?.notes ?? '');
    bool isConfidential = editing?.confidential ?? false;

    bool obscurePassword = true;
    String strengthText = '';
    String strengthLevel = '';

    String? userError;
    String? passError;
    String? categoryError;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    void updateStrength(String pwd, void Function(void Function()) innerSetState) {
      final res = PasswordService.calculatePasswordStrength(pwd);
      strengthText = res['text']!;
      strengthLevel = res['level']!;
      innerSetState(() {});
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, innerSetState) {
        final existing = _existingCategories().toList();
        final predefined = categoryInfo.keys.toList();
        final union = [
          ...predefined,
          ...existing.where((c) => !predefined.contains(c)).toList(),
          'Outra...'
        ];

        String getCategoryDescription() {
          return categoryInfo[categoryController.text] ?? '';
        }

        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
          title: Text(editing == null ? 'Adicionar Senha' : 'Editar Senha', style: TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: siteController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Site/Serviço',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: userController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Usuário/Email',
                    errorText: userError,
                    filled: true,
                    fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
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
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          errorText: passError,
                          filled: true,
                          fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.shuffle, color: AppColors.buttonPrimary),
                      tooltip: 'Gerar Senha',
                      onPressed: () {
                        final gen = PasswordService.generatePassword(length: 16);
                        passController.text = gen;
                        updateStrength(gen, innerSetState);
                      },
                    ),
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppColors.buttonPrimary),
                      tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () => innerSetState(() => obscurePassword = !obscurePassword),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (passController.text.isNotEmpty || strengthText.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Força: ${strengthText.isEmpty ? PasswordService.calculatePasswordStrength(passController.text)['text'] : strengthText}',
                          style: TextStyle(color: secondaryTextColor)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (strengthLevel == 'weak')
                            ? 0.33
                            : (strengthLevel == 'medium')
                                ? 0.66
                                : 1.0,
                        minHeight: 6,
                        color: AppColors.primary,
                        backgroundColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (forceCategory == null) ...[
                  DropdownButtonFormField<String>(
                    value: union.contains(categoryController.text) ? categoryController.text : union.first,
                    items: union.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: textColor)))).toList(),
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
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      errorText: categoryError,
                      filled: true,
                      fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    dropdownColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
                  ),
                  const SizedBox(height: 4),
                  // ---- AQUI MOSTRA A DESCRIÇÃO DA CATEGORIA ----
                  if (categoryController.text.isNotEmpty)
                    Text(
                      getCategoryDescription(),
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                ] else ...[
                  TextField(
                    controller: categoryController,
                    readOnly: true,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      errorText: categoryError,
                      filled: true,
                      fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                    ),
                  ),
                ],
                TextField(
                  controller: notesController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Notas',
                    filled: true,
                    fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isConfidential,
                      activeColor: AppColors.primary,
                      onChanged: (v) => innerSetState(() => isConfidential = v ?? false),
                    ),
                    Expanded(
                        child: Text('Marcar como confidencial (requer senha para visualizar)',
                            style: TextStyle(color: secondaryTextColor))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: TextStyle(color: textColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary, foregroundColor: AppColors.buttonText),
              onPressed: () async {
                innerSetState(() {
                  userError = userController.text.trim().isEmpty ? 'Campo obrigatório' : null;
                  passError = passController.text.trim().isEmpty ? 'Campo obrigatório' : null;
                  categoryError = categoryController.text.trim().isEmpty ? 'Campo obrigatório' : null;
                });
                if (userError != null || passError != null || categoryError != null) return;

                final chosenCategory = categoryController.text.isEmpty ? 'Pessoal' : categoryController.text;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    final existingCategories = _existingCategories().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Guardião de Senhas', style: TextStyle(color: textColor)),
        actions: [
          IconButton(
            icon: Icon(showConfidential ? Icons.visibility : Icons.visibility_off),
            tooltip: showConfidential ? 'Ocultar confidenciais' : 'Mostrar confidenciais',
            color: textColor,
            onPressed: toggleShowConfidential,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: textColor,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadPasswords(),
        child: existingCategories.isEmpty
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('Nenhuma pasta ainda. Adicione senhas para criar pastas.', style: TextStyle(color: secondaryTextColor)),
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: existingCategories.length,
                itemBuilder: (context, i) {
                  final cat = existingCategories[i];
                  return ListTile(
                    leading: Icon(Icons.folder, color: textColor),
                    title: Text(cat, style: TextStyle(color: textColor)),
                    trailing: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Text(_countForCategory(cat).toString(), style: const TextStyle(color: Colors.white)),
                    ),
                    onTap: () => openCategory(cat),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPasswordDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
