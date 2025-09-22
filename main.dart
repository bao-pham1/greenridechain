import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'src/app_state.dart';
import 'src/mock_wallet.dart';
import 'src/mock_auth.dart';
import 'src/models.dart';
import 'src/i18n.dart';
import 'dart:async';

void main() {
  runApp(const GreenRideApp());
}

// AppState and models moved to lib/src/*.dart
// AppStateScope remains below and will use AppState from src/app_state.dart

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

/// ================== APP ROOT ==================
class GreenRideApp extends StatefulWidget {
  const GreenRideApp({super.key});
  @override
  State<GreenRideApp> createState() => _GreenRideAppState();
}

class _GreenRideAppState extends State<GreenRideApp> {
  final state = AppState();
  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
  title: tr(state.locale, 'app_title'),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('GreenRideChain — Du lịch & Blockchain'),
            actions: [
              IconButton(
                tooltip: state.walletConnected ? 'Ví đã kết nối' : 'Kết nối ví',
                icon: Icon(state.walletConnected ? Icons.verified : Icons.account_balance_wallet),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalletScreen()),
                ),
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navIndex,
            onDestinationSelected: (i) => setState(() => navIndex = i),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), label: tr(state.locale, 'nav_home')),
              NavigationDestination(icon: const Icon(Icons.explore_outlined), label: tr(state.locale, 'nav_explore')),
              NavigationDestination(icon: const Icon(Icons.history), label: tr(state.locale, 'nav_history')),
              NavigationDestination(icon: const Icon(Icons.settings_outlined), label: tr(state.locale, 'nav_settings')),
            ],
          ),
          body: IndexedStack(
            index: navIndex,
            children: const [HomeScreen(), ExploreScreen(), HistoryScreen(), SettingsScreen()],
          ),
        ),
      ),
    );
  }
}

