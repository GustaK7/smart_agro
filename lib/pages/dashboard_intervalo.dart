import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data_intervalo.dart';
import '../data/mock_data_intervalo_media.dart';
import '../pages/componentes/card_info.dart';
import '../pages/componentes/tabela_dados.dart';
import '../pages/componentes/filtro_data.dart';

class DashboardHistorico extends StatefulWidget {
  const DashboardHistorico({super.key});

  @override
  State<DashboardHistorico> createState() => _DashboardHistoricoState();
}

class _DashboardHistoricoState extends State<DashboardHistorico> {
  DateTime? dataInicio;
  DateTime? dataFim;
  bool carregando = false;

 Future<void> buscarDados() async {
  if (dataInicio == null || dataFim == null) return;
  setState(() => carregando = true);

  String inicio = DateFormat('yyyy-MM-dd').format(dataInicio!);
  String fim = DateFormat('yyyy-MM-dd').format(dataFim!);

  // Carregar dados E médias
  await MockDataIntervalo.carregarDados(inicio, fim);
  await MockDataMedia.carregarMedia(inicio, fim);

  setState(() => carregando = false);
}


  @override
  Widget build(BuildContext context) {
    final dados = MockDataIntervalo.leituras;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Dados',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
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
            const SizedBox(height: 24),
            if (carregando)
              const CircularProgressIndicator()
            else ...[
              if (MockDataMedia.mediaLeitura != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      CardInfoWidget('Temperatura',
                          '${MockDataMedia.mediaLeitura.temperatura.toStringAsFixed(1)} °C', Icons.thermostat),
                      CardInfoWidget('Umidade Ar',
                          '${MockDataMedia.mediaLeitura.umidadeAr.toStringAsFixed(1)} %', Icons.water_drop),
                      CardInfoWidget('Umidade Solo',
                          '${MockDataMedia.mediaLeitura.umidadeSolo.toStringAsFixed(1)} %', Icons.grass),
                      CardInfoWidget('Luminosidade',
                          '${MockDataMedia.mediaLeitura.luminosidade.toStringAsFixed(1)} lux', Icons.light_mode),
                      CardInfoWidget('CO₂',
                          '${MockDataMedia.mediaLeitura.co2.toStringAsFixed(1)} ppm', Icons.cloud),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (dados.isNotEmpty)
                Expanded(child: TabelaDadosWidget(dados: dados))
              else
                const Text(
                  'Nenhum dado encontrado no período.',
                  style: TextStyle(fontSize: 18),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
