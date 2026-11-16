
import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  AuthService({required this.baseUrl});

  final String baseUrl;

  Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    ).timeout(const Duration(seconds: 10));

    final dados = jsonDecode(resposta.body);

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception('Falha no cadastro: ${resposta.statusCode}');
    }

    if (dados is! Map<String, dynamic>) {
      throw const FormatException('Resposta inesperada da API');
    }

    return dados;
  }
}
