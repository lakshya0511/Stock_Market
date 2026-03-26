import 'package:flutter/material.dart';
import 'package:virtual_trading_app/screens/home.dart';
import '../../services/api_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF050E1F);
const _surface = Color(0xFF0B1829);
const _surfaceHigh = Color(0xFF0F2035);
const _border = Color(0xFF132640);
const _accent = Color(0xFF1A7FE8);
const _textPrimary = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gain = Color(0xFF00D97E);
const _loss = Color(0xFFFF4D6A);
// ─────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void register() async {
    setState(() => isLoading = true);

    final res = await ApiService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      phoneController.text,
      cityController.text,
    );

    setState(() => isLoading = false);

    if (res["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["error"] ?? "Registration failed",
              style: const TextStyle(color: _textPrimary)),
          backgroundColor: _surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _loss, width: 1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Brand ──────────────────────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x331A7FE8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _accent, width: 1),
                ),
                child: const Icon(Icons.candlestick_chart_rounded,
                    color: _accent, size: 26),
              ),
              const SizedBox(height: 14),
              const Text(
                "FinPulse",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Create your account",
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 32),

              // ── Card ───────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _label("Full Name"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: nameController,
                      hint: "John Doe",
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _label("Email"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailController,
                      hint: "you@example.com",
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    _label("Password"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: passwordController,
                      hint: "Create a password",
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _textSecondary,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    _label("Phone"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: phoneController,
                      hint: "+91 98765 43210",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // City
                    _label("City"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: cityController,
                      hint: "Mumbai",
                      icon: Icons.location_city_outlined,
                    ),

                    const SizedBox(height: 24),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: isLoading
                          ? Container(
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _accent, width: 1),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: _accent, strokeWidth: 2),
                          ),
                        ),
                      )
                          : GestureDetector(
                        onTap: register,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Sign in link ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: _accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(color: _textSecondary, fontSize: 13),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: _textSecondary.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, color: _textSecondary, size: 18),
          suffixIcon: suffix != null
              ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: suffix,
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}