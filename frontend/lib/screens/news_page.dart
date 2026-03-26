import 'package:flutter/material.dart';
import 'package:virtual_trading_app/services/api_service.dart';
import 'news_details.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List news = [];
  bool loading = true;

  // ── Theme tokens (mirrors NewsDetailPage) ────────────────────────────────
  static const _bg           = Color(0xFFF5F1EB);
  static const _surface      = Color(0xFFFFFDF7);
  static const _ink          = Color(0xFF1A1A1A);
  static const _subInk       = Color(0xFF4A4A4A);
  static const _muted        = Color(0xFF8A8A8A);
  static const _rule         = Color(0xFFD4C9B0);
  static const _accent       = Color(0xFFC0392B);
  static const _likeGreen    = Color(0xFF27AE60);
  static const _likeGreenBg  = Color(0xFFEAF7EF);
  static const _dislikeRed   = Color(0xFFE74C3C);
  static const _dislikeRedBg = Color(0xFFFDECEA);
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() => loading = true);
    final result = await ApiService.getNews();
    if (!mounted) return;
    setState(() {
      news = result;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  // ── Reaction badge ────────────────────────────────────────────────────────
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
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              color: liked ? _likeGreen : _dislikeRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat chip (likes / comments count) ───────────────────────────────────
  // Accepts dynamic because the API may return int or String
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

  // ── Regular list card ─────────────────────────────────────────────────────
  Widget _newsCard(Map item) {
    final String? reaction  = item["user_reaction"];
    final String  category  = (item["category"] ?? "NEWS").toString().toUpperCase();
    final String? imageUrl = item["image_url"];
    final bool hasImage =
        imageUrl != null &&
            imageUrl != "null" &&
            imageUrl.trim().isNotEmpty &&
            imageUrl.startsWith("http");

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NewsDetailPage(news: item)),
      ).then((_) => _fetchNews()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _rule),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000), // black at ~4% opacity
              blurRadius: 4,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar — stretches to match row height via IntrinsicHeight
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
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        );
                      },

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey[200],
                          child: const Icon(Icons.article, size: 30, color: Colors.grey),
                        );
                      },
                    )
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
                        decoration: const BoxDecoration(
                          color: Color(0x1AC0392B), // _accent at ~10% opacity
                          borderRadius: BorderRadius.all(Radius.circular(2)),
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
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _ink,
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
                                fontFamily: 'Georgia',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "THE DAILY",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _fetchNews,
            tooltip: "Refresh",
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: _accent),
        ),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2,
        ),
      )
          : news.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.newspaper, size: 48, color: _muted),
            const SizedBox(height: 12),
            const Text(
              "No articles available",
              style: TextStyle(
                fontFamily: 'Georgia',
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
                style: TextStyle(
                  color: _accent,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: _accent,
        backgroundColor: _surface,
        onRefresh: _fetchNews,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          // +1 only when there are 2+ items (for the "LATEST STORIES" header)
          itemCount: news.length > 1 ? news.length + 1 : news.length,
          itemBuilder: (context, index) {

            if (index == 0 && news.length > 1) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Divider(color: _rule)),
                  ],
                ),
              );
            }

            // Remaining items: index 2+ map to news[index - 1]
            // (index 0 = featured, index 1 = header, index 2 = news[1], ...)
            final realIndex = index - 1;
            if (realIndex >= news.length) return const SizedBox.shrink();
            return _newsCard(news[realIndex]);
          },
        ),
      ),
    );
  }
}