/// ================== SCREENS ==================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _HeroSection(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _NeonCard(
                title: 'Thuê Xe Nhanh',
                subtitle: 'Thanh toán cross-border bằng stablecoin',
                icon: Icons.flash_on,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VehicleListScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NeonCard(
                title: 'Tour & Gợi ý',
                subtitle: 'Trải nghiệm du lịch địa phương',
                   icon: Icons.place,
                   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExploreScreen(showAppBar: true))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionTitle('Ý tưởng nổi bật'),
        const SizedBox(height: 8),
        const _BenefitsSection(),
        const SizedBox(height: 12),
        _SectionTitle('Xe nổi bật'),
        const SizedBox(height: 8),
  const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.vehicles.length,
            itemBuilder: (context, i) {
              final v = state.vehicles[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v))),
                  child: SizedBox(width: 260, child: _VehicleCard(vehicle: v)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Địa danh nổi bật'),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: _FeaturedToursCarousel(),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Thanh toán & Bảo mật'),
        const SizedBox(height: 8),
        Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Blockchain-enabled payments', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Hỗ trợ thanh toán xuyên biên giới, cọc on-chain, hoàn cọc tự động.'),
              const SizedBox(height: 12),
              Row(children: [
                FilledButton.icon(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Kết nối ví (demo)'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SmartContractScreen())),
                  child: const Text('Xem Smart Contract (demo)'),
                ),
              ])
            ]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key, this.showAppBar = false});
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Gợi ý du lịch theo blockchain'),
        const SizedBox(height: 8),
        const Text('Kết hợp thuê xe, thanh toán xuyên biên giới và trải nghiệm địa phương.'),
        const SizedBox(height: 12),
        for (final t in state.tours) ...[
          _TourCard(
            tour: t,
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 20),
        _SectionTitle('Khai thác du lịch'),
        const SizedBox(height: 8),
        const Text('Gamify trải nghiệm: điểm, NFT kỷ niệm chuyến đi, và giảm giá cho người giới thiệu.'),
        const SizedBox(height: 20),
      ],
    );

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(title: Text(tr(AppStateScope.of(context).locale, 'nav_explore'))),
        body: content,
      );
    }

    return Container(
      color: Colors.transparent,
      child: content,
    );
  }
}

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn phương tiện')),
      body: ListView.builder(
        itemCount: state.vehicles.length,
        itemBuilder: (context, i) {
          final v = state.vehicles[i];
          return ListTile(
            leading: v.imageUrl.startsWith('assets/') 
              ? CircleAvatar(
                  backgroundImage: AssetImage(v.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ) 
              : CircleAvatar(
                  backgroundImage: NetworkImage(v.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ),
            title: Text(v.name),
            subtitle: Text('${v.priceHour.toStringAsFixed(0)} USDT/giờ · ${v.priceDay.toStringAsFixed(0)} USDT/ngày'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v))),
          );
        },
      ),
    );
  }
}

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // Hero image section
          SliverAppBar(
            expandedHeight: 400,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[900],
                child: Stack(
                  fit: StackFit.expand,
        children: [
                    // Main image with proper aspect ratio
                    Center(
            child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
        child: vehicle.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  vehicle.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.error, color: Colors.red, size: 50),
                                  ),
                                )
                              : Image.network(
                                  vehicle.imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.error, color: Colors.red, size: 50),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    // Subtle gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle name and info
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
          Row(
            children: [
                        Icon(Icons.pin_drop_outlined, color: Colors.greenAccent),
              const SizedBox(width: 8),
                        Text(
                          vehicle.station,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
          const SizedBox(height: 16),
                    
                    // Vehicle specs
          Card(
                      color: Colors.grey[850],
            child: Padding(
        padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.greenAccent),
                                const SizedBox(width: 8),
                                const Text(
                                  'Thông số kỹ thuật',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
          ),
          const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.battery_charging_full,
                              label: 'Tầm hoạt động',
                              value: '${vehicle.rangeKm} km',
                            ),
                  const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Trạm hiện tại',
                              value: vehicle.station,
                            ),
                ],
              ),
            ),
          ),
                    const SizedBox(height: 20),
                    
                    // Pricing card
                    Card(
                      color: Colors.green.shade900.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
          Row(
            children: [
                                Icon(Icons.attach_money, color: Colors.greenAccent),
              const SizedBox(width: 8),
                                const Text(
                                  'Bảng giá',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
            ],
          ),
          const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _PriceCard(
                                    label: 'Theo giờ',
                                    price: '${vehicle.priceHour.toStringAsFixed(0)}',
                                    unit: 'USDT/giờ',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PriceCard(
                                    label: 'Theo ngày',
                                    price: '${vehicle.priceDay.toStringAsFixed(0)}',
                                    unit: 'USDT/ngày',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Action buttons
          FilledButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('Xem tình trạng còn xe tại các điểm'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StationAvailabilityScreen(vehicle: vehicle))),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Thuê ngay'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(vehicle: vehicle))),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.label,
    required this.price,
    required this.unit,
  });
  
  final String label;
  final String price;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
              child: Column(
                children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.greenAccent,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

        class StationAvailabilityScreen extends StatelessWidget {
          const StationAvailabilityScreen({required this.vehicle, Key? key}) : super(key: key);
          final Vehicle vehicle;

          @override
          Widget build(BuildContext context) {
            final stations = AppStateScope.of(context).stations;
            return Scaffold(
              appBar: AppBar(title: Text('Tình trạng xe: ${vehicle.name}')),
              body: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: stations.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final s = stations[i];
                  final count = s.availableByVehicleId[vehicle.id] ?? 0;
                  return ListTile(
                    leading: const Icon(Icons.store_mall_directory),
                    title: Text('${s.name} — ${s.city}'),
                    subtitle: Text('Còn: $count xe'),
                    trailing: count > 0 ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.close, color: Colors.red),
                  );
                },
              ),
            );
          }
        }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int hours = 4;
  double deposit = 50;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final price = (hours >= 8)
        ? widget.vehicle.priceDay
        : widget.vehicle.priceHour * hours;

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán & cọc')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: widget.vehicle.imageUrl.startsWith('assets/') 
              ? CircleAvatar(
                  backgroundImage: AssetImage(widget.vehicle.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ) 
              : CircleAvatar(
                  backgroundImage: NetworkImage(widget.vehicle.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ),
            title: Text(widget.vehicle.name),
            subtitle: Text('${widget.vehicle.station} · Tầm hoạt động ${widget.vehicle.rangeKm}km'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thời lượng thuê (giờ)', style: TextStyle(fontWeight: FontWeight.w700)),
                  Slider(
                    value: hours.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '$hours h',
                    onChanged: (v) => setState(() => hours = v.round()),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tiền cọc (USDT)', style: TextStyle(fontWeight: FontWeight.w700)),
                  Slider(
                    value: deposit,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    label: deposit.toStringAsFixed(0),
                    onChanged: (v) => setState(() => deposit = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 8),
                      Text(state.walletConnected ? 'Ví đã kết nối' : 'Chưa kết nối ví'),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
                        child: Text(state.walletConnected ? 'Xem ví' : 'Kết nối ví'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Giá thuê', value: '${price.toStringAsFixed(0)} USDT'),
          _SummaryRow(label: 'Tiền cọc', value: '${deposit.toStringAsFixed(0)} USDT'),
          const Divider(height: 24),
          _SummaryRow(
              label: 'Tổng tạm tính',
              value: '${(price + deposit).toStringAsFixed(0)} USDT',
              big: true),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.lock_outline),
            label: const Text('Khóa tiền cọc & bắt đầu'),
            onPressed: state.walletConnected
                ? () {
                    state.startRide(
                      vehicle: widget.vehicle,
                      hours: hours,
                      deposit: deposit,
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ActiveRideScreen()),
                      (route) => route.isFirst,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final ride = state.activeRide!;

    final unlockPayload =
        'RID:${ride.txHash};VEH:${ride.vehicle.id};START:${ride.start.toIso8601String()}';

    return Scaffold(
      appBar: AppBar(title: const Text('Hành trình đang chạy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Quét QR để mở khóa xe', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Center(
                    child: QrImageView(
                      data: unlockPayload,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText('TX: ${ride.txHash}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Bắt đầu', value: _fmt(ride.start)),
          _SummaryRow(label: 'Thời lượng dự kiến', value: '${ride.hours} giờ'),
          _SummaryRow(label: 'Tiền cọc đã khóa', value: '${ride.deposit.toStringAsFixed(0)} USDT'),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Trả xe & hoàn cọc'),
            onPressed: () {
              state.finishRide();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ReturnScreen()));
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Hủy cọc'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CancelDepositScreen())),
          ),
        ],
      ),
    );
  }
}


class CancelDepositScreen extends StatefulWidget {
  const CancelDepositScreen({Key? key}) : super(key: key);

  @override
  State<CancelDepositScreen> createState() => _CancelDepositScreenState();
}

class _CancelDepositScreenState extends State<CancelDepositScreen> {
  final _reasonCtl = TextEditingController();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hủy cọc & Hoàn tất')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Nhập lý do hủy (tùy chọn):'),
          TextField(controller: _reasonCtl),
          const SizedBox(height: 12),
          processing
              ? const CircularProgressIndicator()
              : FilledButton(
                  onPressed: () async {
                    setState(() => processing = true);
                    state.cancelActiveRide(reason: _reasonCtl.text.isEmpty ? null : _reasonCtl.text);
                    // after cancel, go home
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Xác nhận hủy cọc và lưu lịch sử'),
                )
        ]),
      ),
    );
  }
}
class ReturnScreen extends StatelessWidget {
  const ReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final last = AppStateScope.of(context).history.isNotEmpty ? AppStateScope.of(context).history.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Hoàn tất')), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified, size: 64),
            const SizedBox(height: 12),
            Text(
              last == null ? 'Đã hoàn tất' : 'Tiền cọc hoàn trả: ${last.refund?.toStringAsFixed(0)} USDT',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(last == null ? '' : 'Kết thúc: ${_fmt(last.end!)}'),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('Về trang chủ')),
          ]),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppStateScope.of(context).history;

    if (history.isEmpty) {
      return const Center(child: Text('Chưa có giao dịch'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final r = history[i];
        return ListTile(
            leading: r.vehicle.imageUrl.startsWith('assets/') 
              ? CircleAvatar(
                  backgroundImage: AssetImage(r.vehicle.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ) 
              : CircleAvatar(
                  backgroundImage: NetworkImage(r.vehicle.imageUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle error silently
                  },
                ),
          title: Text(r.vehicle.name),
          subtitle: Text('Bắt đầu: ${_fmt(r.start)}\nKết thúc: ${_fmt(r.end ?? DateTime.now())}'),
          trailing: Text('+${r.refund?.toStringAsFixed(0) ?? '0'} USDT'),
        );
      },
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int tab = 0; // 0 login, 1 register
  final _userCtl = TextEditingController(text: 'admin');
  final _passCtl = TextEditingController(text: 'admin');
  bool processing = false;
  final auth = MockAuthService();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // dim backdrop
          Positioned.fill(child: Container(color: Colors.black54)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: Colors.grey[900],
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // back button inside card
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tab == 0 ? 'Đăng nhập' : 'Đăng ký',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ),
                          ToggleButtons(
                            isSelected: [tab == 0, tab == 1],
                            onPressed: (i) => setState(() => tab = i),
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Colors.green.shade700,
                            children: const [
                              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Đăng nhập')),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Đăng ký')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _userCtl,
                        decoration: InputDecoration(labelText: 'Tài khoản', filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtl,
                        decoration: InputDecoration(labelText: 'Mật khẩu', filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      processing
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                onPressed: () async {
                                  setState(() => processing = true);
                                  final u = _userCtl.text.trim();
                                  final p = _passCtl.text;
                                  bool ok = false;
                                  if (tab == 0) {
                                    ok = await auth.login(u, p);
                                  } else {
                                    ok = await auth.register(u, p);
                                  }
                                  setState(() => processing = false);
                                  if (ok) {
                                    state.setAuthenticated(auth: true, email: u == 'admin' ? 'admin@example.local' : '$u@example.local');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công (demo)')));
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thông tin đăng nhập sai')));
                                  }
                                },
                                child: Text(tab == 0 ? 'Đăng nhập' : 'Đăng ký'),
                              ),
                            ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white12)),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Hoặc', style: TextStyle(color: Colors.white54))),
                          Expanded(child: Divider(color: Colors.white12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            setState(() => processing = true);
                            final email = await auth.signInWithGoogle();
                            setState(() => processing = false);
                            state.setAuthenticated(auth: true, email: email);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập Google demo: $email')));
                            Navigator.of(context).pop();
                          },
                          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                            CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('G', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800))),
                            const SizedBox(width: 12),
                            const Text('Đăng nhập với Google', style: TextStyle(color: Colors.black87)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tài khoản demo: admin / admin', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletScreenState extends State<WalletScreen> {
  final mock = MockWallet();
  bool connecting = false;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final connected = state.walletConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('Ví & Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(connected ? Icons.verified : Icons.account_balance_wallet, size: 32),
            const SizedBox(width: 12),
            Text(connected ? 'Ví đã kết nối' : 'Chưa kết nối ví', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          Text(connected ? 'Bạn có thể thanh toán, khóa tiền cọc và nhận hoàn cọc tự động (demo testnet).' : 'Nhấn nút dưới để kết nối ví (demo).'),
          const Spacer(),
          FilledButton.icon(
            icon: Icon(connected ? Icons.link_off : Icons.link),
            label: Text(connected ? 'Ngắt kết nối' : 'Kết nối ví'),
            onPressed: connecting
                ? null
                : () async {
                    setState(() => connecting = true);
                    if (!connected) {
                      await mock.connect();
                      state.connectWallet();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ví demo kết nối: ${mock.address}')));
                    } else {
                      await mock.disconnect();
                      state.disconnectWallet();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã ngắt kết nối ví demo')));
                    }
                    setState(() => connecting = false);
                  },
          ),
        ]),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dark mode sẽ có ở phiên bản sau')));
          },
          title: Text(tr(state.locale, 'dark_mode')),
          subtitle: const Text('Đang tạm khoá ở MVP'),
        ),
        ListTile(
          title: const Text('Trạng thái ví'),
          subtitle: Text(state.walletConnected ? 'Đã kết nối' : 'Chưa kết nối'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
        ),
        const Divider(),
        ListTile(
          title: Text(tr(state.locale, 'terms_title')),
          subtitle: const Text('Bản demo dành cho cuộc thi hackathon'),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text(tr(state.locale, 'language_label')),
          subtitle: Text(state.locale == 'vi' ? tr(state.locale, 'language_vi') : tr(state.locale, 'language_en')),
        ),
        RadioListTile<String>(
          value: 'vi',
          groupValue: state.locale,
          title: Text(tr(state.locale, 'language_vi')),
          onChanged: (v) => state.setLocale('vi'),
        ),
        RadioListTile<String>(
          value: 'en',
          groupValue: state.locale,
          title: Text(tr(state.locale, 'language_en')),
          onChanged: (v) => state.setLocale('en'),
        ),
        const Divider(),
        ListTile(
          title: Text(state.isAuthenticated ? 'Đăng xuất' : 'Đăng nhập'),
          subtitle: state.isAuthenticated ? Text(state.userEmail ?? '') : const Text('Sử dụng tài khoản demo admin/admin'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (state.isAuthenticated) {
              state.setAuthenticated(auth: false, email: null);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
            }
          },
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.big = false});
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

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle, Key? key}) : super(key: key);
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
      child: vehicle.imageUrl.startsWith('assets/') 
        ? Image.asset(
            vehicle.imageUrl, 
            width: 84, 
            height: 84, 
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 84, height: 84,
              color: Colors.grey[800],
              child: const Icon(Icons.error, color: Colors.red),
            ),
          ) 
        : Image.network(
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

class _NeonCard extends StatelessWidget {
  const _NeonCard({required this.title, required this.subtitle, required this.icon, required this.onTap, Key? key}) : super(key: key);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.6)),
          boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.06), blurRadius: 12, spreadRadius: 2)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            CircleAvatar(backgroundColor: Colors.greenAccent.withOpacity(0.12), child: Icon(icon, color: Colors.greenAccent)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ])),
            Icon(Icons.chevron_right, color: Colors.white54),
          ]),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade800, Colors.black87]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GreenRideChain', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Thuê xe điện — Thanh toán xuyên biên giới · Khai thác du lịch', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Row(children: [
          FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VehicleListScreen())), icon: const Icon(Icons.flash_on), label: const Text('Thuê ngay')),
          const SizedBox(width: 8),
          OutlinedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())), icon: const Icon(Icons.account_balance_wallet), label: const Text('Ví demo')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: const Text('v0.1', style: TextStyle(color: Colors.white70)),
          )
        ])
      ]),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({required this.tour, Key? key}) : super(key: key);
  final Tour tour;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Row(children: [
        ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            child: tour.imageUrl.startsWith('assets/')
                ? Image.asset(
                    tour.imageUrl, 
                    width: 120, 
                    height: 100, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120, height: 100,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  )
                : Image.network(
                    tour.imageUrl, 
                    width: 120, 
                    height: 100, 
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120, height: 100,
                        color: Colors.grey[800],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120, height: 100,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  )),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tour.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(tour.summary, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Row(children: [
              FilledButton(onPressed: () {}, child: const Text('Đặt tour')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour))), child: const Text('Chi tiết')),
            ])
          ]),
        ))
      ]),
    );
  }
}

