import 'package:flutter/material.dart';

class CardInfoWidget extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const CardInfoWidget(this.titulo, this.valor, this.icone, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 140,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, size: 30, color: Colors.green),
              const SizedBox(height: 10),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  valor,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
