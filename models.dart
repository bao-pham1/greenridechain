class Vehicle {
  final String id;
  final String name;
  final VehicleType type;
  final double priceHour;
  final double priceDay;
  final String imageUrl;
  final String station;
  final int rangeKm;

  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.priceHour,
    required this.priceDay,
    required this.imageUrl,
    required this.station,
    required this.rangeKm,
  });
}

enum VehicleType { bike, scooter }

class Ride {
  final Vehicle vehicle;
  final double deposit;
  final DateTime start;
  final int hours;
  final String txHash;
  final DateTime? end;
  final double? refund;
  final String? status; // 'completed', 'cancelled', etc.
  final String? note;

  const Ride({
    required this.vehicle,
    required this.deposit,
    required this.start,
    required this.hours,
    required this.txHash,
    this.end,
    this.refund,
    this.status,
    this.note,
  });

  Ride copyWith({DateTime? end, double? refund, String? status, String? note}) => Ride(
        vehicle: vehicle,
        deposit: deposit,
        start: start,
        hours: hours,
        txHash: txHash,
        end: end ?? this.end,
        refund: refund ?? this.refund,
        status: status ?? this.status,
        note: note ?? this.note,
      );
}

class Tour {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String location; // e.g., 'Hội An, Quảng Nam'

  const Tour({required this.id, required this.title, required this.summary, required this.imageUrl, required this.location});
}

class Station {
  final String id;
  final String name;
  final String city;
  final Map<String, int> availableByVehicleId; // vehicleId -> count

  const Station({required this.id, required this.name, required this.city, required this.availableByVehicleId});
}
