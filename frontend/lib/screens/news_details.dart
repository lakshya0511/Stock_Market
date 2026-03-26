import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NewsDetailPage extends StatefulWidget {
  final Map news;
  final String? initialReaction; // ← passed from HomeScreen local store

  const NewsDetailPage({
    required this.news,
    this.initialReaction, // ← nullable, defaults to null
    super.key,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  List comments = [];
  bool loading = true;
  String? userReaction;
  bool reacting = false;

  // ── Color Palette (matches app theme) ────────────────────────────────────
  static const _bg            = Color(0xFF050E1F);
  static const _surface       = Color(0xFF0B1829);
  static const _surfaceHigh   = Color(0xFF0F2035);
  static const _border        = Color(0xFF132640);
  static const _accent        = Color(0xFF1A7FE8);
  static const _accentGlow    = Color(0x331A7FE8);
  static const _textPrimary   = Color(0xFFE8F1FF);
  static const _textSecondary = Color(0xFF6B8BAE);
  static const _gain          = Color(0xFF00D97E);
  static const _gainBg        = Color(0x1A00D97E);
  static const _loss          = Color(0xFFFF4D6A);
  static const _lossBg        = Color(0x1AFF4D6A);
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Use initialReaction from HomeScreen's local store (not from API,
    // since backend doesn't return user_reaction in getNews())
    userReaction = widget.initialReaction;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final data = await ApiService.getComments(widget.news["news_id"]);
    if (!mounted) return;
    setState(() {
      comments = data;
      loading = false;
    });
  }

  void _handleReact(String type) async {
    if (userReaction != null || reacting) return;
    if (!mounted) return;
    setState(() => reacting = true);

    final res = await ApiService.reactToNews(widget.news["news_id"], type);

    if (!mounted) return;
    setState(() {
      if (res["success"] == true) userReaction = type;
      reacting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surfaceHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _border),
        ),
        content: Text(
          res["success"] == true
              ? "Reaction recorded"
              : res["error"] ?? "Something went wrong",
          style: const TextStyle(color: _textPrimary, fontSize: 13),
        ),
      ),
    );
  }

  // Always pop with the current reaction so HomeScreen can update the badge
  void _popWithReaction() {
    Navigator.pop(context, userReaction);
  }

  void _showCommentDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "LEAVE A COMMENT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: "Share your thoughts…",
                  hintStyle:
                  const TextStyle(color: _textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: _surfaceHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _accent, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 11),
                    ),
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;
                      final res = await ApiService.addComment(
                          widget.news["news_id"], controller.text.trim());
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      if (res["success"] == true) _fetchComments();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _surfaceHigh,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: _border),
                          ),
                          content: Text(
                            res["success"] == true
                                ? "Comment published"
                                : res["error"] ?? "Error",
                            style: const TextStyle(color: _textPrimary),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reaction button ───────────────────────────────────────────────────────
  Widget _reactionButton(String type, IconData icon, String label) {
    final bool isChosen = userReaction == type;
    final bool isLocked = userReaction != null;
    final bool isOther  = isLocked && !isChosen;

    final Color bg     = isChosen
        ? (type == "like" ? _gainBg : _lossBg)
        : _surfaceHigh;
    final Color fg     = isChosen
        ? (type == "like" ? _gain : _loss)
        : isOther
        ? _textSecondary
        : _textPrimary;
    final Color border = isChosen
        ? (type == "like" ? _gain : _loss)
        : _border;

    return GestureDetector(
      onTap: (isLocked || reacting) ? null : () => _handleReact(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: isChosen ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reacting && !isLocked)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: fg),
              )
            else
              Icon(icon, size: 16, color: fg),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: fg,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isChosen) ...[
              const SizedBox(width: 5),
              Icon(Icons.check_circle, size: 13, color: fg),
            ],
          ],
        ),
      ),
    );
  }

  // ── Comment tile ──────────────────────────────────────────────────────────
  Widget _commentTile(Map c) {
    final String name    = (c["name"] ?? "").toString().trim();
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _accentGlow,
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _accent,
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
                  name.isNotEmpty ? name : "Anonymous",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  c["comment"] ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news     = widget.news;
    final hasImage = news["image_url"] != null &&
        news["image_url"].toString().isNotEmpty &&
        news["image_url"].toString().startsWith("http");
    final category = (news["category"] ?? "NEWS").toString().toUpperCase();

    return PopScope(
      // PopScope replaces deprecated WillPopScope in Flutter 3.12+
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _popWithReaction();
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _surface,
          foregroundColor: _textPrimary,
          elevation: 0,
          centerTitle: true,
          // Override back button to pop with reaction
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithReaction,
          ),
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
                "Market News",
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

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Hero image ──────────────────────────────────────────
              if (hasImage)
                Image.network(
                  news["image_url"],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),

              // ── Article body ────────────────────────────────────────
              Container(
                color: _surface,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag (shown when no image)
                    if (!hasImage)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accentGlow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _accent, width: 0.8),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _accent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),

                    // Headline
                    Text(
                      news["title"] ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: _border, thickness: 1, height: 1),
                    const SizedBox(height: 10),

                    // Body
                    Text(
                      news["description"] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        height: 1.75,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Reaction bar ────────────────────────────────────────
              Container(
                color: _surface,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "READER REACTION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _reactionButton(
                            "like", Icons.thumb_up_alt_outlined, "Helpful"),
                        _reactionButton("dislike",
                            Icons.thumb_down_alt_outlined, "Not Helpful"),
                        GestureDetector(
                          onTap: _showCommentDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _accentGlow,
                              border: Border.all(color: _accent, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mode_comment_outlined,
                                    size: 16, color: _accent),
                                SizedBox(width: 7),
                                Text(
                                  "Comment",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _accent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (userReaction != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 13, color: _textSecondary),
                            SizedBox(width: 6),
                            Text(
                              "Your reaction has been recorded.",
                              style: TextStyle(
                                  fontSize: 12, color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Comments section ────────────────────────────────────
              Container(
                color: _surface,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "COMMENTS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: _textSecondary,
                          ),
                        ),
                        if (!loading) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _accentGlow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _border),
                            ),
                            child: Text(
                              "${comments.length}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: _accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(color: _border, thickness: 1, height: 1),
                    const SizedBox(height: 4),

                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: _accent, strokeWidth: 2),
                        ),
                      )
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            "No comments yet. Be the first to respond.",
                            style: TextStyle(
                                fontSize: 13, color: _textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, __) =>
                        const Divider(color: _border, height: 1),
                        itemBuilder: (_, i) => _commentTile(comments[i]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}