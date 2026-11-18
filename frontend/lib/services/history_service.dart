import 'dart:convert';

import 'package:http/http.dart' as http;

class HistoryService {
  HistoryService({this.baseUrl = 'http://192.168.0.29:3004'});

  final String baseUrl;

  Future<List<Map<String, dynamic>>> listarHistorico(
    String token,
  ) async {
    final resposta = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'Falha ao carregar histórico (${resposta.statusCode}).',
      );
    }

    final dados = jsonDecode(resposta.body);

    final lista = dados is List
        ? dados
        : dados is Map && dados['data'] is List
            ? dados['data'] as List
            : null;

    if (lista == null) {
      throw Exception('A API retornou um histórico inválido.');
    }

    return lista
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> criarConsulta({
    required String token,
    required int materialId,
    int? fotografiaId,
  }) async {
    final corpo = <String, dynamic>{
      'materialId': materialId,
    };

    if (fotografiaId != null) {
      corpo['fotografiaId'] = fotografiaId;
    }

    final resposta = await http.post(
      Uri.parse('$baseUrl/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(corpo),
    ).timeout(const Duration(seconds: 15));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'Falha ao salvar consulta (${resposta.statusCode}): ${resposta.body}',
      );
    }

    final dados = jsonDecode(resposta.body);

    if (dados is! Map) {
      throw Exception('Resposta inválida ao salvar consulta.');
    }

    return Map<String, dynamic>.from(dados);
  }
}