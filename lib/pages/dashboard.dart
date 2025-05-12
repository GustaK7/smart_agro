import 'package:flutter/material.dart';
import 'dart:async'; // Necessário para usar Timer

import '../data/mock_data.dart'; // Importa os dados simulados

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Busca inicial dos dados
    MockData.fetchDados().then((_) {
      setState(() {}); // Atualiza a interface com os novos dados
    });

    // Atualiza os dados periodicamente
    Timer.periodic(const Duration(seconds: 5), (timer) {
      MockData.fetchDados().then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estufa Inteligente'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card para Temperatura com Ventilador
            buildInfoCard(
              icon: Icons.thermostat,
              title: 'Temperatura',
              value: '${MockData.temperatura.toStringAsFixed(1)}°C',
              color: Colors.orange,
              child: buildDeviceStatus(
                icon: Icons.air,
                title: 'Ventilador',
                ativo: MockData.ventiladorAtivo,
              ),
            ),
            const SizedBox(height: 16),

            // Card para Umidade do Ar
            buildInfoCard(
              icon: Icons.water_drop,
              title: 'Umidade do Ar',
              value: '${MockData.umidade.toStringAsFixed(1)}%',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Card para Umidade do Solo com Irrigação
            buildInfoCard(
              icon: Icons.grass,
              title: 'Umidade do Solo',
              value: '${MockData.umidadeSolo.toStringAsFixed(1)}%',
              color: Colors.brown,
              child: buildDeviceStatus(
                icon: Icons.water,
                title: 'Irrigação',
                ativo: MockData.irrigacaoAtiva,
              ),
            ),
            const SizedBox(height: 16),

            // Card para Luminosidade com Luz Artificial
            buildInfoCard(
              icon: Icons.wb_sunny,
              title: 'Luminosidade',
              value: '${MockData.luminosidade.toStringAsFixed(1)}',
              color: Colors.yellow,
              child: buildDeviceStatus(
                icon: Icons.lightbulb,
                title: 'Luz Artificial',
                ativo: MockData.luzArtificialAtiva,
              ),
            ),
            const SizedBox(height: 16),

            // Card para Monitoramento de CO₂
            buildInfoCard(
              icon: Icons.cloud,
              title: 'Monitoramento de CO₂',
              value: MockData.co2,
              color: Colors.grey,
              child: buildDeviceStatus(
                icon: Icons.cloud,
                title: 'Monitoramento de CO₂',
                ativo: MockData.monitoramentoCo2Ativo,
              ),
            ),
            const SizedBox(height: 16),

            // Card para Registro de Dados
            buildInfoCard(
              icon: Icons.article,
              title: 'Registro de Dados',
              value: MockData.registro,
              color: Colors.green,
              isMultiline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isMultiline = false,
    Widget? child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        maxLines: isMultiline ? null : 1,
                        overflow: isMultiline
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[
              const SizedBox(height: 16),
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDeviceStatus({
    required IconData icon,
    required String title,
    required bool ativo,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: ativo ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ${ativo ? 'Ativo' : 'Inativo'}',
          style: TextStyle(
            fontSize: 16,
            color: ativo ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}