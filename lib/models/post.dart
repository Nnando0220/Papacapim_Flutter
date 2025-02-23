import 'comment.dart';

class Post {
  final String id; // Identificador único do post
  final String username;
  final String content;
  int likes;
  int deslikes;
  final DateTime timestamp;
  final List<Comment> comments; // Lista de comentários associados
  bool isLiked;
  bool isDesliked;

  Post({
    required this.id,
    required this.username,
    required this.content,
    required this.likes,
    required this.deslikes,
    required this.timestamp,
    List<Comment>? comments,
    required this.isLiked,
    required this.isDesliked,
  }) : comments = comments ?? [];

  // Método para adicionar comentário
  void addComment(Comment comment) {
    comments.add(comment);
  }

  static final List<Post> _posts = [
    Post(
      id: '1',
      username: 'João Silva',
      content: 'Curtindo um dia incrível na praia!',
      likes: 156,
      deslikes: 4,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'Maria Souza',
          content: 'Que lugar maravilhoso! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        Comment(
          id: '1',
          postId: '1',
          username: 'Maria Souza',
          content: 'Que lugar maravilhoso! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        Comment(
          id: '1',
          postId: '1',
          username: 'Maria Souza',
          content: 'Que lugar maravilhoso! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '2',
      username: 'João Silva',
      content: 'Explorando as montanhas!',
      likes: 98,
      deslikes: 2,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'Maria Souza',
          content: 'Que lugar maravilhoso! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        Comment(
          id: '1',
          postId: '1',
          username: 'Maria Souza',
          content: 'Que lugar maravilhoso! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
    Post(
      id: '3',
      username: 'Maria Souza',
      content: 'Aproveitando o dia com os amigos!',
      likes: 120,
      deslikes: 5,
      comments: [
        Comment(
          id: '1',
          postId: '1',
          username: 'João Silva',
          content: 'Que lugar incrível! 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: false,
      isDesliked: false,
    ),
  ];

  static List<Post> getPosts() {
    return _posts;
  }

  static List<Post> getPostsByUser(String username) {
    return _posts.where((post) => post.username == username).toList();
  }
}