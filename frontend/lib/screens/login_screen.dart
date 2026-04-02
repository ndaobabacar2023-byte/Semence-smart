import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      var response = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      if (response['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(
              nom: response['user']['nom'],
              prenom: response['user']['prenom'],
              role: response['user']['role'],
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "❌ Erreur connexion",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  String? emailValidator(String? v) {
    if (v == null || v.isEmpty) return "Email obligatoire";
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Mot de passe obligatoire";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(Icons.lock, color: Colors.white, size: 80),

                        SizedBox(height: 20),

                        Text("Connexion",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          validator: emailValidator,
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          validator: passwordValidator,
                        ),

                        SizedBox(height: 30),

                        loading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text("SE CONNECTER",
                                    style: TextStyle(color: Colors.white)),
                              ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RegisterScreen()),
                            );
                          },
                          child: Text("Créer un compte",
                              style:
                                  TextStyle(color: Colors.greenAccent)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
