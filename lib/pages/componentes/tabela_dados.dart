import 'package:flutter/material.dart';
import '../../data/mock_data_intervalo.dart';

class TabelaDadosWidget extends StatelessWidget {
  final List<Leitura> dados;

  const TabelaDadosWidget({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leituras por Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  dataTextStyle: const TextStyle(fontSize: 16),
                  columns: const [
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Hora')),
                    DataColumn(label: Text('Temp.')),
                    DataColumn(label: Text('Umidade Ar')),
                    DataColumn(label: Text('Umidade Solo')),
                    DataColumn(label: Text('Luminosidade')),
                    DataColumn(label: Text('CO₂')),
                  ],
                  rows: dados.map((d) => DataRow(cells: [
                    DataCell(Text(d.data)),
                    DataCell(Text(d.hora)),
                    DataCell(Text('${d.temperatura.toStringAsFixed(1)}')),
                    DataCell(Text('${d.umidadeAr.toStringAsFixed(1)}')),
                    DataCell(Text('${d.umidadeSolo.toStringAsFixed(1)}')),
                    DataCell(Text('${d.luminosidade.toStringAsFixed(1)}')),
                    DataCell(Text(d.co2)),
                  ])).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
