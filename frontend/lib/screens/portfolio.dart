import 'package:flutter/material.dart';
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

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List portfolio = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPortfolio();
  }

  /* ===========================
     LOAD PORTFOLIO
  =========================== */
  void loadPortfolio() async {
    final data = await ApiService.getPortfolio();
    setState(() {
      portfolio = data;
      isLoading = false;
    });
  }

  /* ===========================
     SELL STOCK
  =========================== */
  void sellStock(String symbol, int quantity) async {
    await ApiService.trade(symbol, quantity, "sell");
    loadPortfolio();
  }

  /* ===========================
     SHOW SELL SHEET
  =========================== */
  void _openSellSheet(Map stock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SellSheet(
        stock: stock,
        onSell: (qty) {
          sellStock(stock["symbol"], qty);
        },
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
            if (!isLoading && portfolio.isNotEmpty) _buildSummaryCard(),
            _buildSectionLabel(),
            Expanded(child: _buildBody()),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PORTFOLIO",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const Text(
                "Your holdings",
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
            child: const Icon(Icons.pie_chart_outline_rounded,
                color: _accent, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    double totalValue = 0;
    double totalPnl = 0;

    for (final stock in portfolio) {
      double current = double.tryParse(stock["current_price"].toString()) ?? 0;
      double avg = double.tryParse(stock["avg_buy_price"].toString()) ?? 0;
      double qty = double.tryParse(stock["total_quantity"].toString()) ?? 0;
      totalValue += double.tryParse(stock["market_value"].toString()) ?? 0;
      totalPnl += (current - avg) * qty;
    }

    final isPnlPositive = totalPnl >= 0;
    final pnlColor = isPnlPositive ? _gain : _loss;
    final pnlBg = isPnlPositive ? _gainBg : _lossBg;

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
                  "TOTAL VALUE",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹${totalValue.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: _border),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "TOTAL P&L",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pnlBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPnlPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: pnlColor,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${isPnlPositive ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            "HOLDINGS",
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
            "${portfolio.length} positions",
            style: const TextStyle(color: _textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
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
            const Text("Loading portfolio...",
                style: TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _border, width: 1),
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: _textSecondary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              "No holdings yet",
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "Buy stocks from the market to get started",
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: portfolio.length,
      itemBuilder: (context, index) {
        final stock = portfolio[index];

        double current =
            double.tryParse(stock["current_price"].toString()) ?? 0;
        double avg = double.tryParse(stock["avg_buy_price"].toString()) ?? 0;
        double qty = double.tryParse(stock["total_quantity"].toString()) ?? 0;
        double pnl = (current - avg) * qty;

        final isPnlPositive = pnl >= 0;
        final pnlColor = isPnlPositive ? _gain : _loss;
        final pnlBg = isPnlPositive ? _gainBg : _lossBg;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top row
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
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
                            fontSize: 16,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${qty.toStringAsFixed(0)} shares  ·  Avg ₹${avg.toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: _textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${stock["market_value"]}",
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Market Value",
                          style:
                          TextStyle(color: _textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 1, color: _border),
                const SizedBox(height: 12),

                // Bottom row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: pnlBg,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPnlPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: pnlColor,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "P&L  ${isPnlPositive ? '+' : ''}₹${pnl.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: pnlColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${current.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 11),
                        ),
                        Text(
                          "LTP",
                          style: TextStyle(
                            color: _textSecondary.withOpacity(0.5),
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Sell button → opens bottom sheet
                    GestureDetector(
                      onTap: () => _openSellSheet(stock),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _lossBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _loss, width: 1),
                        ),
                        child: const Text(
                          "SELL",
                          style: TextStyle(
                            color: _loss,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Sell Bottom Sheet ────────────────────────────────────────────────────────
class _SellSheet extends StatefulWidget {
  final Map stock;
  final Function(int quantity) onSell;

  const _SellSheet({required this.stock, required this.onSell});

  @override
  _SellSheetState createState() => _SellSheetState();
}

class _SellSheetState extends State<_SellSheet> {
  int quantity = 1;
  bool isLoading = false;

  double get currentPrice =>
      double.tryParse(widget.stock["current_price"].toString()) ?? 0;
  double get avgPrice =>
      double.tryParse(widget.stock["avg_buy_price"].toString()) ?? 0;
  int get maxQty =>
      int.tryParse(widget.stock["total_quantity"].toString()) ?? 1;

  double get pnlPerShare => currentPrice - avgPrice;
  double get totalPnl => pnlPerShare * quantity;
  double get totalReturn => currentPrice * quantity;
  bool get isProfit => pnlPerShare >= 0;

  void _sell() async {
    setState(() => isLoading = true);
    widget.onSell(quantity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accent top line
            Container(height: 1, color: _loss),

            Padding(
              padding: EdgeInsets.fromLTRB(
                24, 20, 24,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 22),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPnlPerShareCard(),
                  const SizedBox(height: 20),
                  Container(height: 1, color: _border),
                  const SizedBox(height: 20),
                  _buildQuantityStepper(),
                  const SizedBox(height: 20),
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildSellButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: _border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _surfaceHigh,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _loss, width: 1.5),
          ),
          child: Center(
            child: Text(
              (widget.stock["symbol"] as String).substring(0, 1),
              style: const TextStyle(
                color: _loss,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.stock["symbol"],
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                "Place a sell order",
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        // LTP chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _lossBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _loss, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${currentPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: _loss,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "LTP",
                style: TextStyle(color: _textSecondary, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── P&L per share card ───────────────────────────────────────────────────────
  Widget _buildPnlPerShareCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        children: [
          // Avg buy price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AVG BUY PRICE",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "₹${avgPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(Icons.arrow_forward_rounded,
              color: _textSecondary, size: 16),

          // Current price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "CURRENT PRICE",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "₹${currentPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 36, color: _border),
          const SizedBox(width: 12),

          // P&L per share
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "PER SHARE",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isProfit ? _gainBg : _lossBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${isProfit ? '+' : ''}₹${pnlPerShare.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: isProfit ? _gain : _loss,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quantity stepper ─────────────────────────────────────────────────────────
  Widget _buildQuantityStepper() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "QUANTITY",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "$quantity of $maxQty available",
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border, width: 1),
          ),
          child: Row(
            children: [
              _stepperBtn(
                icon: Icons.remove_rounded,
                onTap: quantity > 1 ? () => setState(() => quantity--) : null,
              ),
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: _border, width: 1),
                  ),
                ),
                child: Text(
                  "$quantity",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _stepperBtn(
                icon: Icons.add_rounded,
                onTap: quantity < maxQty
                    ? () => setState(() => quantity++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepperBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(
          icon,
          color: onTap != null ? _textPrimary : _border,
          size: 18,
        ),
      ),
    );
  }

  // ── Order summary ─────────────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          _summaryRow("Sell price", "₹${currentPrice.toStringAsFixed(2)}"),
          const SizedBox(height: 11),
          _summaryRow("Quantity", "$quantity share${quantity == 1 ? '' : 's'}"),
          const SizedBox(height: 11),
          _summaryRow(
            "Total return",
            "₹${totalReturn.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL P&L",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isProfit ? _gainBg : _lossBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: isProfit ? _gain : _loss,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${isProfit ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isProfit ? _gain : _loss,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Sell button ───────────────────────────────────────────────────────────────
  Widget _buildSellButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isLoading
          ? Container(
        decoration: BoxDecoration(
          color: _loss.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _loss, width: 1),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: _loss, strokeWidth: 2),
          ),
        ),
      )
          : GestureDetector(
        onTap: _sell,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4D6A), Color(0xFFCC2244)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _loss.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sell_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  "SELL  ·  ₹${totalReturn.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}