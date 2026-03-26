import axios from "axios";
import { pool } from "../db.js";

/* ===========================
   FETCH & STORE STOCK NEWS
=========================== */
export const fetchAndStoreNews = async (req, res) => {
  try {
    console.log("📡 Fetching STOCK MARKET news from Finnhub...");

    const response = await axios.get(
      "https://finnhub.io/api/v1/news",
      {
        params: {
          category: "general",
          token: process.env.FINNHUB_API_KEY
        }
      }
    );

    const articles = response.data.slice(0, 10);

    console.log(`📊 Fetched ${articles.length} articles`);

    /* 🔥 IMAGE VALIDATION */
    const isValidImage = (url) => {
      if (!url) return false;

      return (
        url.startsWith("https://") &&
        !url.includes("finnhub.io/file/finnhub/logo") &&
        !url.includes("google.com/rss") &&
        (
          url.includes("cnbcfm.com") ||
          url.includes("reuters.com") ||
          url.includes("bloomberg.com") ||
          url.includes("wsj.com")
        )
      );
    };

    /* 🔥 STOCK FILTER */
    const includeKeywords = [
      "stock","stocks","market","markets","shares","equity",
      "trading","nasdaq","dow","s&p","invest","investor",
      "earnings","ipo","wall street"
    ];

    const excludeKeywords = [
      "war","military","missile","iran","israel",
      "conflict","attack","killed","sports",
      "football","cricket","celebrity","movie"
    ];

    for (let article of articles) {
      try {
        console.log("➡ Trying:", article.headline);

        if (!article.url) {
          console.log("❌ Skipped (no URL)");
          continue;
        }

        const title = article.headline.toLowerCase();

        const isRelevant =
          includeKeywords.some(k => title.includes(k)) &&
          !excludeKeywords.some(k => title.includes(k));

        if (!isRelevant) {
          console.log("⏭ Skipped (not stock related):", article.headline);
          continue;
        }

        /* 🔥 CLEAN IMAGE */
        const image = isValidImage(article.image)
          ? article.image
          : null;

        const result = await pool.query(
          `
          INSERT INTO news (title, description, url, image_url, source, published_at)
          VALUES ($1,$2,$3,$4,$5,$6)
          ON CONFLICT (url) DO NOTHING
          RETURNING *
          `,
          [
            article.headline || "No title",
            article.summary || "No description",
            article.url,
            image,
            article.source || "Unknown",
            new Date(article.datetime * 1000)
          ]
        );

        if (result.rowCount > 0) {
          console.log("✅ INSERTED:", result.rows[0].title);
        } else {
          console.log("⚠ SKIPPED (duplicate):", article.headline);
        }

      } catch (err) {
        console.error("❌ INSERT ERROR:", err.message);
      }
    }

    res.json({
      success: true,
      message: "Stock news fetched and stored"
    });

  } catch (err) {
    console.error("NEWS FETCH ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to fetch news"
    });
  }
};


/* ===========================
   GET NEWS WITH COUNTS
=========================== */
export const getNews = async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT 
        n.*,

        COALESCE(l.likes, 0) AS likes_count,
        COALESCE(d.dislikes, 0) AS dislikes_count,
        COALESCE(c.comments, 0) AS comments_count

      FROM news n

      LEFT JOIN (
        SELECT news_id, COUNT(*) AS likes
        FROM news_reactions
        WHERE reaction_type = 'like'
        GROUP BY news_id
      ) l ON n.news_id = l.news_id

      LEFT JOIN (
        SELECT news_id, COUNT(*) AS dislikes
        FROM news_reactions
        WHERE reaction_type = 'dislike'
        GROUP BY news_id
      ) d ON n.news_id = d.news_id

      LEFT JOIN (
        SELECT news_id, COUNT(*) AS comments
        FROM news_comments
        GROUP BY news_id
      ) c ON n.news_id = c.news_id

      ORDER BY n.published_at DESC
      LIMIT 20
      `
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("GET NEWS ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to get news"
    });
  }
};


/* ===========================
   LIKE / DISLIKE
=========================== */
export const reactToNews = async (req, res) => {
  try {
    const { user_id, news_id, reaction_type } = req.body;

    if (!["like", "dislike"].includes(reaction_type)) {
      return res.status(400).json({
        success: false,
        error: "Invalid reaction"
      });
    }

    await pool.query(
      `
      INSERT INTO news_reactions (user_id, news_id, reaction_type)
      VALUES ($1,$2,$3)
      ON CONFLICT (user_id, news_id)
      DO UPDATE SET reaction_type = EXCLUDED.reaction_type
      `,
      [user_id, news_id, reaction_type]
    );

    res.json({
      success: true,
      message: "Reaction updated"
    });

  } catch (err) {
    console.error("REACTION ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to react"
    });
  }
};


/* ===========================
   ADD COMMENT
=========================== */
export const addComment = async (req, res) => {
  try {
    const { user_id, news_id, comment } = req.body;

    if (!comment || comment.trim() === "") {
      return res.status(400).json({
        success: false,
        error: "Comment cannot be empty"
      });
    }

    const result = await pool.query(
      `
      INSERT INTO news_comments (user_id, news_id, comment)
      VALUES ($1,$2,$3)
      RETURNING *
      `,
      [user_id, news_id, comment]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (err) {
    console.error("COMMENT ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to add comment"
    });
  }
};


/* ===========================
   GET COMMENTS
=========================== */
export const getComments = async (req, res) => {
  try {
    const { news_id } = req.params;

    const result = await pool.query(
      `
      SELECT nc.*, u.name
      FROM news_comments nc
      JOIN users u ON nc.user_id = u.user_id
      WHERE news_id = $1
      ORDER BY created_at DESC
      `,
      [news_id]
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("GET COMMENTS ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to get comments"
    });
  }
};