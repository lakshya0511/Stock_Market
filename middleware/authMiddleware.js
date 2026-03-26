import jwt from "jsonwebtoken";

export const protect = (req, res, next) => {
  try {

    const authHeader = req.headers.authorization;

    console.log("AUTH HEADER:", authHeader);

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        error: "No token provided"
      });
    }

    const token = authHeader.split(" ")[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    console.log("DECODED TOKEN:", decoded);

    req.user = decoded;

    next();

  } catch (err) {

    console.error("AUTH ERROR:", err.message);

    return res.status(401).json({
      success: false,
      error: "Invalid token"
    });
  }
};