/// Mock wallet integration: simple in-memory wallet state and helper methods.
/// This is a demo only — no real key management or network calls.

class MockWallet {
  bool connected = false;
  String address = '0xDEMO...0000';

  Future<void> connect() async {
    // simulate delay
    await Future.delayed(const Duration(milliseconds: 400));
    connected = true;
  }

  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 200));
    connected = false;
  }

  Future<String> sendPayment({required String to, required double amount}) async {
    // simulate a tx hash
    await Future.delayed(const Duration(milliseconds: 600));
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    return '0x$ts';
  }
}
