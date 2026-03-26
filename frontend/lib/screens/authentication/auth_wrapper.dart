import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home.dart';
import 'login.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  void checkAuth() async {
    bool loggedIn = false;

    try {
      loggedIn = await ApiService.loadAuth();
    } catch (e) {
      loggedIn = false;
    }

    if (!mounted) return;

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn ? HomeScreen() : LoginScreen();
  }
}