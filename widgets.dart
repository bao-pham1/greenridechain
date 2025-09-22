import 'package:flutter/material.dart';
import 'models.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({required this.label, required this.value, this.big = false, Key? key}) : super(key: key);
  final String label;
  final String value;
  final bool big;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(children: [
        Text(label),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: big ? 18 : 14)),
      ]),
    );
  }
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({required this.vehicle, Key? key}) : super(key: key);
  final Vehicle vehicle;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade900]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              vehicle.imageUrl, 
              width: 84, 
              height: 84, 
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 84, height: 84,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 84, height: 84,
                color: Colors.grey[800],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('${vehicle.priceHour.toStringAsFixed(0)} USDT/giờ', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(vehicle.station, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ])),
        ]),
      ),
    );
  }
}
