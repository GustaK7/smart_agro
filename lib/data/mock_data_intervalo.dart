import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe que representa uma leitura de sensores.
class Leitura {
  final double temperatura;
  final double umidadeAr;
  final double umidadeSolo;
  final double luminosidade;
  final String co2;
  final bool ventilador;
  final bool irrigacao;
  final bool luzArtificial;
  final bool monitorarUmidade;
  final bool monitorarCo2;
  final String data;
  final String hora;

  Leitura({
    required this.temperatura,
    required this.umidadeAr,
    required this.umidadeSolo,
    required this.luminosidade,
    required this.co2,
    required this.ventilador,
    required this.irrigacao,
    required this.luzArtificial,
    required this.monitorarUmidade,
    required this.monitorarCo2,
    required this.data,
    required this.hora,
  });

  factory Leitura.fromJson(Map<String, dynamic> json) {
    return Leitura(
      temperatura: json['temperatura']?.toDouble() ?? 0.0,
      umidadeAr: json['umidade_ar']?.toDouble() ?? 0.0,
      umidadeSolo: json['umidade_solo']?.toDouble() ?? 0.0,
      luminosidade: json['luminosidade']?.toDouble() ?? 0.0,
      co2: json['co2']?.toString() ?? 'Desconhecido',
      ventilador: json['ventilador'] == 1,
      irrigacao: json['irrigacao'] == 1,
      luzArtificial: json['luz_artificial'] == 1,
      monitorarUmidade: json['monitorar_umidade_ar'] == 1,
      monitorarCo2: json['monitorar_co2'] == 1,
      data: json['data'] ?? 'Desconhecido',
      hora: json['hora'] ?? 'Desconhecido',
    );
  }
}

/// Serviço de API para buscar dados do backend.
class ApiService {
  static Future<List<Leitura>> buscarLeiturasPorData(String dataInicio, String dataFim) async {
    final url = Uri.parse('http://localhost:3000/dadosdata?dataInicio=$dataInicio&dataFim=$dataFim');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((json) => Leitura.fromJson(json)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados: $e');
    }
  }
}

/// Classe para armazenar os dados carregados e calcular médias.
class MockDataIntervalo {
  static List<Leitura> leituras = [];

  static Future<void> carregarDados(String dataInicio, String dataFim) async {
    leituras = await ApiService.buscarLeiturasPorData(dataInicio, dataFim);
  }

  static double mediaTemperatura() {
    if (leituras.isEmpty) return 0.0;
    return leituras.map((l) => l.temperatura).reduce((a, b) => a + b) / leituras.length;
  }

  static double mediaUmidadeAr() {
    if (leituras.isEmpty) return 0.0;
    return leituras.map((l) => l.umidadeAr).reduce((a, b) => a + b) / leituras.length;
  }

  static double mediaUmidadeSolo() {
    if (leituras.isEmpty) return 0.0;
    return leituras.map((l) => l.umidadeSolo).reduce((a, b) => a + b) / leituras.length;
  }

  static double mediaLuminosidade() {
    if (leituras.isEmpty) return 0.0;
    return leituras.map((l) => l.luminosidade).reduce((a, b) => a + b) / leituras.length;
  }

  static String mediaCo2() {
    if (leituras.isEmpty) return '0';
    return leituras.first.co2; // Você pode aplicar outro critério aqui se quiser
  }

}
