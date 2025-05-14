import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data_tempertura.dart';
import '../pages/componentes/filtro_data.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardTemperatura extends StatefulWidget {
  const DashboardTemperatura({super.key});

  @override
  State<DashboardTemperatura> createState() => _DashboardTemperaturaState();
}

class _DashboardTemperaturaState extends State<DashboardTemperatura> {
  DateTime? dataInicio;
  DateTime? dataFim;
  bool carregando = false;
  String periodoExibido = 'Nenhum período selecionado';

  // Estatísticas de temperatura
  double temperaturaMaxima = 0;
  double temperaturaMinima = 0;
  double temperaturaMedia = 0;
  int horasVentiladorLigado = 0;

  Future<void> buscarDados() async {
    if (dataInicio == null || dataFim == null) return;
    setState(() => carregando = true);

    String inicio = DateFormat('yyyy-MM-dd').format(dataInicio!);
    String fim = DateFormat('yyyy-MM-dd').format(dataFim!);

    await MockDataTemperatura.carregarDados(inicio, fim);

    // Atualizar estatísticas após carregar os dados
    temperaturaMaxima = MockDataTemperatura.temperaturaMaxima;
    temperaturaMinima = MockDataTemperatura.temperaturaMinima;
    temperaturaMedia = MockDataTemperatura.mediaTemperatura.temperatura;
    horasVentiladorLigado = MockDataTemperatura.horasVentiladorLigado();

    periodoExibido = 'Período: ${DateFormat('dd/MM/yyyy').format(dataInicio!)} - ${DateFormat('dd/MM/yyyy').format(dataFim!)}';

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    final dados = MockDataTemperatura.leituras;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoramento de Temperatura',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FiltroDataWidget(
              dataInicio: dataInicio,
              dataFim: dataFim,
              onSelecionarData: (inicio, data) {
                setState(() {
                  if (inicio) {
                    dataInicio = data;
                  } else {
                    dataFim = data;
                  }
                });
              },
              onBuscar: buscarDados,
            ),
            const SizedBox(height: 16),
            Text(
              periodoExibido,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (carregando)
              const Center(child: CircularProgressIndicator(color: Colors.orange))
            else if (dados.isNotEmpty) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildEstatsCard(
                    'Máxima',
                    '${temperaturaMaxima.toStringAsFixed(1)}°C',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                  _buildEstatsCard(
                    'Mínima',
                    '${temperaturaMinima.toStringAsFixed(1)}°C',
                    Icons.arrow_downward,
                    Colors.blue,
                  ),
                  _buildEstatsCard(
                    'Média',
                    '${temperaturaMedia.toStringAsFixed(1)}°C',
                    Icons.calculate,
                    Colors.amber,
                  ),
                  _buildEstatsCard(
                    'Ventilador',
                    '$horasVentiladorLigado h ativo',
                    Icons.air,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variação de Temperatura',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildTemperatureChart(dados)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registros de Temperatura',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildTemperatureTable(dados)),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const Center(
                child: Text(
                  'Nenhum dado de temperatura encontrado no período.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(List<LeituraTemperatura> dados) {
    if (dados.isEmpty) {
      return const Center(child: Text('Sem dados para exibir no gráfico'));
    }

    final spots = dados.asMap().entries.map((entry) {
      final idx = entry.key.toDouble();
      final leitura = entry.value;
      return FlSpot(idx, leitura.temperatura);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final int idx = value.toInt();
                if (idx >= 0 && idx < dados.length && idx % 5 == 0) {
                  final leitura = dados[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${leitura.data.substring(5)}\n${leitura.hora}',
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toInt()}°C', style: const TextStyle(fontSize: 10)),
              interval: 5,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (dados.length - 1).toDouble(),
        minY: (temperaturaMinima - 2).floorToDouble(),
        maxY: (temperaturaMaxima + 2).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTable(List<LeituraTemperatura> dados) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Temperatura', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ventilador', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Observação', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: dados.map((leitura) {
            String observacao = '';
            if (leitura.temperatura > 30) {
              observacao = 'Temperatura elevada';
            } else if (leitura.temperatura < 15) {
              observacao = 'Temperatura baixa';
            } else {
              observacao = 'Temperatura ideal';
            }

            return DataRow(cells: [
              DataCell(Text(leitura.data)),
              DataCell(Text(leitura.hora)),
              DataCell(Text('${leitura.temperatura.toStringAsFixed(1)}°C')),
              DataCell(Row(
                children: [
                  Icon(
                    Icons.air,
                    color: leitura.ventilador ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(leitura.ventilador ? 'Ativo' : 'Inativo'),
                ],
              )),
              DataCell(Text(observacao)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
