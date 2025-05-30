import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:social_app/models/user.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
}

class UserService {
  final storage = const FlutterSecureStorage();

  Future<List<User>> fetchUsers({int? page, String? search}) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.users}').replace(queryParameters: {
      if (page != null) 'page': '$page',
      if (search != null && search.isNotEmpty) 'search': search,
    });

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
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar usuários (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar usuários');
    }
  }

  Future<User> fetchUser(String login) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.user(login)}');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Tempo limite de conexão excedido. Tente novamente mais tarde.');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        throw NotFoundException('Usuário "@$login" não encontrado');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException('Sessão expirada ou inválida');
      } else {
        throw ApiException('Erro ao buscar usuário', response.statusCode);
      }
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Tempo de conexão esgotado');
    } on NotFoundException catch (e) {
      throw e;
    } on AuthException catch (e) {
      throw e;
    } on ApiException catch (e) {
      throw e;
    } on FormatException {
      throw FormatException('Erro no formato dos dados recebidos do servidor');
    } catch (e) {
      throw Exception('Erro de conexão ao buscar usuário: ${e.toString()}');
    }
  }

  Future<(List<String>, int)> fetchFollowers(String login) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.followers(login)}');

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
        final followers = data.map<String>((json) => json['follower_login'] as String).toList();
        return (followers, followers.length);
      } else {
        throw Exception('Falha ao listar seguidores (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao buscar seguidores');
    }
  }

  Future<void> followUser(String login) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    try {
      final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.follower(login)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao seguir o usuário (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao seguir o usuário');
    }
  }

  Future<void> unfollowUser(String login) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.unfollow(login)}');

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
        throw Exception('Falha ao deixar de seguir o usuário (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao deixar de seguir o usuário');
    }
  }

  Future<Map<String, dynamic>> editUser({data}) async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.editUser}');

    try {
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
        body: json.encode({
          'user': {
            if (data['name'] != null) 'name': data['name'],
            if (data['login'] != null) 'login': data['login'],
            if (data['password'] != null) 'password': data['password'],
            if (data['confirm_password'] != null) 'password_confirmation': data['confirm_password'],
          }
        }),
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'user_data');
        await storage.delete(key: 'auth_token');
        return {'success': true, 'message': 'Usuário atualizado com sucesso!'};
      } else {
        final errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Erro ao atualizar usuário.'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Erro de conexão. Verifique sua internet.'};
    }
  }

  Future<void> deleteUser() async {
    final token = await AuthService().getTokenUser();
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('${AppRoutes.initial}${AppRoutes.deleteUser}');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-session-token': token,
        },
      );

      if (response.statusCode == 204) {
        await storage.delete(key: 'auth_token');
        await storage.delete(key: 'user_data');
      } else {
        throw Exception('Falha ao excluir usuário (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão ao excluir usuário');
    }
  }
}