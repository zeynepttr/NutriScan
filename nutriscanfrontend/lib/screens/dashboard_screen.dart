import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';
import 'analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DailySummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  static const double _calorieGoal = 2000.0;
  static const double _carbGoal = 250.0;
  static const double _proteinGoal = 120.0;
  static const double _fatGoal = 65.0;

  late AnimationController _cardAnimController;
  late Animation<double> _cardFadeAnim;

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _cardFadeAnim = CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    _cardAnimController.reset();
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final summary = await ApiService.getDailySummary(dateStr);
      setState(() { _summary = summary; });
      _cardAnimController.forward();
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('404') || errStr.contains('204')) {
        setState(() {
          _summary = DailySummary(
            totalCalories: 0,
            totalProtein: 0,
            totalCarbohydrate: 0,
            totalFat: 0,
            meals: [],
          );
        });
        _cardAnimController.forward();
      } else {
        setState(() { _errorMessage = 'Veriler yüklenemedi.'; });
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
              secondary: AppColors.activeOrange,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.primaryGreen,
              headerForegroundColor: Colors.white,
              dayStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              weekdayStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
              yearStyle: GoogleFonts.plusJakartaSans(),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  Future<void> _deleteLog(int id) async {
    try {
      await ApiService.deleteMealLog(id);
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silme işlemi başarısız.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.cardBg,
            onRefresh: _loadData,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NutriScan',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 22, fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary, letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isToday ? 'Bugün' : DateFormat('dd MMMM yyyy', 'tr').format(_selectedDate),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _pickDate,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Icons.calendar_month_rounded, color: AppColors.textPrimary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: _logout,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                        )
                      : _errorMessage != null
                          ? _buildErrorState()
                          : FadeTransition(
                              opacity: _cardFadeAnim,
                              child: Column(
                                children: [
                                  const SizedBox(height: 28),
                                  _buildCalorieRing(),
                                  const SizedBox(height: 24),
                                  _buildMacroCards(),
                                  const SizedBox(height: 28),
                                  _buildMealsList(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildCalorieRing() {
    final calories = _summary?.totalCalories ?? 0;
    final percent = (calories / _calorieGoal).clamp(0.0, 1.0);
    final remaining = (_calorieGoal - calories).clamp(0, double.infinity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 32, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Günlük Kalori',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 14,
            percent: percent,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${calories.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'kcal',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            progressColor: percent >= 1.0 ? AppColors.error : AppColors.activeOrange,
            backgroundColor: AppColors.surfaceBg,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalorieStat('Hedef', '${_calorieGoal.toInt()} kcal', AppColors.primaryGreen),
              Container(width: 1, height: 32, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildCalorieStat('Kalan', '${remaining.toInt()} kcal', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _buildMacroCards() {
    final carb = _summary?.totalCarbohydrate ?? 0;
    final protein = _summary?.totalProtein ?? 0;
    final fat = _summary?.totalFat ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildMacroCard('Karbonhidrat', carb, _carbGoal, AppColors.carbYellow, Icons.grain_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _buildMacroCard('Protein', protein, _proteinGoal, AppColors.proteinBlue, Icons.fitness_center_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _buildMacroCard('Yağ', fat, _fatGoal, AppColors.fatPink, Icons.water_drop_rounded)),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String name, double value, double goal, Color color, IconData icon) {
    final percent = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            '${value.toInt()}g',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6,
            percent: percent,
            progressColor: color,
            backgroundColor: AppColors.surfaceBg,
            barRadius: const Radius.circular(4),
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 4),
          Text(
            '/ ${goal.toInt()}g',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    final meals = _summary?.meals ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Öğünler',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${meals.length} öğün',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (meals.isEmpty)
            _buildEmptyMeals()
          else
            ...meals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildEmptyMeals() {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            isToday ? 'Henüz öğün eklenmedi' : 'Bu gün için kayıtlı öğün bulunmamaktadır',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            isToday ? 'Kameraya dokunarak yemek analizi yap' : 'Yemek eklemek için aşağıdaki butonu kullanabilirsin',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealLog meal) {
    final confidencePercent = (meal.confidence * 100).toInt();
    final confidenceColor = meal.confidence >= 0.8
        ? AppColors.success
        : meal.confidence >= 0.6
            ? AppColors.activeOrange
            : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.healthGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMacroChip('K:${meal.carbohydrate.toInt()}g', AppColors.carbYellow),
                      const SizedBox(width: 4),
                      _buildMacroChip('P:${meal.protein.toInt()}g', AppColors.proteinBlue),
                      const SizedBox(width: 4),
                      _buildMacroChip('Y:${meal.fat.toInt()}g', AppColors.fatPink),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: confidenceColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Doğruluk: %$confidencePercent',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.calories.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.activeOrange,
                  ),
                ),
                Text('kcal', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _confirmDelete(meal),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Bağlantı hatası', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_errorMessage ?? '', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.calorieGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.activeOrange.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => AnalysisScreen(selectedDate: _selectedDate)),
          );
          if (result == true) _loadData();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: Text(
          'Yemek Tara',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _confirmDelete(MealLog meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceBg, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(
              '${meal.foodName} silinsin mi?',
              style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu işlem geri alınamaz.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); _deleteLog(meal.id); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Sil'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
