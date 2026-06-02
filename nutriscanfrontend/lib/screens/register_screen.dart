import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'MALE';
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        age: int.tryParse(_ageController.text) ?? 25,
        gender: _gender,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      setState(() { _errorMessage = 'Kayıt başarısız. Bu e-posta zaten kullanılıyor olabilir.'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hesap\nOluştur ✨',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Besin takibine hemen başla.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _firstNameController, label: 'Ad', icon: Icons.person_outline)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(controller: _lastNameController, label: 'Soyad', icon: Icons.person_outline)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@') ? null : 'Geçerli e-posta girin',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Şifre',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    validator: (v) => v != null && v.length >= 6 ? null : 'En az 6 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
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
                            border: Border.all(color: const Color(0xFF2E2550)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
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
                          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isLoading
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.accentOrange, AppColors.warmOrange]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.accentOrange, AppColors.warmOrange]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentOrange.withOpacity(0.4),
                                  blurRadius: 24, offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'Kayıt Ol',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
