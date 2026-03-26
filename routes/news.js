import express from "express";
import {
  fetchAndStoreNews,
  getNews,
  reactToNews,
  addComment,
  getComments
} from "../controllers/newsController.js";

const router = express.Router();

/* ===========================
   NEWS ROUTES
=========================== */

router.get("/fetch", fetchAndStoreNews);
router.get("/", getNews);

router.post("/react", reactToNews);
router.post("/comment", addComment);

router.get("/:news_id/comments", getComments);

export default router;