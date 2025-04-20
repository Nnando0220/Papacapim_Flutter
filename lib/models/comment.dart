class Comment {
  final int id; 
  final int postId; 
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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '', 
      postId: json['post_id'] ?? '', 
      username: json['user_login'] ?? 'Usuário Desconhecido', 
      content: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(), 
    );
  }
}