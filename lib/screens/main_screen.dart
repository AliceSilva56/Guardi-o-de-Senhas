// Arquivo main_screen.dart para a tela principal do Guardião de Senhas
// Esta tela exibe as "pastas" (categorias) que contêm as senhas, permitindo ao usuário navegar entre elas.

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/password_model.dart';
import '../services/password_service.dart';
import '../services/settings_service.dart';
import '../services/biometric_service.dart';
import 'category_screen.dart';
import 'confidencial_screen.dart';
import 'settings_screen.dart';
import '../theme/app_colors.dart';
import '../utils/category_info.dart';


class MainScreen extends StatefulWidget {
  final String? userName; // ← acréscimo: nome opcional

  const MainScreen({super.key, this.userName});

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
    // sempre carrega apenas senhas normais (não confidenciais)
    final all = PasswordService.searchPasswords(searchQuery, includeConfidential: false);
    passwords = all.where((p) => !p.confidential).toList();
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
    bool isAuthenticating = false;

    // Verifica se a biometria está disponível e habilitada
    final bool canUseBiometrics = await BiometricService.isBiometricAvailable() && 
                                 await BiometricService.isBiometricEnabled();

    // Função para tentar autenticação biométrica
    Future<bool> tryBiometricAuth() async {
      try {
        setState(() => isAuthenticating = true);
        final authenticated = await BiometricService.authenticate();
        if (authenticated) {
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
          return true;
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Autenticação biométrica falhou'),
                backgroundColor: Colors.orange[800],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return false;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro na autenticação biométrica'),
              backgroundColor: Colors.red[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      } finally {
        if (context.mounted) {
          setState(() => isAuthenticating = false);
        }
      }
    }

    // Se a biometria estiver disponível, tenta autenticar primeiro
    if (canUseBiometrics && !isAuthenticating) {
      return await tryBiometricAuth();
    }

    // Diálogo para pedir a senha mestra
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
        title: Text('Verificar Acesso', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Digite sua senha mestra ou use biometria', 
                 style: TextStyle(color: secondaryTextColor, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
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
            if (canUseBiometrics) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('OU', textAlign: TextAlign.center, 
                   style: TextStyle(color: secondaryTextColor)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return ElevatedButton.icon(
                    onPressed: isAuthenticating 
                        ? null 
                        : () async {
                            setState(() => isAuthenticating = true);
                            final result = await tryBiometricAuth();
                            if (!result) {
                              setState(() => isAuthenticating = false);
                            }
                          },
                    icon: isAuthenticating 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      isAuthenticating ? 'Autenticando...' : 'Usar Biometria',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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

// collecta categorias existentes
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
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
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

// Diálogo para adicionar/editar senha
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
                   autofocus: true, // 🔹 Alteração: já inicia com foco neste campo
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
                      fillColor: isDark ? AppColors.darkInputBackground : AppColors.lightInputBackground,
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    dropdownColor: isDark ? AppColors.darkAppBar : AppColors.lightAppBar,
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
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
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

                final passwordService = PasswordService();
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

// Construção da interface frase
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

  final existingCategories = _existingCategories().toList()..sort();
  final displayName = widget.userName?.trim().isEmpty ?? true ? 'Guardião' : widget.userName!.trim();

  return Scaffold(
    appBar: AppBar(
      title: AnimatedOpacity(
        duration: const Duration(seconds: 2), // animação suave
        opacity: 1.0, // sempre visível
        child: ShaderMask( // efeito de gradiente no texto
  shaderCallback: (bounds) { // cria o gradiente
    final isDark = Theme.of(context).brightness == Brightness.dark; // verifica tema
 
    return LinearGradient(
      colors: isDark
          ? const [
              Color.fromARGB(255, 167, 77, 247), // violeta futurista
              Color.fromARGB(255, 102, 41, 223), // azul escuro
            ]
          : const [
               Color.fromARGB(255, 203, 147, 252), // violeta futurista
              Color.fromARGB(255, 143, 150, 247), // azul escuro
            ],
      begin: Alignment.topLeft, // direção do gradiente
      end: Alignment.bottomRight, // direção do gradiente
    ).createShader(bounds);
  },
 child: FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    'Os pergaminhos de senha aguardam, $displayName',
     softWrap: true, // permite quebrar
        overflow: TextOverflow.visible, // não corta
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
      // Ícones de ação na AppBar
      // Ícone para mostrar/ocultar senhas confidenciais

      
actions: [
  IconButton(
  icon: Icon(
    Icons.lock, 
    color: textColor,
  ),
  tooltip: 'Modo Confidencial',
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _passwordController =
            TextEditingController();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark
            ? AppColors.darkAppBar
            : AppColors.lightAppBar;
        final titleColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        final textFieldColor = isDark
            ? AppColors.darkInputBackground
            : AppColors.lightInputBackground;

        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Acesso Confidencial', style: TextStyle(color: titleColor)),
          content: TextField(
            controller: _passwordController,
            autofocus: true,
            obscureText: true,
            style: TextStyle(color: titleColor),
            decoration: InputDecoration(
              hintText: 'Digite a senha',
              hintStyle: TextStyle(color: AppColors.inputHint),
              filled: true,
              fillColor: textFieldColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.buttonPrimary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
              ),
              // botão entrar no modo confidencial
              child: const Text('Entrar'),
              onPressed: () async {
                final service = SettingsService();
                final storedPassword = await SettingsService.getConfidentialPassword(); // ✅ certo
                final input = _passwordController.text;

                // Permite acesso com "1234" sempre
                // Se não há senha definida no settings, também permite qualquer senha
                if (input == "1234" || storedPassword == null || storedPassword.isEmpty || input == storedPassword) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfidencialScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Senha incorreta!")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  },
  
  //icon de configurações
  ),
  IconButton(
    icon: const Icon(Icons.settings),
    color: textColor,
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ),
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
                    child: Text(
                      'Nenhuma pasta ainda. Adicione senhas para criar pastas.',
                      style: TextStyle(color: secondaryTextColor),
                    ),
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

    // FloatingActionButton para adicionar nova senha
    floatingActionButton: FloatingActionButton(
      onPressed: () => addPasswordDialog(),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
      ),
    );
  }
}
