import 'package:http/http.dart' as http;
import 'package:social_app/models/comment.dart';
import 'dart:convert';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/auth_service.dart';
import '../models/post.dart'; 

class TimeoutException implements Exception {
  final String? message;
  TimeoutException(this.message);
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class PostService {
  Future<List<Post>> fetchPosts({required int page}) async {
    final url = Uri.parse('${AppRoutes.initial}${AppRoutes.timeline}?page=$page');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Tempo limite de conexão excedido. Tente novamente mais tarde.');
      });

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson)) 
            .toList();

        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }
        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
         throw AuthException('Sessão expirada ou inválida. Por favor, faça login novamente.');
      }
      else {
        throw ApiException('Falha ao carregar posts', response.statusCode);
      }
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Tempo de conexão esgotado');
    } on AuthException catch (e) {
      throw e;
    } on ApiException catch (e) {
      throw e;
    } on FormatException {
      throw FormatException('Erro no formato dos dados recebidos do servidor');
    } catch (error) {
      throw Exception('Erro de conexão ao buscar posts: ${error.toString()}');
    }
  }

  Future<int> fetchLikesForPost(int postId) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');
    
    final url = Uri.parse('${AppRoutes.initial}${AppRoutes.like(postId)}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-session-token': token,
      },
    );

    if (response.statusCode == 200) {
      final likesData = json.decode(response.body);
      return likesData.isEmpty ? 0 : likesData.length;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sessão expirada ou inválida');
    } else {
      return 0;
    }
  }

  Future<int> fetchComentsForPost(int postId) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');
    
    final url = Uri.parse('${AppRoutes.initial}${AppRoutes.comment(postId)}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-session-token': token,
      },
    );

    if (response.statusCode == 200) {
      final commentsData = json.decode(response.body);

      return commentsData.isEmpty ? 0 : commentsData.length;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sessão expirada ou inválida');
    } else {
      return 0;
    }
  }

  Future<List<Post>> fetchPostsSearch({required String query}) async {
    final url = Uri.parse('${AppRoutes.initial}${AppRoutes.timeline}?search=$query');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        if (responseData.isEmpty) return [];

        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson))
            .toList();

        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }

        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sessão expirada ou inválida');
      } else {
        throw Exception('Falha ao carregar posts (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao buscar posts.');
    }
  }

  Future<List<Post>> fetchUserPosts({required String login, required int page}) async {
    final url = Uri.parse('${AppRoutes.initial}${AppRoutes.postUser(login)}?page=$page');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson)) 
            .toList();

        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }
        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
         throw Exception('Sessão expirada ou inválida');
      }
      else {
        throw Exception('Falha ao carregar posts (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao buscar posts.');
    }
  }

  Future<int> fetchUserPostCount(String login) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.postUser(login)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try{
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.length;
      } else {
        throw Exception('Erro ao contar posts (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao contar posts.');
    }
  }

  Future<void> likePost(int postId) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.like(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try{
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao curtir a postagem');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao curtir a postagem.');
    }
  }

  Future<void> unlikePost(int postId) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.unlike(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try{
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Falha ao descurtir a postagem');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao descurtir a postagem.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLikes(int postId) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.like(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try{
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, 
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erro ao carregar curtidas');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao carregar curtidas.');
    }
  }

  Future<void> createPost(String message) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.post}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
        body: json.encode({
          'post': {
            'message': message,
          },
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar post (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao criar post.');
    }
  }

  Future<void> deletePost(int postId) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.deletePost(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar post (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao deletar post.');
    }
  }

  Future<List<Comment>> fetchComments(int postId, int page) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.comments(postId)}?page=$page');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar comentários (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao carregar comentários.');
    }
  }

  Future<Comment> createComment(int postId, String message) async {
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.comment(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
        body: json.encode({
          'reply': {
            'message': message,
          },
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Comment.fromJson(jsonData);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sessão expirada ou inválida');
      } else {
        throw Exception('Erro ao criar comentário (${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Erro de conexão ao criar comentário.');
    }
  }

}