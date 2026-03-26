import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _surface = Color(0xFF0B1829);
const _surfaceHigh = Color(0xFF0F2035);
const _border = Color(0xFF132640);
const _accent = Color(0xFF1A7FE8);
const _accentGlow = Color(0x331A7FE8);
const _textPrimary = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gain = Color(0xFF00D97E);
const _gainBg = Color(0x1200D97E);
// ─────────────────────────────────────────────────────────────────────────────

class TradeModal extends StatefulWidget {
  final String symbol;
  final double price;

  TradeModal({required this.symbol, required this.price});

  @override
  _TradeModalState createState() => _TradeModalState();
}

class _TradeModalState extends State<TradeModal> {
  int quantity = 1;
  bool isLoading = false;

  void trade(String type) async {
    setState(() => isLoading = true);
    await ApiService.trade(widget.symbol, quantity, type);
    Navigator.pop(context, true);
  }

  double get totalAmount => widget.price * quantity;

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
            // ── Accent top border line ───────────────────────────────────────
            Container(
              height: 1,
              color: _accent,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 22),
                  _buildStockHeader(),
                  const SizedBox(height: 24),
                  Container(height: 1, color: _border),
                  const SizedBox(height: 24),
                  _buildQuantityStepper(),
                  const SizedBox(height: 20),
                  _buildOrderSummary(),
                  const SizedBox(height: 24),
                  _buildBuyButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Drag handle ──────────────────────────────────────────────────────────────
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

  // ── Stock header ─────────────────────────────────────────────────────────────
  Widget _buildStockHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _surfaceHigh,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _accent, width: 1.5),
          ),
          child: Center(
            child: Text(
              widget.symbol.substring(0, 1),
              style: const TextStyle(
                color: _accent,
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
                widget.symbol,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                "Place a buy order",
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _accentGlow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${widget.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: _accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "per share",
                style: TextStyle(color: _textSecondary, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
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
                "$quantity share${quantity == 1 ? '' : 's'}",
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
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
                onTap: () => setState(() => quantity++),
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
          _summaryRow("Price per share", "₹${widget.price.toStringAsFixed(2)}"),
          const SizedBox(height: 11),
          _summaryRow("Quantity", "$quantity share${quantity == 1 ? '' : 's'}"),
          const SizedBox(height: 14),
          Container(height: 1, color: _border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL AMOUNT",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _gainBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: _gain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
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

  // ── Buy button ────────────────────────────────────────────────────────────────
  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isLoading
          ? Container(
        decoration: BoxDecoration(
          color: _gain.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gain, width: 1),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: _gain, strokeWidth: 2),
          ),
        ),
      )
          : GestureDetector(
        onTap: () => trade("buy"),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D97E), Color(0xFF00A85F)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _gain.withOpacity(0.3),
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
                const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  "BUY  ·  ₹${totalAmount.toStringAsFixed(2)}",
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