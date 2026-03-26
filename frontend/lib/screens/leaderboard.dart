import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ─── Color Palette (same as Dashboard & Portfolio) ────────────────────────────
const _bg = Color(0xFF050E1F);
const _surface = Color(0xFF0B1829);
const _surfaceHigh = Color(0xFF0F2035);
const _border = Color(0xFF132640);
const _accent = Color(0xFF1A7FE8);
const _accentGlow = Color(0x331A7FE8);
const _textPrimary = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gain = Color(0xFF00D97E);
const _gold = Color(0xFFFFB830);
const _silver = Color(0xFFB0BEC5);
const _bronze = Color(0xFFCD7F4A);
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  void loadLeaderboard() async {
    final res = await ApiService.getLeaderboard();
    setState(() {
      users = res;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (!isLoading && users.length >= 3) _buildPodium(),
            _buildSectionLabel(),
            Expanded(child: _buildList()),
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
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: _textSecondary, size: 15),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LEADERBOARD",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                "Top traders ranked by worth",
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0x33FFB830),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold.withOpacity(0.4), width: 1),
            ),
            child: Icon(Icons.emoji_events_outlined, color: _gold, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Podium (top 3) ───────────────────────────────────────────────────────────
  Widget _buildPodium() {
    final top3 = users.take(3).toList();
    // order: 2nd, 1st, 3rd
    final order = [1, 0, 2];
    final heights = [80.0, 108.0, 64.0];
    final medals = [_silver, _gold, _bronze];
    final ranks = ["2nd", "1st", "3rd"];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E2A50), Color(0xFF091830)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: order.map((i) {
          final user = top3[i];
          final color = medals[order.indexOf(i)];
          final height = heights[order.indexOf(i)];
          final rank = ranks[order.indexOf(i)];
          final isFirst = i == 0;

          return Expanded(
            child: Column(
              children: [
                // Crown for 1st
                if (isFirst)
                  Icon(Icons.workspace_premium_rounded,
                      color: _gold, size: 22)
                else
                  const SizedBox(height: 22),

                const SizedBox(height: 6),

                // Avatar circle
                Container(
                  width: isFirst ? 54 : 44,
                  height: isFirst ? 54 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _surfaceHigh,
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (user["name"] as String).substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: isFirst ? 20 : 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Name
                Text(
                  user["name"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: isFirst ? 13 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                // Worth
                Text(
                  "₹${user["total_worth"]}",
                  style: TextStyle(
                    color: _gain,
                    fontSize: isFirst ? 12 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Podium block
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    border: Border(
                      top: BorderSide(color: color.withOpacity(0.5), width: 1),
                      left: BorderSide(color: color.withOpacity(0.2), width: 1),
                      right: BorderSide(color: color.withOpacity(0.2), width: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      rank,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Text(
            "ALL RANKINGS",
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
            "${users.length} traders",
            style: TextStyle(color: _textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Full List ─────────────────────────────────────────────────────────────────
  Widget _buildList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
            ),
            const SizedBox(height: 14),
            Text("Fetching rankings...",
                style: TextStyle(color: _textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    if (users.isEmpty) {
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
              child: Icon(Icons.leaderboard_outlined,
                  color: _textSecondary, size: 32),
            ),
            const SizedBox(height: 16),
            Text("No rankings yet",
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text("Start trading to appear on the board",
                style: TextStyle(color: _textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final rank = index + 1;

        Color rankColor;
        Color rankBg;
        if (rank == 1) {
          rankColor = _gold;
          rankBg = Color(0x22FFB830);
        } else if (rank == 2) {
          rankColor = _silver;
          rankBg = Color(0x22B0BEC5);
        } else if (rank == 3) {
          rankColor = _bronze;
          rankBg = Color(0x22CD7F4A);
        } else {
          rankColor = _textSecondary;
          rankBg = _surfaceHigh;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: rank <= 3 ? _surfaceHigh : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rank <= 3 ? rankColor.withOpacity(0.2) : _border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rankBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: rank <= 3
                      ? Icon(Icons.emoji_events_rounded,
                      color: rankColor, size: 16)
                      : Text(
                    "$rank",
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _surfaceHigh,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rank <= 3 ? rankColor.withOpacity(0.5) : _border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    (user["name"] as String).substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: rank <= 3 ? rankColor : _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Text(
                  user["name"],
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Worth
              Text(
                "₹${user["total_worth"]}",
                style: TextStyle(
                  color: rank <= 3 ? rankColor : _gain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}