import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe que representa uma leitura de temperatura.
class LeituraTemperatura {
  final double temperatura;
  final bool ventilador;
  final String data;
  final String hora;

  LeituraTemperatura({
    required this.temperatura,
    required this.ventilador,
    required this.data,
    required this.hora,
  });

  factory LeituraTemperatura.fromJson(Map<String, dynamic> json) {
    return LeituraTemperatura(
      temperatura: json['temperatura']?.toDouble() ?? 0.0,
      ventilador: json['ventilador'] == 1,
      data: json['data'] ?? 'Desconhecido',
      hora: json['hora'] ?? 'Desconhecido',
    );
  }
}

/// Classe que representa a média das leituras de temperatura.
class MediaTemperatura {
  final double temperatura;

  MediaTemperatura({
    required this.temperatura,
  });

  factory MediaTemperatura.fromJson(Map<String, dynamic> json) {
    return MediaTemperatura(
      temperatura: json['temperatura']?.toDouble() ?? 0.0,
    );
  }
}

/// Serviço de API para buscar dados do backend.
class ApiServiceTemperatura {
  static const String baseUrl = 'http://localhost:3000';

  /// Busca leituras de temperatura por intervalo de data
  static Future<List<LeituraTemperatura>> buscarLeiturasPorData(String dataInicio, String dataFim) async {
    final url = Uri.parse('$baseUrl/dadosdatatemperatura?dataInicio=$dataInicio&dataFim=$dataFim');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        return dados.map((json) => LeituraTemperatura.fromJson(json)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar dados de temperatura: $e');
      // Em caso de erro na API, retorna dados simulados para não quebrar o app
      return _gerarDadosSimulados(dataInicio, dataFim);
    }
  }

  /// Busca a média de temperatura por intervalo de data
  static Future<MediaTemperatura> buscarMediaPorData(String dataInicio, String dataFim) async {
    final url = Uri.parse('$baseUrl/dadostemperaturamedia?dataInicio=$dataInicio&dataFim=$dataFim');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          if (decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
            return MediaTemperatura.fromJson(decoded.first);
          } else {
            throw Exception('Lista vazia ou com formato inválido');
          }
        } else if (decoded is Map<String, dynamic>) {
          return MediaTemperatura.fromJson(decoded);
        } else {
          throw Exception('Resposta inesperada do servidor: $decoded');
        }
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar média de temperatura: $e');
      // Em caso de erro na API, retorna dados simulados
      return MediaTemperatura(temperatura: 24.5);
    }
  }

  /// Gera dados simulados em caso de falha na API
  static List<LeituraTemperatura> _gerarDadosSimulados(String dataInicio, String dataFim) {
    List<LeituraTemperatura> leituras = [];
    
    DateTime inicio = DateTime.parse(dataInicio);
    DateTime fim = DateTime.parse(dataFim);
    
    // Gera um registro para cada dia no intervalo
    DateTime atual = inicio;
    while (atual.isBefore(fim.add(Duration(days: 1)))) {
      // Para cada dia, gera 4 registros (6h, 12h, 18h, 00h)
      for (int hora in [6, 12, 18, 0]) {
        // Temperatura baseada na hora do dia
        double temperatura = 20.0;
        
        if (hora >= 6 && hora < 12) {
          // Manhã - temperatura aumentando
          temperatura = 20.0 + ((hora - 6) * 1.5);
        } else if (hora >= 12 && hora < 18) {
          // Tarde - temperatura mais alta
          temperatura = 28.0 - ((hora - 12) * 0.5);
        } else if (hora >= 18) {
          // Noite - temperatura caindo
          temperatura = 25.0 - ((hora - 18) * 1.0);
        } else {
          // Madrugada - temperatura mais baixa
          temperatura = 19.0;
        }
        
        // Adiciona variação aleatória entre -1.0 e +1.0
        temperatura += (atual.millisecond % 20) / 10.0 - 1.0;
        
        // Arredonda para uma casa decimal
        temperatura = double.parse(temperatura.toStringAsFixed(1));
        
        // Define se o ventilador está ligado (acima de 25°C)
        bool ventilador = temperatura > 25.0;
        
        // Formata a data e hora
        String dataFormatada = "${atual.year}-${atual.month.toString().padLeft(2, '0')}-${atual.day.toString().padLeft(2, '0')}";
        String horaFormatada = "${hora.toString().padLeft(2, '0')}:00";
        
        leituras.add(LeituraTemperatura(
          temperatura: temperatura,
          ventilador: ventilador,
          data: dataFormatada,
          hora: horaFormatada,
        ));
      }
      
      // Avança para o próximo dia
      atual = atual.add(Duration(days: 1));
    }
    
    return leituras;
  }
}

/// Classe para armazenar os dados de temperatura carregados.
class MockDataTemperatura {
  static List<LeituraTemperatura> leituras = [];
  static MediaTemperatura mediaTemperatura = MediaTemperatura(temperatura: 0.0);
  
  /// Temperatura mais alta no período
  static double temperaturaMaxima = 0.0;
  
  /// Temperatura mais baixa no período
  static double temperaturaMinima = 0.0;
  
  /// Percentual de tempo com ventilador ligado
  static double percentualVentilador = 0.0;
  
  /// Carrega os dados de leitura de temperatura do período especificado
  static Future<void> carregarDados(String dataInicio, String dataFim) async {
    try {
      // Busca dados da API
      leituras = await ApiServiceTemperatura.buscarLeiturasPorData(dataInicio, dataFim);
      
      // Busca a média de temperatura
      mediaTemperatura = await ApiServiceTemperatura.buscarMediaPorData(dataInicio, dataFim);
      
      // Calcula estatísticas adicionais
      _calcularEstatisticas();
    } catch (e) {
      print('Erro ao carregar dados de temperatura: $e');
      // Em caso de erro, mantém a lista vazia
      leituras = [];
    }
  }
  
  /// Calcula estatísticas baseadas nas leituras carregadas
  static void _calcularEstatisticas() {
    if (leituras.isEmpty) {
      temperaturaMaxima = 0.0;
      temperaturaMinima = 0.0;
      percentualVentilador = 0.0;
      return;
    }
    
    // Calcula temperatura máxima e mínima
    temperaturaMaxima = leituras.map((l) => l.temperatura).reduce((a, b) => a > b ? a : b);
    temperaturaMinima = leituras.map((l) => l.temperatura).reduce((a, b) => a < b ? a : b);
    
    // Calcula percentual de tempo com ventilador ligado
    int ventiladorLigado = leituras.where((l) => l.ventilador).length;
    percentualVentilador = (ventiladorLigado / leituras.length) * 100;
  }
  
  /// Retorna o número de horas com ventilador ligado
  static int horasVentiladorLigado() {
    return leituras.where((l) => l.ventilador).length;
  }
  
  /// Retorna a temperatura média das leituras
  static double temperaturaMediaLocal() {
    if (leituras.isEmpty) return 0.0;
    return leituras.map((l) => l.temperatura).reduce((a, b) => a + b) / leituras.length;
  }
}