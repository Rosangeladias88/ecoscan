
import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  AuthService({
    this.baseUrl = 'http://localhost:3004',
  });

  final String baseUrl;

  Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String papel,
  }) async {
    return _post('/auth/register', {
      'nome': nome,
      'email': email,
      'senha': senha,
      'papel': papel,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    return _post('/auth/login', {
      'email': email,
      'senha': senha,
    });
  }

  Future<Map<String, dynamic>> perfil(String token) async {
    final resposta = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    return _interpretarResposta(resposta);
  }

  Future<Map<String, dynamic>> _post(
    String rota,
    Map<String, dynamic> dados,
  ) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl$rota'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dados),
    ).timeout(const Duration(seconds: 10));

    return _interpretarResposta(resposta);
  }

  Map<String, dynamic> _interpretarResposta(
    http.Response resposta,
  ) {
    dynamic dados;

    try {
      dados = jsonDecode(resposta.body);
    } catch (_) {
      throw const FormatException(
        'O servidor retornou uma resposta inválida.',
      );
    }

    if (resposta.statusCode < 200 ||
        resposta.statusCode >= 300) {
      final mensagem = dados is Map
          ? dados['message']?.toString()
          : null;

      throw Exception(
        mensagem ?? 'Erro HTTP ${resposta.statusCode}.',
      );
    }

    if (dados is! Map<String, dynamic>) {
      throw const FormatException(
        'Formato de resposta inesperado.',
      );
    }

    return dados;
  }
}
