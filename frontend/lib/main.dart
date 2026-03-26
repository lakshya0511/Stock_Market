import 'package:flutter/material.dart';
import 'package:virtual_trading_app/screens/authentication/auth_wrapper.dart';
import 'package:virtual_trading_app/screens/authentication/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading App',

      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Color(0xFF121212),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),

      home: AuthWrapper(),
    );
  }
}