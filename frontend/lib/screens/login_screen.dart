import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'type_culture_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() { loading = true; });

      var response = await ApiService.login(emailController.text.trim(), passwordController.text.trim());

      setState(() { loading = false; });

      if (response['token'] != null) {
        Fluttertoast.showToast(msg: response['message'] ?? "Connexion réussie");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TypeCultureScreen()));
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? "Erreur connexion");
      }
    }
  }

  String? emailValidator(String? v) {
    if (v == null || v.isEmpty) return "Obligatoire";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v)) return "Email invalide";
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Obligatoire";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: emailValidator,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: passwordValidator,
              ),
              SizedBox(height: 20),
              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: login, child: Text("Se connecter")),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                },
                child: Text("Pas encore de compte ? Inscrivez-vous")
              )
            ],
          ),
        ),
      ),
    );
  }
}
