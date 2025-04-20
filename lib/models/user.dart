class User {
  final String login;
  final String name;

  User({
    required this.login,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['user_login'] ?? json['login'] ?? 'Usuário Desconhecido',
      name: json['name'] ?? 'Nome Desconhecido',
    );
  }
}