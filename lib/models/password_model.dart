//Arquvio password_model.dart para o modelo de senha do Guardião de Senhas
// Este arquivo define a estrutura de dados para armazenar informações de senhas, incluindo site, nome de usuário, senha, categoria e notas adicionais.
class PasswordModel {
  final String id;
  final String siteName;
  final String username;
  final String password;
  final String category;
  final String? notes;
  final bool confidential; // novo
  final DateTime createdAt;
  final DateTime lastModified;

  PasswordModel({
    required this.id,
    required this.siteName,
    required this.username,
    required this.password,
    required this.category,
    this.notes,
    this.confidential = false,
    required this.createdAt,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() => {
        'siteName': siteName,
        'username': username,
        'password': password,
        'category': category,
        'notes': notes,
        'confidential': confidential,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
      };

  factory PasswordModel.fromMap(String id, Map data) {
    return PasswordModel(
      id: id,
      siteName: data['siteName'],
      username: data['username'],
      password: data['password'],
      category: data['category'],
      notes: data['notes'],
      confidential: data['confidential'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
      lastModified: DateTime.parse(data['lastModified']),
    );
  }
}
