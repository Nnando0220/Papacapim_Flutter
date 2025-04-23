import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/routes/app_routes.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppRoutes.initial}${AppRoutes.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'login': login,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Tempo limite de conexão excedido. Verifique sua internet.');
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await storage.write(key: 'auth_token', value: responseData['token']);

        Map<String, dynamic> userDataToStore = Map.from(responseData);
        userDataToStore.remove('token');

        await storage.write(
          key: 'user_data',
          value: json.encode(userDataToStore),
        );

        User.fromJson(userDataToStore);

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login realizado com sucesso!',
          'user': userDataToStore,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Credenciais inválidas. Verifique seu login e senha.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no login. Código: ${response.statusCode}',
        };
      }
    } on TimeoutException catch (e) {
      return {'success': false, 'message': e.message ?? 'Tempo de conexão esgotado'};
    } on FormatException {
      return {'success': false, 'message': 'Erro no formato dos dados recebidos do servidor'};
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(String login, String name, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppRoutes.initial}${AppRoutes.signup}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user': {
            'name': name,
            'login': login,
            'password': password,
            'password_confirmation': confirmPassword,
          }
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Usuário cadastrado com sucesso!',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no registro. Verifique os dados.',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet.',
      };
    }
  }

  Future<String?> getTokenUser() async {
    return await storage.read(key: 'auth_token');
  }

  Future<User> loadCurrentUser() async {
    try {
      final userJson = await storage.read(key: 'user_data');
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
      throw Exception('Dados do usuário não encontrados. Efetue login novamente.');
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro no formato dos dados do usuário. Efetue login novamente.');
      }
      throw Exception('Erro ao carregar usuário: ${e.toString()}');
    }
  }
}
