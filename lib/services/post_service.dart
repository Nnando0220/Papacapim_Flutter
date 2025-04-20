import 'package:http/http.dart' as http;
import 'package:social_app/models/comment.dart';
import 'dart:convert';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/auth_service.dart';
import '../models/post.dart'; // Importe seu modelo Post

class PostService {
  // Método para buscar posts paginados
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode == 200) {
        // Decodifica a resposta JSON (espera-se uma lista de posts)
        final List<dynamic> responseData = json.decode(response.body);
        // Mapeia a lista de JSON para uma lista de objetos Post
        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson)) // Usa o factory constructor
            .toList();

        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }
        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
         // Erro de autenticação/autorização
         print('Erro de autenticação ao buscar posts: ${response.statusCode}');
         // Você pode tentar fazer logout aqui ou lançar um erro específico
         throw Exception('Sessão expirada ou inválida');
      }
      else {
        // Outros erros do servidor
        print('Erro ao buscar posts: ${response.statusCode} - ${response.body}');
        throw Exception('Falha ao carregar posts (${response.statusCode})');
      }
    } catch (error) {
      // Erros de rede ou outros erros
      print('Erro de conexão/inesperado ao buscar posts: $error');
      throw Exception('Erro de conexão ao buscar posts.');
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
      print('Erro de autenticação ao buscar likes: ${response.statusCode}');
      throw Exception('Sessão expirada ou inválida');
    } else {
      print('Erro ao buscar likes: ${response.statusCode} - ${response.body}');
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
      print('Erro de autenticação ao buscar likes: ${response.statusCode}');
      throw Exception('Sessão expirada ou inválida');
    } else {
      print('Erro ao buscar likes: ${response.statusCode} - ${response.body}');
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Se a lista estiver vazia, retorna imediatamente
        if (responseData.isEmpty) return [];

        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson))
            .toList();

        // Só busca likes e comentários se houver posts
        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }

        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Erro de autenticação ao buscar posts: ${response.statusCode}');
        throw Exception('Sessão expirada ou inválida');
      } else {
        print('Erro ao buscar posts: ${response.statusCode} - ${response.body}');
        throw Exception('Falha ao carregar posts (${response.statusCode})');
      }
    } catch (error) {
      print('Erro de conexão/inesperado ao buscar posts: $error');
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode == 200) {
        // Decodifica a resposta JSON (espera-se uma lista de posts)
        final List<dynamic> responseData = json.decode(response.body);
        // Mapeia a lista de JSON para uma lista de objetos Post
        List<Post> posts = responseData
            .map((postJson) => Post.fromJson(postJson)) // Usa o factory constructor
            .toList();

        for (var post in posts) {
          post.likes = await fetchLikesForPost(post.id);
          post.comments = await fetchComentsForPost(post.id);
        }
        return posts;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
         // Erro de autenticação/autorização
         print('Erro de autenticação ao buscar posts: ${response.statusCode}');
         // Você pode tentar fazer logout aqui ou lançar um erro específico
         throw Exception('Sessão expirada ou inválida');
      }
      else {
        // Outros erros do servidor
        print('Erro ao buscar posts: ${response.statusCode} - ${response.body}');
        throw Exception('Falha ao carregar posts (${response.statusCode})');
      }
    } catch (error) {
      // Erros de rede ou outros erros
      print('Erro de conexão/inesperado ao buscar posts: $error');
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Número de posts: ${data.length}');
        return data.length;
      } else {
        throw Exception('Erro ao contar posts (${response.statusCode})');
      }
    } catch (error) {
      print('Erro de conexão ao contar posts: $error');
      throw Exception('Erro de conexão ao contar posts.');
    }
  }

  Future<void> likePost(int postId) async {
    print(postId);
    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.like(postId)}');

    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try{
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao curtir a postagem');
      }
    } catch (error) {
      print('Erro de conexão ao curtir a postagem: $error');
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Falha ao descurtir a postagem');
      }
    } catch (error) {
      print('Erro de conexão ao descurtir a postagem: $error');
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
          'x-session-token': token, // Inclui o token no header
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erro ao carregar curtidas');
      }
    } catch (error) {
      print('Erro de conexão ao carregar curtidas: $error');
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
      print('Erro de conexão ao criar post: $error');
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
      print('Erro de conexão ao deletar post: $error');
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
      print('Erro de conexão ao carregar comentários: $error');
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
        print('Erro de autenticação ao criar comentário: ${response.statusCode}');
        throw Exception('Sessão expirada ou inválida');
      } else {
        throw Exception('Erro ao criar comentário (${response.statusCode})');
      }
    } catch (error) {
      print('Erro de conexão ao criar comentário: $error');
      throw Exception('Erro de conexão ao criar comentário.');
    }
  }

}