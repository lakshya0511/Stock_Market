import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import cron from "node-cron";

import usersRoutes from "./routes/users.js";
import stocksRoutes from "./routes/stocks.js";
import tradesRoutes from "./routes/trades.js";

import { seedStocks, refreshStocksInternal } from "./controllers/stocksController.js";
import newsRoutes from "./routes/news.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

/* ===========================
   MIDDLEWARE
=========================== */

app.use(cors({
  origin: "*",
}));

app.use(express.json());

/* ===========================
   ROUTES
=========================== */

app.get("/", (req, res) => {
  console.log("Root route hit");
  res.send("🚀 Virtual Trading Backend Ready");
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.use("/users", usersRoutes);
app.use("/stocks", stocksRoutes);
app.use("/trades", tradesRoutes);
app.use("/news", newsRoutes);

/* ===========================
   CRON JOB (AUTO STOCK UPDATE)
=========================== */

// runs every 5 minutes
cron.schedule("*/5 * * * *", async () => {
  console.log("⏳ Running scheduled stock update...");
  await refreshStocksInternal();
});

/* ===========================
   ERROR HANDLER
=========================== */

app.use((err, req, res, next) => {
  console.error("ERROR:", err.stack);

  res.status(500).json({
    success: false,
    error: "Internal server error"
  });
});

/* ===========================
   START SERVER
=========================== */

app.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);

  // 🔥 Seed stocks automatically on start
  await seedStocks();

  console.log("✅ Initial stock setup complete");
});