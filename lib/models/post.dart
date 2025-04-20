class Post {
  final int id; 
  final int postId; 
  final String login; 
  final String message;
  final DateTime timestamp;
  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.id,
    required this.postId,
    required this.login,
    required this.message,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '', 
      postId: json['post_id'] ?? 0, 
      login: json['user_login'] ?? 'Usuário Desconhecido',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(), 
      likes: json['likes_count'] ?? 0, 
      isLiked: json['current_user_liked'] ?? false,
      comments: json['comments_count'] ?? 0, 
    );
  }
}