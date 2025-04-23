class User {
  final String login;
  final String name;
  final DateTime timestamp;

  User({
    required this.login,
    required this.name,
    required this.timestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['user_login'] ?? json['login'] ?? 'Usuário Desconhecido',
      name: json['name'] ?? 'Nome Desconhecido',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(), 
    );
  }
}