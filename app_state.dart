import 'package:flutter/material.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  bool walletConnected = false;
  String locale = 'vi'; // 'vi' or 'en'
  bool isAuthenticated = false;
  String? userEmail;
  Ride? activeRide;
  final List<Ride> history = [];

  final vehicles = <Vehicle>[
    Vehicle(
      id: 'v1',
      name: 'Xe máy điện',
      type: VehicleType.scooter,
      priceHour: 10,
      priceDay: 50,
      // use stable placeholder images to avoid hotlink/403
  imageUrl: 'assets/images/xe_may.png',
      station: 'Bến Thành Station',
      rangeKm: 80,
    ),
    Vehicle(
      id: 'v2',
      name: 'Xe đạp điện',
      type: VehicleType.bike,
      priceHour: 6,
      priceDay: 25,
  // stable placeholder
  imageUrl: 'assets/images/xe_dap.png',
      station: 'Dalat Center',
      rangeKm: 50,
    ),
    Vehicle(
      id: 'v3',
      name: 'Xe ga',
      type: VehicleType.scooter,
      priceHour: 12,
      priceDay: 55,
  // stable placeholder
  imageUrl: 'assets/images/xe_ga.png',
      station: 'Hội An Old Town',
      rangeKm: 120,
    ),
  ];

  final tours = <Tour>[
    Tour(
      id: 't1',
      title: 'Hội An & Phố Cổ',
      summary: 'Khám phá phố cổ Hội An: kiến trúc cổ, lồng đèn, ẩm thực địa phương và nghề thủ công.',
      imageUrl: 'assets/images/3142_hoiantown.png',
      location: 'Hội An, Quảng Nam',
    ),
    Tour(
      id: 't2',
      title: 'Cầu Rồng & Bờ sông',
      summary: 'Tham quan Cầu Rồng Đà Nẵng, dạo bộ ven sông và xem biểu diễn phun lửa vào cuối tuần.',
      imageUrl: 'assets/images/vna_potal_da_nang_ruc_ro_don_tet_nguyen_dan_giap_thin_2024__stand.png',
      location: 'Đà Nẵng',
    ),
    Tour(
      id: 't3',
      title: 'Kinh Thành & Lăng Tẩm',
      summary: 'Lịch sử triều Nguyễn tại Huế: lăng tẩm, đền đài và trải nghiệm văn hoá cung đình.',
      imageUrl: 'assets/images/lang-tam-hue-2.png',
      location: 'Huế, Thừa Thiên Huế',
    ),
    Tour(
      id: 't4',
      title: 'Vịnh Hạ Long',
      summary: 'Ngắm hàng ngàn đảo đá vôi tuyệt đẹp và tham gia chèo thuyền kayak trên vịnh.',
      imageUrl: 'assets/images/ha long.png',
      location: 'Hạ Long, Quảng Ninh',
    ),
    Tour(
      id: 't5',
      title: 'Tràng An - Ninh Bình',
      summary: 'Phong cảnh non nước hữu tình, đền chùa và tuyến tham quan bằng thuyền.',
      imageUrl: 'assets/images/trang_ninh.png',
      location: 'Ninh Bình',
    ),
    Tour(
      id: 't6',
      title: 'Sapa & Fansipan',
      summary: 'Ruộng bậc thang, bản làng dân tộc và hành trình lên đỉnh Fansipan.',
      imageUrl: 'assets/images/fansipan_view1.png',
      location: 'Sapa, Lào Cai',
    ),
    Tour(
      id: 't7',
      title: 'Phú Quốc - Đảo Ngọc',
      summary: 'Bãi biển trắng, lặn san hô và hải sản tươi ngon.',
      imageUrl: 'assets/images/bat-dong-san-phu-quoc-12.png',
      location: 'Phú Quốc, Kiên Giang',
    ),
  ];

  // Sample stations with availability per vehicle id
  final stations = <Station>[
    Station(id: 's1', name: 'Bến Thành', city: 'Hồ Chí Minh', availableByVehicleId: {'v1': 5, 'v2': 2, 'v3': 1}),
    Station(id: 's2', name: 'Ga Đà Nẵng', city: 'Đà Nẵng', availableByVehicleId: {'v1': 3, 'v2': 0, 'v3': 4}),
    Station(id: 's3', name: 'Hội An Central', city: 'Hội An', availableByVehicleId: {'v1': 2, 'v2': 6, 'v3': 0}),
  ];

  void connectWallet() {
    walletConnected = true;
    notifyListeners();
  }

  void disconnectWallet() {
    walletConnected = false;
    notifyListeners();
  }

  void startRide({
    required Vehicle vehicle,
    required int hours,
    required double deposit,
  }) {
    final tx = _fakeTxHash();
    activeRide = Ride(
      vehicle: vehicle,
      deposit: deposit,
      start: DateTime.now(),
      hours: hours,
      txHash: tx,
    );
    notifyListeners();
  }

  void finishRide() {
    if (activeRide == null) return;
    activeRide = activeRide!.copyWith(
      end: DateTime.now(),
      refund: activeRide!.deposit,
      status: 'completed',
    );
    history.insert(0, activeRide!);
    activeRide = null;
    notifyListeners();
  }

  void cancelActiveRide({String? reason}) {
    if (activeRide == null) return;
    activeRide = activeRide!.copyWith(
      end: DateTime.now(),
      refund: 0.0,
      status: 'cancelled',
      note: reason,
    );
    history.insert(0, activeRide!);
    activeRide = null;
    notifyListeners();
  }

  void setLocale(String l) {
    if (l == locale) return;
    locale = l;
    notifyListeners();
  }

  void setAuthenticated({required bool auth, String? email}) {
    isAuthenticated = auth;
    userEmail = email;
    notifyListeners();
  }

  static String _fakeTxHash() {
    final r = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    return '0x${r.substring(r.length - 6)}...${r.substring(r.length - 2)}';
  }
}
