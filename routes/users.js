import express from "express";
import {
  createUser,
  loginUser,
  getUsers,
  getLeaderboard,
  getWallet
} from "../controllers/usersController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", createUser);
router.post("/login", loginUser);

router.get("/", getUsers);
router.get("/leaderboard", getLeaderboard);
router.get("/wallet/:userId", protect, getWallet);
export default router;