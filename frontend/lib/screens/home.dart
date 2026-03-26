import 'package:flutter/material.dart';
import 'package:virtual_trading_app/screens/about_us.dart';
import 'package:virtual_trading_app/screens/dashboard.dart';
import 'package:virtual_trading_app/screens/leaderboard.dart';
import 'package:virtual_trading_app/screens/news_page.dart';
import 'package:virtual_trading_app/screens/profile.dart';
import '../services/api_service.dart';
import 'news_details.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg            = Color(0xFF050E1F);
const _surface       = Color(0xFF0B1829);
const _border        = Color(0xFF132640);
const _accent        = Color(0xFF1A7FE8);
const _accentGlow    = Color(0x331A7FE8);
const _textPrimary   = Color(0xFFE8F1FF);
const _textSecondary = Color(0xFF6B8BAE);
const _gold          = Color(0xFFFFB830);
const _muted         = Color(0xFF8A8A8A);
const _rule          = Color(0xFF1C3050);
const _likeGreen     = Color(0xFF27AE60);
const _likeGreenBg   = Color(0xFF0D2A1A);
const _dislikeRed    = Color(0xFFE74C3C);
const _dislikeRedBg  = Color(0xFF2A0D0D);
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, this.userName = "Trader"}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _news = [];
  bool _loading = true;

  // Local reaction store: newsId → "like" | "dislike"
  // Since the backend doesn't return user_reaction, we track it in memory.
  // The badge persists as long as the user stays in the app session.
  final Map<String, String> _localReactions = {};

  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final result = await ApiService.getNews();
    if (!mounted) return;
    setState(() {
      _news = result;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // NewsDetailPage calls Navigator.pop(context, reactionString) when user reacts.
  // We catch it here and store it locally so the badge shows on the list card.
  void _openDetail(Map item) {
    final String newsId = item["news_id"]?.toString() ?? "";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailPage(
          news: item,
          initialReaction: _localReactions[newsId], // pre-lock if already reacted
        ),
      ),
    ).then((result) {
      if (result is String && newsId.isNotEmpty) {
        setState(() => _localReactions[newsId] = result);
      }
    });
  }

  // ── Reaction badge ──────────────────────────────────────────────────────────
  Widget _reactionBadge(String reaction) {
    final bool liked = reaction == "like";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: liked ? _likeGreenBg : _dislikeRedBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: liked ? _likeGreen : _dislikeRed,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            liked ? Icons.thumb_up_alt : Icons.thumb_down_alt,
            size: 11,
            color: liked ? _likeGreen : _dislikeRed,
          ),
          const SizedBox(width: 4),
          Text(
            liked ? "You liked" : "You disliked",
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: liked ? _likeGreen : _dislikeRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat chip ───────────────────────────────────────────────────────────────
  Widget _statChip(IconData icon, dynamic rawCount) {
    final int count = rawCount is int
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '0') ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _muted),
        const SizedBox(width: 3),
        Text(
          "$count",
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      ],
    );
  }

  // ── News card ───────────────────────────────────────────────────────────────
  Widget _newsCard(Map item) {
    final String newsId = item["news_id"]?.toString() ?? "";
    final String? reaction = _localReactions[newsId]; // from local store
    final String category =
    (item["category"] ?? "NEWS").toString().toUpperCase();
    final String? imageUrl = item["image_url"];
    final bool hasImage = imageUrl != null &&
        imageUrl != "null" &&
        imageUrl.trim().isNotEmpty &&
        imageUrl.startsWith("http");

    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _rule),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 3,
                decoration: const BoxDecoration(
                  color: _accent,
                  borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(4)),
                ),
              ),

              // Thumbnail
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Image.network(
                    imageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        alignment: Alignment.center,
                        color: _bg,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: _bg,
                      child: const Icon(Icons.article,
                          size: 30, color: _textSecondary),
                    ),
                  ),
                )
              else
                Container(
                  width: 90,
                  height: 90,
                  color: _bg,
                  child: const Icon(Icons.article_outlined,
                      size: 28, color: _muted),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentGlow,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Title
                      Text(
                        item["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Footer
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["source"] ?? "",
                              style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: _muted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (reaction != null)
                            _reactionBadge(reaction)
                          else ...[
                            _statChip(Icons.thumb_up_alt_outlined,
                                item["likes_count"] ?? 0),
                            const SizedBox(width: 8),
                            _statChip(Icons.mode_comment_outlined,
                                item["comments_count"] ?? 0),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action tile ─────────────────────────────────────────────────────────────
  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: _textSecondary, size: 14),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: _border, height: 1)),
        ],
      ),
    );
  }

  Widget _newsColumnHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: _accent),
          const SizedBox(width: 8),
          const Text(
            "LATEST STORIES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: _textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: _rule)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _fetchNews,
            child: const Icon(Icons.refresh, size: 16, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _newsList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
        ),
      );
    }

    if (_news.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.newspaper, size: 48, color: _muted),
            const SizedBox(height: 12),
            const Text(
              "No articles available",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: _muted,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchNews,
              child: const Text(
                "Try again",
                style: TextStyle(color: _accent),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _news.map<Widget>((item) => _newsCard(item as Map)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
          backgroundColor: _surface,
          onRefresh: _fetchNews,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        "QUICK ACCESS",
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Divider(color: _border)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Virtual Trading hero card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _push(DashboardScreen()),
                    child: Container(
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
                            color: _accent.withOpacity(0.15),
                            blurRadius: 24,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _accentGlow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _accent, width: 1),
                            ),
                            child: const Icon(
                                Icons.candlestick_chart_rounded,
                                color: _accent,
                                size: 26),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Virtual Trading",
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Trade stocks with virtual money\nZero risks",
                                  style: TextStyle(
                                      color: _textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "OPEN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3 action tiles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _actionTile(
                          icon: Icons.emoji_events_outlined,
                          label: "Leaderboard",
                          color: _gold,
                          onTap: () => _push(LeaderboardScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionTile(
                          icon: Icons.person_outline_rounded,
                          label: "Profile",
                          color: _accent,
                          onTap: () => _push(ProfileScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionTile(
                          icon: Icons.info_outline_rounded,
                          label: "About Us",
                          color: const Color(0xFF9B6FE8),
                          onTap: () => _push(AboutUsPage()),
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionHeader("MARKET NEWS", Icons.article_outlined),
                _newsColumnHeader(),
                const SizedBox(height: 4),
                _newsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}