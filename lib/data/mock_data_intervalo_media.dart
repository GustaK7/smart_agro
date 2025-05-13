import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe que representa as médias das leituras de sensores.
class MediaLeitura {
  final double temperatura;
  final double umidadeAr;
  final double umidadeSolo;
  final double luminosidade;
  final double co2; // Alterado para double

  MediaLeitura({
    required this.temperatura,
    required this.umidadeAr,
    required this.umidadeSolo,
    required this.luminosidade,
    required this.co2, // Alterado para double
  });

  factory MediaLeitura.fromJson(Map<String, dynamic> json) {
    return MediaLeitura(
      temperatura: json['temperatura']?.toDouble() ?? 0.0,
      umidadeAr: json['umidade_ar']?.toDouble() ?? 0.0,
      umidadeSolo: json['umidade_solo']?.toDouble() ?? 0.0,
      luminosidade: json['luminosidade']?.toDouble() ?? 0.0,
      co2: json['co2']?.toDouble() ?? 0.0, // Alterado para double
    );
  }
}


/// Serviço de API para buscar médias das leituras.
class ApiService {
  static Future<MediaLeitura> buscarMediaPorData(String dataInicio, String dataFim) async {
    final url = Uri.parse('http://localhost:3000/dadosdatamedia?dataInicio=$dataInicio&dataFim=$dataFim');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(response.body);
        return MediaLeitura.fromJson(dados);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados: $e');
    }
  }
}

/// Classe para armazenar as médias carregadas e exibir no Dashboard.
class MockDataMedia {
  static MediaLeitura mediaLeitura = MediaLeitura(
    temperatura: 0.0,
    umidadeAr: 0.0,
    umidadeSolo: 0.0,
    luminosidade: 0.0,
    co2: 0.0,
  );

  static Future<void> carregarMedia(String dataInicio, String dataFim) async {
    mediaLeitura = await ApiService.buscarMediaPorData(dataInicio, dataFim);
  }
}
