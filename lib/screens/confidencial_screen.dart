//Arquivo: lib/screens/confidencial_screen.dart
import 'package:flutter/material.dart';
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

  List<String> _existingCategories() {
  final box = PasswordService.getAllPasswords();
  final categories = <String>{};

  for (var password in box) {
    if (password is PasswordModel) {
      categories.add(password.category);
    }
  }

  return categories.toList();
}


  @override
  void initState() {
    super.initState();
    loadPasswords();
  }

  void loadPasswords() {
    final all = PasswordService.searchPasswords('', includeConfidential: true);
    passwords = all.where((p) => p.confidential).toList(); // só as senhas confidenciais
    setState(() {});
  }

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
                   autofocus: true, // 🔹 Alteração: já inicia com foco neste campo
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
    final backgroundColor = isDark ? ConfidentialColors.darkBackground : ConfidentialColors.lightBackground;
    final appBarColor = isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar;
    final textColor = isDark ? ConfidentialColors.darkText : ConfidentialColors.lightText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: 1.0,

           child: ShaderMask( // efeito de gradiente no texto
  shaderCallback: (bounds) { // cria o gradiente
    final isDark = Theme.of(context).brightness == Brightness.dark; // verifica tema
 
    return LinearGradient(
      colors: isDark
          ? const [ // cores para tema escuro
              Color.fromARGB(255, 167, 77, 247), // violeta futurista
              Color.fromARGB(255, 102, 41, 223), // azul escuro
            ]
          : const [ // cores para tema claro
               Color.fromARGB(255, 203, 147, 252), // violeta claro
              Color.fromARGB(255, 143, 150, 247), // azul claro
            ],
      begin: Alignment.topLeft, // direção do gradiente
      end: Alignment.bottomRight, // direção do gradiente
    ).createShader(bounds);
  },
  child: Text(
    'Modo Confidencial - Somente os escolhidos podem ver.',
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white, // precisa ser branco p/ Shader aplicar
      shadows: [
        Shadow(
          blurRadius: 8,
          color: Color.fromARGB(136, 105, 105, 105), // sombra sutil
          offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: passwords.isEmpty
          ? Center(child: Text('Nenhuma senha confidencial ainda.', style: TextStyle(color: textColor)))
          : ListView.builder(
              itemCount: passwords.length,
              itemBuilder: (context, i) {
                final p = passwords[i];
                return ListTile(
                  leading: Icon(Icons.key, color: textColor),
                  title: Text(p.siteName, style: TextStyle(color: textColor)),
                  subtitle: Text(p.username, style: TextStyle(color: textColor)),
                  onTap: () => addPasswordDialog(editing: p),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: isDark ? ConfidentialColors.darkAppBar : ConfidentialColors.lightAppBar,
                          title: Text('Excluir senha', style: TextStyle(color: textColor)),
                          content: Text('Tem certeza que deseja excluir esta senha?', style: TextStyle(color: textColor)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar', style: TextStyle(color: textColor)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ConfidentialColors.buttonPrimary,
                                foregroundColor: ConfidentialColors.buttonText,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await PasswordService.deletePassword(p.id);
                        loadPasswords();
                      }
                    },
                  ),
                );
              },
            ),

            // botão adicionar senha
      floatingActionButton: FloatingActionButton( 
        onPressed: () => addPasswordDialog(),
        backgroundColor: ConfidentialColors.buttonPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}