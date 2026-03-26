import { pool } from "../db.js";

/* ===========================
   CREATE TRADE (FINAL)
   DB handles wallet + holdings
=========================== */
export const createTrade = async (req, res) => {
  const client = await pool.connect();

  try {
    const { symbol, quantity, trade_type } = req.body;
    const user_id = req.user.user_id;

    /* ===========================
       VALIDATION
    =========================== */
    if (!user_id || !symbol || !quantity || !trade_type) {
      return res.status(400).json({
        success: false,
        error: "Missing required fields"
      });
    }

    if (!["buy", "sell"].includes(trade_type)) {
      return res.status(400).json({
        success: false,
        error: "Invalid trade type"
      });
    }

    if (quantity <= 0) {
      return res.status(400).json({
        success: false,
        error: "Quantity must be greater than 0"
      });
    }

    const normalizedSymbol = symbol.toUpperCase();

    await client.query("BEGIN");

    /* ===========================
       GET STOCK PRICE
    =========================== */
    const stockResult = await client.query(
      `SELECT price FROM stocks WHERE symbol = $1`,
      [normalizedSymbol]
    );

    if (stockResult.rows.length === 0) {
      throw new Error("Stock does not exist");
    }

    const stockPrice = parseFloat(stockResult.rows[0].price);

    /* ===========================
       INSERT TRADE ONLY
       (Triggers handle everything)
    =========================== */
    const tradeResult = await client.query(
      `
      INSERT INTO trades (user_id, symbol, price, quantity, trade_type)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
      `,
      [
        user_id,
        normalizedSymbol,
        stockPrice,
        quantity,
        trade_type
      ]
    );

    await client.query("COMMIT");

    return res.status(201).json({
      success: true,
      data: tradeResult.rows[0]
    });

  } catch (err) {
    await client.query("ROLLBACK");

    console.error("TRADE ERROR:", err.message);

    return res.status(400).json({
      success: false,
      error: err.message
    });

  } finally {
    client.release();
  }
};


/* ===========================
   PORTFOLIO
   (Calculated from trades)
=========================== */
export const getPortfolio = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const result = await pool.query(
      `
      SELECT
        t.symbol,

        SUM(
          CASE
            WHEN t.trade_type = 'buy' THEN t.quantity
            WHEN t.trade_type = 'sell' THEN -t.quantity
          END
        ) AS total_quantity,

        CASE
          WHEN SUM(CASE WHEN t.trade_type='buy' THEN t.quantity END) IS NULL
          OR SUM(CASE WHEN t.trade_type='buy' THEN t.quantity END) = 0
          THEN 0
          ELSE
            SUM(CASE WHEN t.trade_type='buy' THEN t.price * t.quantity END)
            /
            SUM(CASE WHEN t.trade_type='buy' THEN t.quantity END)
        END AS avg_buy_price,

        s.price AS current_price,

        (
          SUM(
            CASE
              WHEN t.trade_type='buy' THEN t.quantity
              WHEN t.trade_type='sell' THEN -t.quantity
            END
          ) * s.price
        ) AS market_value

      FROM trades t
      JOIN stocks s ON t.symbol = s.symbol

      WHERE t.user_id = $1

      GROUP BY t.symbol, s.price

      HAVING SUM(
        CASE
          WHEN t.trade_type='buy' THEN t.quantity
          WHEN t.trade_type='sell' THEN -t.quantity
        END
      ) > 0
      `,
      [userId]
    );

    return res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("PORTFOLIO ERROR:", err);

    return res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
};


/* ===========================
   TRADE HISTORY
=========================== */
export const getUserTrades = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const result = await pool.query(
      `
      SELECT *
      FROM trades
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT 50
      `,
      [userId]
    );

    return res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("TRADE HISTORY ERROR:", err);

    return res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
};