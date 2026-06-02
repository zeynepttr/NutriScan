import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

enum AnalysisState { picking, analyzing, result, error }

class AnalysisScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AnalysisScreen({super.key, required this.selectedDate});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with TickerProviderStateMixin {
  File? _imageFile;
  AnalysisResult? _result;
  AnalysisState _state = AnalysisState.picking;
  String? _errorMessage;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _resultController;
  late Animation<double> _resultFade;
  late Animation<Offset> _resultSlide;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _resultController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _resultFade = CurvedAnimation(parent: _resultController, curve: Curves.easeOut);
    _resultSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _resultController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;
    setState(() {
      _imageFile = File(xFile.path);
      _state = AnalysisState.analyzing;
    });
    await _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final result = await ApiService.analyzeImage(_imageFile!);
      setState(() { _result = result; _state = AnalysisState.result; });
      _resultController.forward();
      if (result.confidence < 0.8) {
        if (!mounted) return;
        _showLowConfidenceDialog(result.confidence);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Analiz başarısız. Lütfen daha net bir fotoğraf deneyin.';
        _state = AnalysisState.error;
      });
    }
  }

  void _showLowConfidenceDialog(double confidence) {
    final percent = (confidence * 100).toInt();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.activeOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.activeOrange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Düşük Doğruluk Oranı',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Yemeğin doğruluk oranı (%$percent) hedeflenen %80 değerinin altındadır. Daha doğru besin değerleri hesaplanabilmesi için lütfen yemeği daha net ve aydınlık bir ortamda tekrar tarayın.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.mintGreen]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _state = AnalysisState.picking;
                          _imageFile = null;
                          _result = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Yeniden Çek / Tara',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Yine de Sonucu İncele',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveLog() async {
    if (_result == null) return;
    try {
      await ApiService.logMeal(
        foodName: _result!.foodName,
        calories: _result!.calories,
        protein: _result!.protein,
        carbohydrate: _result!.carbohydrate,
        fat: _result!.fat,
        confidence: _result!.confidence,
        date: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydetme başarısız.'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Yemek Analizi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case AnalysisState.picking:
        return _buildPickingState();
      case AnalysisState.analyzing:
        return _buildAnalyzingState();
      case AnalysisState.result:
        return _buildResultState();
      case AnalysisState.error:
        return _buildErrorState();
    }
  }

  Widget _buildPickingState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.mintGreen],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primaryGreen.withOpacity(0.12), blurRadius: 40, spreadRadius: 10),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Yemeğini Tara',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'AI destekli besin analizi için\nyemeğinin fotoğrafını çek veya seç.',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildSourceButton(
            label: 'Kamera ile Çek',
            icon: Icons.camera_alt_rounded,
            gradient: AppColors.healthGradient,
            shadowColor: AppColors.primaryGreen,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          _buildSourceButton(
            label: 'Galeriden Seç',
            icon: Icons.photo_library_rounded,
            gradient: AppColors.calorieGradient,
            shadowColor: AppColors.activeOrange,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required String label,
    required IconData icon,
    required LinearGradient gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(_imageFile!, height: 240, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 40),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analiz ediliyor...',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'AI besin değerlerini hesaplıyor',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          _buildAnalysisStep('Görüntü işleniyor', true),
          _buildAnalysisStep('Yemek tanımlanıyor', true),
          _buildAnalysisStep('Besin değerleri hesaplanıyor', false),
        ],
      ),
    );
  }

  Widget _buildAnalysisStep(String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.surfaceBg,
              shape: BoxShape.circle,
              border: Border.all(color: done ? AppColors.success : AppColors.textSecondary.withOpacity(0.3)),
            ),
            child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    final r = _result!;
    final confidence = (r.confidence * 100).toInt();
    final confColor = r.confidence >= 0.8 ? AppColors.success : r.confidence >= 0.6 ? AppColors.activeOrange : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _resultFade,
        child: SlideTransition(
          position: _resultSlide,
          child: Column(
            children: [
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              // Success badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    const SizedBox(width: 6),
                    Text('Analiz Tamamlandı', style: GoogleFonts.plusJakartaSans(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                r.foodName,
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: confColor, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Doğruluk: %$confidence', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: confColor, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),
              // Calorie card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.activeOrange.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.activeOrange, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      '${r.calories.toInt()}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.activeOrange),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: GoogleFonts.plusJakartaSans(fontSize: 20, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Macros
              Row(
                children: [
                  Expanded(child: _buildResultMacro('Karbonhidrat', r.carbohydrate, AppColors.carbYellow)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildResultMacro('Protein', r.protein, AppColors.proteinBlue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildResultMacro('Yağ', r.fat, AppColors.fatPink)),
                ],
              ),
              const SizedBox(height: 28),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.calorieGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.activeOrange.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveLog,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('Öğünü Kaydet', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() { _state = AnalysisState.picking; _imageFile = null; _result = null; }),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Yeniden Çek', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultMacro(String name, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text('${value.toInt()}g', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: 32),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Analiz Başarısız', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(_errorMessage ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () => setState(() { _state = AnalysisState.picking; _imageFile = null; }),
              child: const Text('Tekrar Dene'),
            ),
          ),
        ],
      ),
    );
  }
}
