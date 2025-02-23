import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService{
  final String _baseUrl = 'http://127.0.0.1:8000/api';
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Login: $email, $password');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode({
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200){
        final responseData = json.decode(response.body);

        await storage.write(
            key: 'auth_token',
            value: responseData['token']
        );

        await storage.write(
            key: 'user_data',
            value: json.encode(responseData['user'])
        );

        return {
          'sucess': true,
          'message': 'Login realizado com sucesso',
          'user': responseData['user']
        };
      } else {
        // Tratamento de erro
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no login'
        };
      }
    } catch (error){
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet.'
      };
    }
  }
}
