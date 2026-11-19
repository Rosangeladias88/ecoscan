import 'dart:convert';

import 'package:http/http.dart' as http;

class MaterialsService {
  MaterialsService({this.baseUrl = 'http://localhost:3004'});

  final String baseUrl;

  Future<List<Map<String, dynamic>>> listarMateriais() async {
    final resposta = await http.get(
      Uri.parse('$baseUrl/materials'),
    ).timeout(const Duration(seconds: 15));

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'Falha ao carregar materiais (${resposta.statusCode}).',
      );
    }

    final dados = jsonDecode(resposta.body);

    final lista = dados is List
        ? dados
        : dados is Map && dados['data'] is List
            ? dados['data'] as List
            : null;

    if (lista == null) {
      throw Exception('A API retornou uma lista de materiais inválida.');
    }

    return lista
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}