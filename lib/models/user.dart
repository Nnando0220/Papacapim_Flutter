class User {
  final String username;
  final int posts;
  final int followers;
  final int following;
  final bool isCurrentUser;

  User({
    required this.username,
    required this.posts,
    required this.followers,
    required this.following,
    required this.isCurrentUser,
  });

  static final List<User> _usersProfile = [
    User(
      username: 'João Silva',
      posts: 42,
      followers: 1520,
      following: 890,
      isCurrentUser: true,
    ),
    User(
      username: 'Maria Souza',
      posts: 65,
      followers: 2100,
      following: 750,
      isCurrentUser: false,
    ),
    // Add more mock users as needed
  ];

  static List<User> getUsers() {
    return _usersProfile;
  }

  static User getUserByUsername(String username) {
    return _usersProfile.firstWhere((user) => user.username == username);
  }
}