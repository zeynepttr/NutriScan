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

  AnalysisResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.confidence,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      foodName: json['foodName'] ?? json['food_name'] ?? 'Unknown',
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
