import { pool } from "../db.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

/* ===========================
   GENERATE JWT TOKEN
=========================== */
const generateToken = (user_id) => {
  return jwt.sign(
    { user_id },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};


/* ===========================
   REGISTER USER
=========================== */
export const createUser = async (req, res) => {
  try {

    const { name, email, password, phone_number, city } = req.body;

    console.log("Creating user:", email);

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        error: "Name, email and password required"
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const userResult = await pool.query(
      `INSERT INTO users (name, email, password, phone_number, city)
       VALUES ($1,$2,$3,$4,$5)
       RETURNING user_id,name,email,phone_number,city`,
      [name, email, hashedPassword, phone_number, city]
    );

    const user = userResult.rows[0];

    await pool.query(
      `INSERT INTO wallets (user_id, balance, locked)
       VALUES ($1,$2,$3)`,
      [user.user_id, 100000, false]
    );

    const token = generateToken(user.user_id);

    res.status(201).json({
      success: true,
      token,
      data: user
    });

  } catch (err) {

    if (err.code === "23505") {
      return res.status(400).json({
        success: false,
        error: "Email already registered"
      });
    }

    console.error(err);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });

  }
};


/* ===========================
   LOGIN USER
=========================== */
export const loginUser = async (req, res) => {

  try {

    const { email, password } = req.body;

    const result = await pool.query(
      `SELECT * FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: "Invalid email or password"
      });
    }

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(
      password,
      user.password
    );

    if (!validPassword) {
      return res.status(400).json({
        success: false,
        error: "Invalid email or password"
      });
    }

    const token = generateToken(user.user_id);

    res.json({
      success: true,
      token,
      data: {
        user_id: user.user_id,
        name: user.name,
        email: user.email
      }
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });

  }

};


/* ===========================
   GET USERS
=========================== */
export const getUsers = async (req, res) => {
  try {

    const result = await pool.query(
      `SELECT user_id,name,email,phone_number,city FROM users`
    );

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });

  }
};


/* ===========================
   LEADERBOARD
=========================== */
export const getLeaderboard = async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT 
        u.user_id,
        u.name,
        w.balance,

        COALESCE(SUM(
          (CASE 
            WHEN t.trade_type = 'buy' THEN t.quantity
            WHEN t.trade_type = 'sell' THEN -t.quantity
          END) * s.price
        ),0) AS portfolio_value,

        (w.balance + COALESCE(SUM(
          (CASE 
            WHEN t.trade_type = 'buy' THEN t.quantity
            WHEN t.trade_type = 'sell' THEN -t.quantity
          END) * s.price
        ),0)) AS total_worth

      FROM users u
      JOIN wallets w ON u.user_id = w.user_id
      LEFT JOIN trades t ON u.user_id = t.user_id
      LEFT JOIN stocks s ON t.symbol = s.symbol

      GROUP BY u.user_id,u.name,w.balance
      ORDER BY total_worth DESC
      LIMIT 50
    `);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });

  }
};


/* ===========================
   GET WALLET
=========================== */
export const getWallet = async (req, res) => {

  try {

    const userId = req.user.user_id;

    const result = await pool.query(
      `SELECT balance FROM wallets WHERE user_id=$1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: "Wallet not found"
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });

  }

};