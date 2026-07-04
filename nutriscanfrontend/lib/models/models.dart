class MealLog {
  final int id;
  final String foodName;
  final double calories;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double confidence;
  final String date;
  final String? createdAt;
  final bool? containsAllergen;
  final String? allergenWarning;

  MealLog({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.confidence,
    required this.date,
    this.createdAt,
    this.containsAllergen,
    this.allergenWarning,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'],
      foodName: json['foodName'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      date: json['date'],
      createdAt: json['createdAt'],
      containsAllergen: json['containsAllergen'] as bool?,
      allergenWarning: json['allergenWarning'] as String?,
    );
  }
}

class DailySummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbohydrate;
  final double totalFat;
  final List<MealLog> meals;

  DailySummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbohydrate,
    required this.totalFat,
    required this.meals,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final mealList = (json['meals'] as List<dynamic>?)
            ?.map((m) => MealLog.fromJson(m))
            .toList() ??
        [];
    return DailySummary(
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbohydrate: (json['totalCarbohydrate'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      meals: mealList,
    );
  }
}

class AnalysisResult {
  final String foodName;
  final double calories;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double confidence;
  final bool? containsAllergen;
  final String? allergenWarning;

  AnalysisResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.confidence,
    this.containsAllergen,
    this.allergenWarning,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      foodName: json['foodName'] ?? json['food_name'] ?? 'Unknown',
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      containsAllergen: json['containsAllergen'] as bool?,
      allergenWarning: json['allergenWarning'] as String?,
    );
  }
}

class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String target;
  final double? targetWeight;
  final int? targetDays;
  final int dailyCalorieTarget;
  final String email;
  final List<String>? allergens;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.target,
    this.targetWeight,
    this.targetDays,
    required this.dailyCalorieTarget,
    required this.email,
    this.allergens,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      target: json['target'] ?? 'MAINTAIN',
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      targetDays: json['targetDays'] as int?,
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      email: json['email'] ?? '',
      allergens: (json['allergens'] as List<dynamic>?)?.map((item) => item as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'target': target,
      'targetWeight': targetWeight,
      'targetDays': targetDays,
      'dailyCalorieTarget': dailyCalorieTarget,
      'email': email,
      'allergens': allergens,
    };
  }
}