class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({required this.tour, Key? key}) : super(key: key);
  final Tour tour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tour.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          // Hero image section
          SliverAppBar(
            expandedHeight: 300,
            pinned: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  tour.imageUrl.startsWith('assets/')
                    ? Image.asset(
                        tour.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.red, size: 50),
                        ),
                      )
                    : Image.network(
                        tour.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.red, size: 50),
                        ),
                      ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location and title
                    Text(
                      tour.location,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tour.title,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tour.summary,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Information card
                    Card(
                      color: Colors.grey[850],
                      child: Padding(
        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.greenAccent),
                                const SizedBox(width: 8),
                                const Text(
                                  'Thông tin du lịch',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
          ),
          const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Giờ mở cửa',
                              value: 'Thay đổi theo địa điểm',
                            ),
          const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.lightbulb_outline,
                              label: 'Gợi ý',
                              value: 'Ghé buổi sáng để tránh nắng',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Địa điểm',
                              value: tour.location,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.book_online),
                            label: const Text('Đặt tour'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Thêm vào lịch'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.greenAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {Key? key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
  );
}

class _BenefitsSection extends StatelessWidget {
  const _BenefitsSection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _IdeaTile(icon: Icons.lock, title: 'Cọc on-chain', subtitle: 'Cọc tự động trên smart contract, minh bạch.'),
      const SizedBox(height: 8),
      _IdeaTile(icon: Icons.language, title: 'Thanh toán xuyên biên giới', subtitle: 'USDT / stablecoin — nhanh, phí thấp.'),
      const SizedBox(height: 8),
      _IdeaTile(icon: Icons.card_giftcard, title: 'Khai thác du lịch', subtitle: 'Voucher, điểm & NFT kỷ niệm chuyến đi.'),
    ]);
  }
}

