import 'package:flutter/material.dart';

class AtuadorTile extends StatelessWidget {
  final String label;
  final bool ligado;

  const AtuadorTile({super.key, required this.label, required this.ligado});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        ligado ? Icons.check_circle : Icons.cancel,
        color: ligado ? Colors.green : Colors.red,
      ),
      title: Text(label),
      trailing: Text(ligado ? 'Ligado' : 'Desligado'),
    );
  }
}