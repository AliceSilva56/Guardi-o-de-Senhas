//Arquivo: lib/screens/confidencial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';
import '../theme/app_theme_confidential.dart';
import '../utils/category_info.dart';


class ConfidencialScreen extends StatefulWidget {
  const ConfidencialScreen({super.key});

  @override
  State<ConfidencialScreen> createState() => _ConfidencialScreenState();
}

class _ConfidencialScreenState extends State<ConfidencialScreen> {
  List<PasswordModel> passwords = [];
  List<String> categories = [];

  Iterable<String> _existingCategories() {
    return passwords.map((p) => p.category).toSet();
  }

  @override
  void initState() {
    super.initState();
    loadPasswords();
  }

  void loadPasswords() {
    final all = PasswordService.searchPasswords('', includeConfidential: true);
    passwords = all.where((p) => p.confidential).toList();
    categories = passwords.map((p) => p.category).toSet().toList();
    setState(() {});
  }

  int _countForCategory(String category) =>
      passwords.where((p) => p.category == category).length;

  void openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ConfidentialCategoryScreen(
          category: category,
          passwords: passwords.where((p) => p.category == category).toList(),
        ),
      ),
    ).then((_) => loadPasswords());
  }

// Diálogo para adicionar/editar senha
Future<void> addPasswordDialog({PasswordModel? editing, String? forceCategory}) async {
    final siteController = TextEditingController(text: editing?.siteName ?? '');
    final userController = TextEditingController(text: editing?.username ?? '');
    final passController = TextEditingController(text: editing?.password ?? '');
    final categoryController = TextEditingController(text: editing?.category ?? (forceCategory ?? 'Pessoal'));
    final notesController = TextEditingController(text: editing?.notes ?? '');
    bool isConfidential = true;

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
          backgroundColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
          title: Text(editing == null ? 'Adicionar Senha' : 'Editar Senha', style: TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: siteController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                   autofocus: true, // 🔹 Alteração: já inicia com foco no campo Site/Serviço
                  decoration: InputDecoration(
                    labelText: 'Site/Serviço',
                    labelStyle: TextStyle(color: secondaryTextColor),
                    filled: true,
                    fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                    fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                          fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.shuffle, color: ConfidentialColors.buttonPrimary),
                      tooltip: 'Gerar Senha',
                      onPressed: () {
                        final gen = PasswordService.generatePassword(length: 16);
                        passController.text = gen;
                        updateStrength(gen, innerSetState);
                      },
                    ),
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off, color: ConfidentialColors.buttonPrimary),
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
                        color: ConfidentialColors.primary,
                        backgroundColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                      ),
                    ],
                  ),
                  // adiciona um espaçamento se a força da senha for exibida
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
                  // Adiciona o campo de descrição da categoria
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      errorText: categoryError,
                      filled: true,
                      fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                    ),
                    dropdownColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
                  ),
                  const SizedBox(height: 4),
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
                      fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                    fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isConfidential,
                      activeColor: ConfidentialColors.primary,
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
              style: ElevatedButton.styleFrom(backgroundColor: ConfidentialColors.buttonPrimary, foregroundColor: ConfidentialColors.buttonText),
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
    final textColor = isDark ? ConfidentialColors.darkText : ConfidentialColors.lightText;
    final secondaryTextColor = isDark ? ConfidentialColors.darkTextSecondary : ConfidentialColors.lightTextSecondary;
    final backgroundColor = isDark ? ConfidentialColors.darkBackground : ConfidentialColors.lightBackground;
    final appBarColor = isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: 1.0,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: isDark
                    ? const [
                        Color.fromARGB(255, 167, 77, 247), // Violeta Futurista
                        Color.fromARGB(255, 102, 41, 223), // Azul Profundo
                      ]
                    : const [
                        Color.fromARGB(255, 203, 147, 252), // Lavanda Suave
                        Color.fromARGB(255, 143, 150, 247), // Azul Céu
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Modo Confidencial - Somente os escolhidos podem ver.',
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Color.fromARGB(136, 105, 105, 105),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadPasswords(),
        child: categories.isEmpty
            ? ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Nenhuma pasta confidencial ainda. Adicione senhas para criar pastas.',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                  )
                ],
              )
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return ListTile(
                    leading: Icon(Icons.folder, color: textColor),
                    title: Text(cat, style: TextStyle(color: textColor)),
                    trailing: CircleAvatar(
                      radius: 14,
                      backgroundColor: ConfidentialColors.primary,
                      child: Text(
                        _countForCategory(cat).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () => openCategory(cat),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPasswordDialog(),
        backgroundColor: ConfidentialColors.buttonPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tela de categoria confidencial (igual à CategoryScreen, mas só mostra confidenciais)
// Move addPasswordDialog to a global function
Future<void> showAddPasswordDialog(BuildContext context, {PasswordModel? editing, String? forceCategory, required VoidCallback reloadPasswords}) async {
  final siteController = TextEditingController(text: editing?.siteName ?? '');
  final userController = TextEditingController(text: editing?.username ?? '');
  final passController = TextEditingController(text: editing?.password ?? '');
  final categoryController = TextEditingController(text: editing?.category ?? (forceCategory ?? 'Pessoal'));
  final notesController = TextEditingController(text: editing?.notes ?? '');
  bool isConfidential = true;

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

  final allPasswords = PasswordService.searchPasswords('', includeConfidential: true);
  final passwords = allPasswords.where((p) => p.confidential).toList();
  final existingCategories = passwords.map((p) => p.category).toSet().toList();

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(builder: (context, innerSetState) {
      final predefined = categoryInfo.keys.toList();
      final union = [
        ...predefined,
        ...existingCategories.where((c) => !predefined.contains(c)).toList(),
        'Outra...'
      ];

      String getCategoryDescription() {
        return categoryInfo[categoryController.text] ?? '';
      }

      return AlertDialog(
        backgroundColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
        title: Text(editing == null ? 'Adicionar Senha' : 'Editar Senha', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: siteController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: textColor),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Site/Serviço',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                  fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                        fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shuffle, color: ConfidentialColors.buttonPrimary),
                    tooltip: 'Gerar Senha',
                    onPressed: () {
                      final gen = PasswordService.generatePassword(length: 16);
                      passController.text = gen;
                      updateStrength(gen, innerSetState);
                    },
                  ),
                  IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off, color: ConfidentialColors.buttonPrimary),
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
                      color: ConfidentialColors.primary,
                      backgroundColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
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
                    fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                  ),
                  dropdownColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
                ),
                const SizedBox(height: 4),
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
                    fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
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
                  fillColor: isDark ? ConfidentialColors.darkInputBackground : ConfidentialColors.lightInputBackground,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.inputBorder)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ConfidentialColors.primary, width: 2)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: isConfidential,
                    activeColor: ConfidentialColors.primary,
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
            style: ElevatedButton.styleFrom(backgroundColor: ConfidentialColors.buttonPrimary, foregroundColor: ConfidentialColors.buttonText),
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

              reloadPasswords();
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    }),
  );
}

