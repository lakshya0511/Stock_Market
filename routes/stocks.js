import express from "express";
import {
  getStocks,
  refreshStocks
} from "../controllers/stocksController.js";

const router = express.Router();

/* ===========================
   STOCK ROUTES
=========================== */

// Get all stocks
router.get("/", getStocks);

// Refresh prices manually
router.get("/refresh", refreshStocks);

export default router;