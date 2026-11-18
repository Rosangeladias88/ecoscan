import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PhotosService {
  PhotosService({this.baseUrl = 'http://192.168.0.29:3004'});

  final String baseUrl;

  Future<Map<String, dynamic>> enviarFoto(
    Uint8List bytes, {
    String? token,
  }) async {
    final tipo = _identificarImagem(bytes);

    final requisicao = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/photos'),
    );

    if (token != null && token.isNotEmpty) {
      requisicao.headers['Authorization'] = 'Bearer $token';
    }

    requisicao.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'residuo.${tipo.extensao}',
        contentType: MediaType.parse(tipo.mime),
      ),
    );

    final resposta = await requisicao.send().timeout(
      const Duration(seconds: 30),
    );

    final corpo = await resposta.stream.bytesToString();

    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(
        'Falha ao enviar foto (${resposta.statusCode}): $corpo',
      );
    }

    final dados = jsonDecode(corpo);

    if (dados is! Map) {
      throw Exception('Resposta inválida ao enviar a foto.');
    }

    return Map<String, dynamic>.from(dados);
  }

  _TipoImagem _identificarImagem(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return const _TipoImagem('image/jpeg', 'jpg');
    }

    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return const _TipoImagem('image/png', 'png');
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return const _TipoImagem('image/webp', 'webp');
    }

    throw Exception(
      'Formato de imagem não suportado. Use JPG, PNG ou WEBP.',
    );
  }
}

class _TipoImagem {
  final String mime;
  final String extensao;

  const _TipoImagem(this.mime, this.extensao);
}