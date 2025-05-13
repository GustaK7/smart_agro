import 'dart:convert';
import 'package:http/http.dart' as http;

class MockData {
  static int ultimoId = 0;
  static String ultimaAtualizacao = "Desconhecido";

  static double temperatura = 0.0;
  static double umidade = 0.0;
  static double umidadeSolo = 0.0;
  static double luminosidade = 0.0;
  static String co2 = "Desconhecido";
  static String registro = "Sem dados.";

  // Estados associados
  static bool ventiladorAtivo = false;
  static bool irrigacaoAtiva = false;
  static bool luzArtificialAtiva = false;
  static bool monitoramentoCo2Ativo = false;
  static bool monitoramentoUmidadeAtiva = false;

  // Buscar dados da API
static Future<void> fetchDados() async {
  final url = Uri.parse('http://localhost:3000/dadosone');
  try {
    print("Fazendo requisição para: $url");
    final response = await http.get(url).timeout(Duration(seconds: 10));
    print("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> dado = jsonDecode(response.body);

      // Atualizando os dados recebidos
      ultimoId = dado['id'] ?? 0;
      temperatura = dado['temperatura'] ?? 0.0;
      umidade = dado['umidade_ar'] ?? 0.0;
      umidadeSolo = dado['umidade_solo'] ?? 0.0;
      luminosidade = dado['luminosidade'] ?? 0.0;
      co2 = dado['co2']?.toString() ?? "Desconhecido";

      ventiladorAtivo = dado['ventilador'] == 1;
      irrigacaoAtiva = dado['irrigacao'] == 1;
      luzArtificialAtiva = dado['luz_artificial'] == 1;
      monitoramentoCo2Ativo = dado['monitorar_co2'] == 1;
      monitoramentoUmidadeAtiva = dado['monitorar_umidade_ar'] == 1;

      // Atualizando a data e hora
      ultimaAtualizacao = "${dado['data'] ?? 'Desconhecido'} às ${dado['hora'] ?? 'Desconhecido'}";

      registro = "Dados atualizados com sucesso (ID $ultimoId às $ultimaAtualizacao)";
    } else {
      registro = "Erro ao buscar dados: ${response.statusCode}";
    }
  } catch (e) {
    registro = "Erro ao buscar dados: ${e.runtimeType} - ${e.toString()}";
    print("Erro ao buscar dados: $e");
  }
}

}