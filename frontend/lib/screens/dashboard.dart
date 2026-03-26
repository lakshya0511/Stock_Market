import 'package:flutter/material.dart';
import 'package:virtual_trading_app/screens/portfolio.dart';

import '../models/trade_model.dart';
import '../services/api_service.dart';

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
const _loss = Color(0xFFFF4D6A);
const _gainBg = Color(0x1200D97E);
const _lossBg = Color(0x12FF4D6A);
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List stocks = [];
  double wallet = 0;
  bool isLoading = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    loadData();
    refreshLoop();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  /* ===========================
     LOAD DATA
  =========================== */
  void loadData() async {
    await Future.wait([loadStocks(), loadWallet()]);
    setState(() => isLoading = false);
  }

  /* ===========================
     LOAD STOCKS
  =========================== */
  Future<void> loadStocks() async {
    final data = await ApiService.getStocks();
    setState(() => stocks = data);
  }

  /* ===========================
     LOAD WALLET
  =========================== */
  Future<void> loadWallet() async {
    final data = await ApiService.getWallet();
    setState(() => wallet = data);
  }

  /* ===========================
     AUTO REFRESH
  =========================== */
  void refreshLoop() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 5));
      loadStocks();
    }
  }

  /* ===========================
     OPEN BUY SHEET
  =========================== */
  void _openBuySheet(Map stock) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TradeModal(
        symbol: stock["symbol"],
        price: double.parse(stock["price"].toString()),
      ),
    );

    if (result == true) {
      loadStocks();
      loadWallet();
    }
  }

  /* ===========================
     BUILD UI
  =========================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildWalletCard(),
            _buildSectionLabel(),
            Expanded(child: _buildStockList()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border, width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textSecondary, size: 14),
            ),
          ),
          const SizedBox(width: 12),

          // Brand icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _accentGlow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent, width: 1),
            ),
            child: const Icon(Icons.candlestick_chart_rounded,
                color: _accent, size: 18),
          ),
          const SizedBox(width: 10),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MARKET",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Opacity(
                      opacity: _pulse.value,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _gain,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: _gain.withOpacity(0.6), blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "LIVE",
                    style: TextStyle(
                      color: _gain,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Portfolio button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PortfolioScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _accentGlow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: _accent, size: 15),
                  const SizedBox(width: 6),
                  const Text(
                    "Portfolio",
                    style: TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Wallet Card ─────────────────────────────────────────────────────────────
  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
              color: _accent.withOpacity(0.08), blurRadius: 24, spreadRadius: -4),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AVAILABLE BALANCE",
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
                    fontSize: 28,
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

  // ── Section Label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            "WATCHLIST",
            style: TextStyle(
              color: _textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: _border)),
          const SizedBox(width: 8),
          Text(
            "${stocks.length} stocks",
            style: const TextStyle(
                color: _textSecondary, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // ── Stock List ───────────────────────────────────────────────────────────────
  Widget _buildStockList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
            ),
            const SizedBox(height: 14),
            const Text("Fetching market data...",
                style: TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: () async {
        await loadStocks();
        await loadWallet();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
          double change = double.tryParse(stock["change"].toString()) ?? 0;
          final isGain = change >= 0;
          final changeColor = isGain ? _gain : _loss;
          final changeBg = isGain ? _gainBg : _lossBg;

          return GestureDetector(
            onTap: () => _openBuySheet(stock),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        (stock["symbol"] as String).substring(0, 1),
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock["symbol"],
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "₹${stock["price"]}",
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: changeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGain
                                  ? Icons.arrow_drop_up_rounded
                                  : Icons.arrow_drop_down_rounded,
                              color: changeColor,
                              size: 16,
                            ),
                            Text(
                              "${stock["change_percent"]}%",
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${isGain ? '+' : ''}${stock["change"]}",
                        style: TextStyle(color: changeColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded,
                      color: _border, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: _accent,
      elevation: 0,
      child: const Icon(Icons.refresh_rounded, color: Colors.white),
      onPressed: () {
        loadStocks();
        loadWallet();
      },
    );
  }
}