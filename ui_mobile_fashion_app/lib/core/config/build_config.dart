class BuildConfig {
  static const String _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'customer');

  static String get flavor => _flavor;

  static String get apiBaseUrl {
    switch (_flavor) {
      case 'admin':
        return 'https://api.admin.example.com';
      case 'customer':
      default:
        return 'https://api.customer.example.com';
    }
  }

  static String get appName {
    switch (_flavor) {
      case 'admin':
        return 'Admin App';
      case 'customer':
      default:
        return 'Customer App';
    }
  }
}