class _IdeaTile extends StatelessWidget {
  const _IdeaTile({required this.icon, required this.title, required this.subtitle, Key? key}) : super(key: key);
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.greenAccent.withOpacity(0.14), child: Icon(icon, color: Colors.greenAccent)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}

class _FeaturedToursCarousel extends StatefulWidget {
  const _FeaturedToursCarousel({Key? key}) : super(key: key);

  @override
  State<_FeaturedToursCarousel> createState() => _FeaturedToursCarouselState();
}

class _FeaturedToursCarouselState extends State<_FeaturedToursCarousel> {
  late final PageController _ctrl;
  int _page = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.92);
    // start timer after a short delay
    _timer = Timer(const Duration(milliseconds: 800), _startAutoAdvance);
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final state = AppStateScope.of(context);
      final len = state.tours.length;
      if (len == 0) return;
      _page = (_page + 1) % len;
      _ctrl.animateToPage(_page, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
  _timer?.cancel();
  _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tours = state.tours;
    if (tours.isEmpty) return const SizedBox.shrink();
    return Stack(
      children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: tours.length,
          itemBuilder: (context, i) {
            final t = tours[i];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TourDetailScreen(tour: t))),
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[850]),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                      child: t.imageUrl.startsWith('assets/') 
                        ? Image.asset(
                            t.imageUrl, 
                            width: 140, 
                            height: 140, 
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140, height: 140,
                              color: Colors.grey[800],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ) 
                        : Image.network(
                            t.imageUrl, 
                            width: 140, 
                            height: 140, 
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 140, height: 140,
                                color: Colors.grey[800],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140, height: 140,
                              color: Colors.grey[800],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(t.summary, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis)
                        ]),
                      ),
                    )
                  ]),
                ),
              ),
            );
          },
        ),
        // Prev / Next buttons
        Positioned(
          left: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                final len = tours.length;
                if (len == 0) return;
                _page = (_page - 1) % len;
                _ctrl.animateToPage(_page, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                _startAutoAdvance();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                final len = tours.length;
                if (len == 0) return;
                _page = (_page + 1) % len;
                _ctrl.animateToPage(_page, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                _startAutoAdvance();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// _ActiveRideBanner removed (replaced by ActiveRide UI elsewhere).

String _fmt(DateTime dt) {
  final df = DateFormat('dd/MM/yyyy HH:mm');
  return df.format(dt);
}

class SmartContractScreen extends StatelessWidget {
  const SmartContractScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final md = '''
Smart contract (pseudocode) — demo

Goal: escrow deposit and automatic refund when ride ends.

contract RideEscrow {
    struct Ride { address user; uint256 deposit; uint256 start; uint256 duration; bool closed; }
    mapping(bytes32 => Ride) public rides;

    function startRide(bytes32 rideId, uint256 duration) public payable {
        require(msg.value > 0, "deposit required");
        rides[rideId] = Ride(msg.sender, msg.value, block.timestamp, duration, false);
    }

    function endRide(bytes32 rideId) public {
        Ride storage r = rides[rideId];
        require(!r.closed, "already closed");
        require(msg.sender == r.user, "only user can end");
        uint256 refund = r.deposit; // demo: full refund
        r.closed = true;
        payable(r.user).transfer(refund);
    }

    // Admin / operator hooks could release partial refunds if needed.
}

Notes:
- In production use audited contracts and proper access control.
- Use stablecoin ERC-20 like USDT/USDC via allowance/transferFrom for cross-border payments.
''';

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Contract (demo)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: Text(md, style: const TextStyle(fontFamily: 'monospace'))),
      ),
    );
  }
}
