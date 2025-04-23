import 'dart:async';
import 'package:flutter/material.dart';

// Exceções customizadas
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException: $message (Código: $statusCode)';
}

class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

// Utilitário para lidar com erros na UI
class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static String getReadableError(dynamic error) {
    if (error is TimeoutException) {
      return error.message ?? 'O servidor demorou muito para responder. Tente novamente.';
    } else if (error is AuthException) {
      return error.message;
    } else if (error is NotFoundException) {
      return error.message;
    } else if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is FormatException) {
      return 'Erro no formato de dados recebido do servidor.';
    } else {
      return 'Ocorreu um erro inesperado: ${error.toString()}';
    }
  }

  static bool isAuthError(dynamic error) {
    return error is AuthException || 
           (error is ApiException && (error.statusCode == 401 || error.statusCode == 403)) ||
           (error is Exception && error.toString().contains('não autenticado')) ||
           (error is Exception && error.toString().contains('expirada'));
  }
}
