import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'authentication/auth_wrapper.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF050E1F);
const _surface = Color(0xFF0B1829);
const _surfaceHigh = Color(0xFF0F2035);
const _border = Color(0xFF132640);
const _accent = Color(0xFF1A7FE8);
const _accentGlow = Color(0x331A7FE8);
const _textPrimary = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gain = Color(0xFF00D97E);
const _gainBg = Color(0x1200D97E);
const _loss = Color(0xFFFF4D6A);
const _lossBg = Color(0x12FF4D6A);
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map user = {};
  double wallet = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /* ===========================
     LOAD DATA
  =========================== */
  void loadProfile() async {
    final userData = await ApiService.getUser();
    final walletData = await ApiService.getWallet();

    setState(() {
      user = userData;
      wallet = walletData;
      isLoading = false;
    });
  }

  /* ===========================
     LOGOUT
  =========================== */
  void logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border, width: 1),
        ),
        title: const Text(
          "Sign Out",
          style: TextStyle(
              color: _textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Are you sure you want to sign out?",
          style: TextStyle(color: _textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: _textSecondary)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context); // close dialog
              await ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AuthWrapper()),
                    (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _lossBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _loss, width: 1),
              ),
              child: const Text(
                "Sign Out",
                style: TextStyle(
                    color: _loss,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  /* ===========================
     UI
  =========================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            isLoading
                ? const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                    color: _accent, strokeWidth: 2),
              ),
            )
                : Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 24),
                    _buildWalletCard(),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border, width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textSecondary, size: 15),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PROFILE",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                "Your account",
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentGlow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent, width: 1),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: _accent, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    final name = user["name"] ?? "?";
    final email = user["email"] ?? "";
    final initial = (name as String).isNotEmpty
        ? name[0].toUpperCase()
        : "?";

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _accentGlow,
            shape: BoxShape.circle,
            border: Border.all(color: _accent, width: 2),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: _accent,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(color: _textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _gainBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gain, width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: _gain, size: 13),
              SizedBox(width: 5),
              Text(
                "Virtual Trader",
                style: TextStyle(
                  color: _gain,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Wallet card ──────────────────────────────────────────────────────────────
  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E2A50), Color(0xFF091830)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent, width: 1),
        boxShadow: [
          BoxShadow(
              color: _accent.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: -4),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WALLET BALANCE",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${wallet.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentGlow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent, width: 1),
            ),
            child: const Icon(Icons.account_balance_outlined,
                color: _accent, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACCOUNT DETAILS",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.phone_outlined,
            "Phone",
            user["phone_number"] ?? "—",
          ),
          Container(
              height: 1,
              color: _border,
              margin: const EdgeInsets.symmetric(vertical: 12)),
          _infoRow(
            Icons.location_city_outlined,
            "City",
            user["city"] ?? "—",
          ),
          Container(
              height: 1,
              color: _border,
              margin: const EdgeInsets.symmetric(vertical: 12)),
          _infoRow(
            Icons.alternate_email_rounded,
            "Email",
            user["email"] ?? "—",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surfaceHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: _textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // ── Logout button ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: logout,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _lossBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _loss, width: 1),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: _loss, size: 18),
              SizedBox(width: 10),
              Text(
                "Sign Out",
                style: TextStyle(
                  color: _loss,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}