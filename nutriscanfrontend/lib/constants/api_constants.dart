class ApiConstants {
  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Gerçek cihaz kullanıyorsan:
  // static const String baseUrl = 'http://192.168.1.41:8080';

  // Auth
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';

  // Meals
  static const String meals = '$baseUrl/api/meals';

  // POST /api/meals
  static const String mealLogs = meals;

  // POST /api/meals/analyze
  static const String analyze = '$meals/analyze';

  // GET /api/meals/summary
  static const String dailySummary = '$meals/summary';
}