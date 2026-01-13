import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'type_culture_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void checkLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => TypeCultureScreen())
        );
      } else {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => LoginScreen())
        );
      }
    } catch (e) {
      // Si erreur, rediriger vers login
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => LoginScreen())
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () => checkLogin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "AgriAdvisor", 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Indicateur de chargement
          ],
        ),
      ),
    );
  }
}
