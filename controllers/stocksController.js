import { pool } from "../db.js";
import axios from "axios";

/* ===========================
   PREDEFINED STOCK LIST
=========================== */
const STOCK_LIST = [
  "AAPL",
  "TSLA",
  "GOOGL",
  "MSFT",
  "AMZN",
  "META",
  "NVDA",
  "NFLX"
];

/* ===========================
   SEED STOCKS (RUN ON START)
=========================== */
export const seedStocks = async () => {
  try {
    console.log("🌱 Seeding stocks...");

    for (let symbol of STOCK_LIST) {
      await pool.query(
        `
        INSERT INTO stocks (symbol, price, change, change_percent, updated_at)
        VALUES ($1, 0, 0, 0, NOW())
        ON CONFLICT (symbol) DO NOTHING
        `,
        [symbol]
      );

      console.log(`✔ Added ${symbol}`);
    }

    console.log("✅ Stock seeding completed");

  } catch (err) {
    console.error("SEED ERROR:", err.message);
  }
};


/* ===========================
   GET ALL STOCKS
=========================== */
export const getStocks = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM stocks
      ORDER BY symbol
    `);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {
    console.error("GET STOCKS ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
};


/* ===========================
   FETCH STOCK FROM FINNHUB
=========================== */
const fetchStockPrice = async (symbol) => {
  try {
    console.log(`📡 Fetching ${symbol}...`);

    const res = await axios.get(
      "https://finnhub.io/api/v1/quote",
      {
        params: {
          symbol,
          token: process.env.FINNHUB_API_KEY
        }
      }
    );

    console.log(`📊 ${symbol}:`, res.data);

    return res.data;

  } catch (err) {
    console.error(`❌ Error fetching ${symbol}:`, err.message);
    return null;
  }
};


/* ===========================
   REFRESH STOCKS (MANUAL API)
=========================== */
export const refreshStocks = async (req, res) => {
  try {
    console.log("🔄 Manual stock refresh...");

    const stocks = await pool.query(`SELECT symbol FROM stocks`);

    for (let stock of stocks.rows) {
      const data = await fetchStockPrice(stock.symbol);

      if (!data || data.c === 0) {
        console.log(`⚠ Skipping ${stock.symbol}`);
        continue;
      }

      await pool.query(
        `
        UPDATE stocks
        SET price = $1,
            change = $2,
            change_percent = $3,
            updated_at = NOW()
        WHERE symbol = $4
        `,
        [data.c, data.d, data.dp, stock.symbol]
      );

      console.log(`✅ Updated ${stock.symbol} → ${data.c}`);
    }

    res.json({
      success: true,
      message: "Stocks updated"
    });

  } catch (err) {
    console.error("REFRESH ERROR:", err.message);

    res.status(500).json({
      success: false,
      error: "Failed to refresh stocks"
    });
  }
};


/* ===========================
   REFRESH STOCKS (CRON)
=========================== */
export const refreshStocksInternal = async () => {
  try {
    console.log("⏳ Auto stock refresh...");

    const stocks = await pool.query(`SELECT symbol FROM stocks`);

    for (let stock of stocks.rows) {
      const data = await fetchStockPrice(stock.symbol);

      if (!data || data.c === 0) continue;

      await pool.query(
        `
        UPDATE stocks
        SET price = $1,
            change = $2,
            change_percent = $3,
            updated_at = NOW()
        WHERE symbol = $4
        `,
        [data.c, data.d, data.dp, stock.symbol]
      );
    }

    console.log("✅ Auto refresh done");

  } catch (err) {
    console.error("CRON ERROR:", err.message);
  }
};