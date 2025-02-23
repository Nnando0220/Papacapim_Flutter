class Comment {
  final String id; // Identificador único do comentário
  final String postId; // Referência ao post
  final String username;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.username,
    required this.content,
    required this.timestamp,
  });
}