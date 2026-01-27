import 'package:flutter/material.dart';

class TechnicienHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tableau de bord Technicien")),
      body: Center(
        child: Text(
          "Bienvenue Technicien !",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
