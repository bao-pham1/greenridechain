class MockAuthService {
  // very small demo auth: admin/admin
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return username == 'admin' && password == 'admin';
  }

  Future<bool> register(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Accept any non-empty username/password for demo
    return username.isNotEmpty && password.isNotEmpty;
  }

  Future<String> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // return a fake google email
    return 'demo.user@gmail.com';
  }
}
