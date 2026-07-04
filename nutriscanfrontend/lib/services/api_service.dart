import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/models.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // AUTH
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['accessToken'] ?? data['jwt'];
      if (token == null) throw Exception('Token bulunamadı');
      await saveToken(token);
      return token;
    }
    throw Exception('Giriş başarısız: ${response.statusCode} ${response.body}');
  }

  static Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String target,
    double? targetWeight,
    int? targetDays,
    List<String>? allergens,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
        'weight': weight,
        'height': height,
        'target': target,
        'targetWeight': targetWeight,
        'targetDays': targetDays,
        'allergens': allergens,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Kayıt başarısız: ${response.body}');
    }
  }

  // MEAL LOGS
  static Future<DailySummary> getDailySummary(String date) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.dailySummary}?date=$date'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return DailySummary.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404 || response.statusCode == 204) {
      return DailySummary(
        totalCalories: 0,
        totalProtein: 0,
        totalCarbohydrate: 0,
        totalFat: 0,
        meals: [],
      );
    }
    throw Exception('Özet alınamadı: ${response.statusCode}');
  }

  static Future<AnalysisResult> analyzeImage(File imageFile) async {
  final token = await getToken();

  final request = http.MultipartRequest(
    'POST',
    Uri.parse(ApiConstants.analyze),
  );

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ),
  );


  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

 

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return AnalysisResult.fromJson(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Analiz başarısız: ${response.statusCode} ${response.body}',
  );
}

  static Future<MealLog> logMeal({
    required String foodName,
    required double calories,
    required double protein,
    required double carbohydrate,
    required double fat,
    required double confidence,
    required String date,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.mealLogs),
      headers: headers,
      body: jsonEncode({
        'foodName': foodName,
        'calories': calories,
        'protein': protein,
        'carbohydrate': carbohydrate,
        'fat': fat,
        'confidence': confidence,
        'date': date,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return MealLog.fromJson(jsonDecode(response.body));
    }
    throw Exception('Öğün kaydedilemedi: ${response.statusCode}');
  }

  static Future<void> deleteMealLog(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.mealLogs}/$id'),
      headers: headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Silme başarısız: ${response.statusCode}');
    }
  }

  // USER PROFILE
  static Future<UserProfile> getUserProfile() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/users/me'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    throw Exception('Profil bilgileri alınamadı: ${response.statusCode}');
  }

  static Future<UserProfile> updateUserProfile({
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? target,
    double? targetWeight,
    int? targetDays,
    List<String>? allergens,
    int? dailyCalorieTarget,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/users/me'),
      headers: headers,
      body: jsonEncode({
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (target != null) 'target': target,
        if (targetWeight != null) 'targetWeight': targetWeight,
        if (targetDays != null) 'targetDays': targetDays,
        if (allergens != null) 'allergens': allergens,
        if (dailyCalorieTarget != null) 'dailyCalorieTarget': dailyCalorieTarget,
      }),
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    throw Exception('Profil güncellenemedi: ${response.statusCode} ${response.body}');
  }
}
