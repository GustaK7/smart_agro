import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltroDataWidget extends StatelessWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final void Function(bool, DateTime) onSelecionarData;
  final VoidCallback onBuscar;

  const FiltroDataWidget({
    super.key,
    required this.dataInicio,
    required this.dataFim,
    required this.onSelecionarData,
    required this.onBuscar,
  });

  Future<void> _selecionarData(BuildContext context, bool inicio) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null) {
      onSelecionarData(inicio, dataSelecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selecionarData(context, true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  dataInicio == null
                      ? 'Selecionar Início'
                      : 'Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selecionarData(context, false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  dataFim == null
                      ? 'Selecionar Fim'
                      : 'Fim: ${DateFormat('dd/MM/yyyy').format(dataFim!)}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onBuscar,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Buscar'),
        ),
      ],
    );
  }
}
