import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const String baseUrl = "https://stock-market-fsvc.onrender.com";

  static String? token;
  static String? userId; // ✅ ADD THIS

/* ===========================
   SAVE AUTH
=========================== */
  static Future<void> saveAuth(String tokenValue, String userIdValue) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", tokenValue);
    await prefs.setString("userId", userIdValue);

    // 🔥 FORCE SYNC (important for web)
    await prefs.reload();

    token = tokenValue;
    userId = userIdValue;

    print("SAVED TOKEN: $token");
    print("SAVED USERID: $userId");
  }
/* ===========================
   LOAD AUTH
=========================== */
  static Future<bool> loadAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      token = prefs.getString("token");
      userId = prefs.getString("userId");

      print("TOKEN FROM STORAGE: $token");
      print("USERID FROM STORAGE: $userId");

      return token != null && userId != null;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getUser() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/users"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      // Find current user
      return data["data"]
          .firstWhere((u) => u["user_id"] == userId);
    } catch (e) {
      return {};
    }
  }

/* ===========================
   LOGOUT
=========================== */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token = null;
    userId = null;
  }

  /* ===========================
     GET NEWS
  =========================== */
  static Future<List<dynamic>> getNews() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/news"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /* ===========================
     LIKE / DISLIKE NEWS
  =========================== */
  static Future<Map<String, dynamic>> reactToNews(
      String newsId, String type) async {
    try {
      if (userId == null) {
        return {"success": false, "error": "User not logged in"};
      }

      final res = await http.post(
        Uri.parse("$baseUrl/news/react"),
        headers: headers,
        body: jsonEncode({
          "user_id": userId,
          "news_id": newsId,
          "reaction_type": type
        }),
      );

      final data = jsonDecode(res.body);
      return data;

    } catch (e) {
      return {
        "success": false,
        "error": "Reaction failed"
      };
    }
  }

  /* ===========================
     ADD COMMENT
  =========================== */
  static Future<Map<String, dynamic>> addComment(
      String newsId, String comment) async {
    try {
      if (userId == null) {
        return {"success": false, "error": "User not logged in"};
      }

      final res = await http.post(
        Uri.parse("$baseUrl/news/comment"),
        headers: headers,
        body: jsonEncode({
          "user_id": userId,
          "news_id": newsId,
          "comment": comment
        }),
      );

      final data = jsonDecode(res.body);
      return data;

    } catch (e) {
      return {
        "success": false,
        "error": "Comment failed"
      };
    }
  }

  /* ===========================
     GET COMMENTS
  =========================== */
  static Future<List<dynamic>> getComments(String newsId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/news/$newsId/comments"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /* ===========================
     HEADERS
  =========================== */
  static Map<String, String> get headers {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String phone,
      String city,
      ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone_number": phone,
          "city": city
        }),
      );

      final data = jsonDecode(res.body);

      if (data["token"] != null) {
        await saveAuth(
          data["token"],
          data["data"]["user_id"],
        );
      }

      return data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /* ===========================
     LOGIN
  =========================== */
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["token"] != null) {
        await saveAuth(
          data["token"],
          data["data"]["user_id"],
        );// ✅ STORE USER ID
      }

      return data;
    } catch (e) {
      return {
        "success": false,
        "error": "Network error"
      };
    }
  }

  /* ===========================
     GET STOCKS
  =========================== */
  static Future<List<dynamic>> getStocks() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/stocks"),
        headers: headers,
      );

      final data = jsonDecode(res.body);

      return data["data"] ?? [];
    } catch (e) {
      return [];
    }
  }

  /* ===========================
     BUY / SELL TRADE
  =========================== */
  static Future<Map<String, dynamic>> trade(
      String symbol, int quantity, String type) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/trades"),
        headers: headers,
        body: jsonEncode({
          "symbol": symbol,
          "quantity": quantity,
          "trade_type": type,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        return {
          "success": false,
          "error": data["error"] ?? "Trade failed"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Trade failed: $e"
      };
    }
  }

  /* ===========================
     PORTFOLIO
  =========================== */
  static Future<List<dynamic>> getPortfolio() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/trades/portfolio"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /* ===========================
     WALLET
  =========================== */
  static Future<double> getWallet() async {
    try {
      if (userId == null) return 0;

      final res = await http.get(
        Uri.parse("$baseUrl/users/wallet/$userId"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Safe parsing
        final balance = data["data"]?["balance"];

        if (balance == null) return 0;

        return (balance is num)
            ? balance.toDouble()
            : double.tryParse(balance.toString()) ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static Future<List<dynamic>> getLeaderboard() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/users/leaderboard"),
        headers: headers,
      );

      final data = jsonDecode(res.body);
      return data["data"] ?? [];
    } catch (e) {
      return [];
    }
  }
}