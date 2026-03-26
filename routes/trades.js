import express from "express";
import {
  createTrade,
  getPortfolio,
  getUserTrades
} from "../controllers/tradesController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", protect, createTrade);
router.get("/portfolio", protect, getPortfolio);
router.get("/user", protect, getUserTrades);

export default router;
