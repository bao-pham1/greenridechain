
const Map<String, Map<String, String>> _t = {
  'vi': {
    'app_title': 'GreenRideChain — Du lịch & Blockchain',
    'nav_home': 'Trang chủ',
    'nav_explore': 'Khám phá',
    'nav_history': 'Lịch sử',
    'nav_settings': 'Cài đặt',
    'dark_mode': 'Dark mode',
    'wallet_status': 'Trạng thái ví',
    'terms_title': 'Điều khoản & Quyền riêng tư',
    'language_label': 'Ngôn ngữ',
    'language_vi': 'Tiếng Việt',
    'language_en': 'English',
    'connect_wallet': 'Kết nối ví (demo)',
    'smart_contract': 'Xem Smart Contract (demo)'
  },
  'en': {
    'app_title': 'GreenRideChain — Travel & Blockchain',
    'nav_home': 'Home',
    'nav_explore': 'Explore',
    'nav_history': 'History',
    'nav_settings': 'Settings',
    'dark_mode': 'Dark mode',
    'wallet_status': 'Wallet status',
    'terms_title': 'Terms & Privacy',
    'language_label': 'Language',
    'language_vi': 'Tiếng Việt',
    'language_en': 'English',
    'connect_wallet': 'Connect Wallet (demo)',
    'smart_contract': 'View Smart Contract (demo)'
  }
};

String tr(String locale, String key) {
  final lang = _t[locale] ?? _t['vi']!;
  return lang[key] ?? key;
}