class _ConfidentialCategoryScreen extends StatelessWidget {
  final String category;
  final List<PasswordModel> passwords;
  const _ConfidentialCategoryScreen({required this.category, required this.passwords});

  void _confirmDelete(BuildContext context, String id, VoidCallback reload) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? ConfidentialColors.darkText : ConfidentialColors.lightText;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
      title: Text('Excluir', style: TextStyle(color: textColor)),
      content: Text('Confirma exclusão?', style: TextStyle(color: textColor)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: textColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ConfidentialColors.buttonPrimary,
            foregroundColor: ConfidentialColors.buttonText,
          ),
          onPressed: () async {
            await PasswordService.deletePassword(id);
            reload(); // chama primeiro para atualizar a lista
            Navigator.pop(context); // depois fecha o diálogo
          },
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ConfidentialColors.darkText : ConfidentialColors.lightText;
    final secondaryTextColor = isDark ? ConfidentialColors.darkTextSecondary : ConfidentialColors.lightTextSecondary;

    return StatefulBuilder(
      builder: (context, setState) => Scaffold(
        appBar: AppBar(
          title: Text(category),
          backgroundColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
        ),
        body: passwords.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Nenhuma senha nessa pasta', style: TextStyle(color: secondaryTextColor)),
                ),
              )
            : ListView.builder(
                itemCount: passwords.length,
                itemBuilder: (context, i) {
                  final p = passwords[i];
                  return ListTile(
                    title: Text(p.siteName, style: TextStyle(color: textColor)),
                    subtitle: Text(p.username, style: TextStyle(color: textColor)),
                    leading: const Icon(Icons.lock),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await showAddPasswordDialog(
                              context,
                              editing: p,
                              forceCategory: category,
                              reloadPasswords: () => setState(() {}),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, p.id, () => setState(() {})),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Detalhes da senha
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
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            );
                          });
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}