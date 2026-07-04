import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _calorieController;
  late TextEditingController _targetWeightController;
  late TextEditingController _targetDaysController;
  
  String _gender = 'MALE';
  String _target = 'MAINTAIN';
  final List<String> _selectedAllergens = [];
  final List<String> _availableAllergens = [
    'Gluten',
    'Süt/Laktoz',
    'Yumurta',
    'Fıstık/Kuruyemiş',
    'Deniz Ürünleri',
    'Soya',
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _calorieController = TextEditingController();
    _targetWeightController = TextEditingController();
    _targetDaysController = TextEditingController();
 
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _calorieController.dispose();
    _targetWeightController.dispose();
    _targetDaysController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final profile = await ApiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _ageController.text = profile.age.toString();
        _weightController.text = profile.weight.toString();
        _heightController.text = profile.height.toString();
        _calorieController.text = profile.dailyCalorieTarget.toString();
        _targetWeightController.text = profile.targetWeight?.toString() ?? '';
        _targetDaysController.text = profile.targetDays?.toString() ?? '';
        _gender = profile.gender;
        _target = profile.target;
        _selectedAllergens.clear();
        if (profile.allergens != null) {
          _selectedAllergens.addAll(profile.allergens!);
        }
      });
      _animController.forward();
    } catch (e) {
      setState(() { _errorMessage = 'Profil bilgileri yüklenemedi.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate target weight goals
    if (_target == 'LOSE_WEIGHT' || _target == 'GAIN_WEIGHT') {
      final targetWeight = double.tryParse(_targetWeightController.text.trim());
      final targetDays = int.tryParse(_targetDaysController.text.trim());
      final currentWeight = double.tryParse(_weightController.text.trim());

      if (targetWeight == null) {
        setState(() => _errorMessage = 'Lütfen geçerli bir hedef kilo girin.');
        return;
      }
      if (targetDays == null || targetDays <= 0) {
        setState(() => _errorMessage = 'Lütfen geçerli bir hedef gün sayısı girin.');
        return;
      }
      if (currentWeight != null) {
        if (_target == 'LOSE_WEIGHT' && targetWeight >= currentWeight) {
          setState(() => _errorMessage = 'Hedef kilonuz mevcut kilonuzdan düşük olmalıdır.');
          return;
        }
        if (_target == 'GAIN_WEIGHT' && targetWeight <= currentWeight) {
          setState(() => _errorMessage = 'Hedef kilonuz mevcut kilonuzdan yüksek olmalıdır.');
          return;
        }
        double minDays = ((currentWeight - targetWeight).abs() / 1.5) * 7.0;
        if (targetDays < minDays) {
          setState(() => _errorMessage = 'Haftalık en fazla 1.5 kg kilo değişimi sağlıklıdır. Belirttiğiniz hedef için en az ${minDays.ceil()} gün girmelisiniz.');
          return;
        }
      }
    }

    setState(() { _isSaving = true; _errorMessage = null; });
    try {
      final inputCalorie = int.tryParse(_calorieController.text.trim());
      final isCalorieManuallyEdited = inputCalorie != _userProfile?.dailyCalorieTarget;
      final isMaintain = _target == 'MAINTAIN';

      await ApiService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        target: _target,
        targetWeight: isMaintain ? null : double.tryParse(_targetWeightController.text.trim()),
        targetDays: isMaintain ? null : int.tryParse(_targetDaysController.text.trim()),
        allergens: _selectedAllergens,
        dailyCalorieTarget: isCalorieManuallyEdited ? inputCalorie : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profiliniz başarıyla güncellendi!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Güncelleme başarısız oldu: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() { _isSaving = false; });
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
              // Toolbar
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
                        'Profil Yönetimi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Equal balancing
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                    : _errorMessage != null && _userProfile == null
                        ? _buildErrorState()
                        : FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildAvatarSection(),
                                      const SizedBox(height: 28),
                                      _buildFormFields(),
                                      const SizedBox(height: 36),
                                      _buildSaveButton(),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.healthGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _firstNameController.text.isNotEmpty
                    ? _firstNameController.text.substring(0, 1).toUpperCase()
                    : 'U',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_firstNameController.text} ${_lastNameController.text}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile?.email ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kişisel Bilgiler',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'Ad',
                icon: Icons.person_outline,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Soyad',
                icon: Icons.person_outline,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ageController,
                label: 'Yaş',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    dropdownColor: AppColors.surfaceBg,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('Erkek')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Kadın')),
                    ],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Fiziksel Parametreler ve Hedefler',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Kilo (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Boy (cm)',
                icon: Icons.height_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hedef Dropdown
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _target,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.track_changes_rounded, color: AppColors.textSecondary, size: 20),
                prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              items: const [
                DropdownMenuItem(value: 'MAINTAIN', child: Text('Formu Koru')),
                DropdownMenuItem(value: 'LOSE_WEIGHT', child: Text('Kilo Ver')),
                DropdownMenuItem(value: 'GAIN_WEIGHT', child: Text('Kilo Al')),
              ],
              onChanged: (v) => setState(() => _target = v!),
            ),
          ),
        ),
        if (_target == 'LOSE_WEIGHT' || _target == 'GAIN_WEIGHT') ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _targetWeightController,
            label: 'Hedef Kilo (kg)',
            icon: Icons.flag_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _targetDaysController,
            label: 'Hedef Süre (gün)',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Alerjen Hassasiyetleriniz ⚠️',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Yapay zeka analizlerinde uyarılmasını istediğiniz içerikleri seçin.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAllergens.map((allergen) {
            final isSelected = _selectedAllergens.contains(allergen);
            return FilterChip(
              label: Text(allergen),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAllergens.add(allergen);
                  } else {
                    _selectedAllergens.remove(allergen);
                  }
                });
              },
              selectedColor: AppColors.primaryGreen.withOpacity(0.15),
              checkmarkColor: AppColors.primaryGreen,
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'Günlük Kalori Hedefi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fiziksel özellikleriniz veya hedefleriniz değiştiğinde kalori hedefiniz yapay zeka (LLM) tarafından otomatik olarak yeniden hesaplanır. İsterseniz aşağıdaki alandan bu hedefi tamamen kendinize göre elinizle özelleştirebilirsiniz.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _calorieController,
          label: 'Günlük Hedef Kalori (kcal)',
          icon: Icons.local_fire_department_rounded,
          keyboardType: TextInputType.number,
          validator: (v) => v != null && v.isNotEmpty ? null : 'Gerekli',
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isSaving
          ? Container(
              decoration: BoxDecoration(
                gradient: AppColors.healthGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.healthGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Değişiklikleri Kaydet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Bağlantı Hatası',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
