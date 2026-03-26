import 'package:flutter/material.dart';

// ─── Color Palette (matches app theme) ───────────────────────────────────────
const _bg            = Color(0xFF050E1F);
const _surface       = Color(0xFF0B1829);
const _surfaceHigh   = Color(0xFF0F2035);
const _border        = Color(0xFF132640);
const _accent        = Color(0xFF1A7FE8);
const _accentGlow    = Color(0x331A7FE8);
const _textPrimary   = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gain          = Color(0xFF00D97E);
const _gold          = Color(0xFFFFB830);
const _loss          = Color(0xFFFF4D6A);
// ─────────────────────────────────────────────────────────────────────────────

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "About Us",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Stack(
        children: [
          // Watermark logo
          Center(
            child: Opacity(
              opacity: 0.04,
              child: Image.asset(
                "assets/logo.png",
                width: 360,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Branding header ─────────────────────────────────────────
                Container(
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _accentGlow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _accent, width: 1),
                        ),
                        child: const Icon(
                          Icons.candlestick_chart_rounded,
                          color: _accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Virtual Trading Platform",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Trade Smart. Risk Nothing. Learn Everything.",
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Sections ────────────────────────────────────────────────
                _Section(
                  title: "🎯 About This Project",
                  content:
                  "Virtual Trading Platform is a full-stack stock market simulator "
                      "designed to give beginners a risk-free environment to experience "
                      "real-world trading. Users can register, manage a digital wallet, "
                      "and trade stocks using real or simulated market data — all without "
                      "spending a single rupee.\n\n"
                      "The platform was built to lower the barrier to financial literacy. "
                      "Whether you're a student curious about investing or a beginner "
                      "unsure where to start, this app gives you the tools to learn by doing.",
                ),

                _Section(
                  title: "🚀 Our Mission",
                  content:
                  "Our mission is to make stock market education hands-on, accessible, "
                      "and beginner-friendly. We believe the best way to learn investing is "
                      "to actually invest — safely. By simulating real market conditions, "
                      "we help users build strategies, understand risk, and develop "
                      "confidence before stepping into the real market.",
                ),

                _Section(
                  title: "📚 What We Offer",
                  isList: true,
                  content:
                  "Virtual wallet with simulated funds to start trading immediately\n"
                      "Real-time stock browsing with live buy and sell order execution\n"
                      "Full transaction history to review every trade you've made\n"
                      "Market news feed with community reactions and comments\n"
                      "Leaderboard to compare your portfolio performance with others\n"
                      "Secure authentication and personal profile management",
                ),

                // ── How It Works ────────────────────────────────────────────
                _HowItWorksSection(),

                _Section(
                  title: "🌐 Our Vision",
                  content:
                  "We envision a world where anyone — regardless of background or "
                      "income — can understand and participate in financial markets. "
                      "By combining education with hands-on practice, we aim to build "
                      "a generation of smarter, more confident investors.",
                ),

                const SizedBox(height: 8),

                // ── Footer ──────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Divider(color: _border),
                      const SizedBox(height: 20),
                      const Text(
                        "Learn smart. Trade safe. Grow financially.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card (mirrors your existing _Section style) ───────────────────────
class _Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isList;

  const _Section({
    required this.title,
    required this.content,
    this.isList = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _accent,
            ),
          ),
          const SizedBox(height: 12),
          if (isList)
            ...content.split('\n').where((l) => l.trim().isNotEmpty).map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.65,
              ),
            ),
        ],
      ),
    );
  }
}

// ── How It Works (timeline, same style as rest of page) ───────────────────────
class _HowItWorksSection extends StatelessWidget {
  static const _steps = [
    _Step(
      number: "01",
      icon: Icons.person_add_alt_1_outlined,
      title: "Register & Get Funded",
      description:
      "Create an account and receive a virtual wallet loaded with simulated funds. No real money needed.",
      color: _accent,
    ),
    _Step(
      number: "02",
      icon: Icons.search_rounded,
      title: "Browse the Market",
      description:
      "Explore stocks and read market news — just like a real brokerage platform.",
      color: _gold,
    ),
    _Step(
      number: "03",
      icon: Icons.swap_horiz_rounded,
      title: "Buy & Sell Stocks",
      description:
      "Execute orders instantly. Your portfolio updates in real time reflecting your gains and losses.",
      color: _gain,
    ),
    _Step(
      number: "04",
      icon: Icons.bar_chart_rounded,
      title: "Track Your Performance",
      description:
      "Review your transaction history and compete with others on the leaderboard.",
      color: Color(0xFF9B6FE8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚙️ How It Works",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _accent,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isLast = i == _steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline column
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: step.color, width: 1),
                      ),
                      child: Icon(step.icon, color: step.color, size: 16),
                    ),
                    if (!isLast)
                      Container(
                        width: 1,
                        height: 36,
                        color: _border,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              step.number,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: step.color,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Step {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}