import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

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
      FocusScope.of(context).unfocus();
      setState(() => loading = true);

      print("🔐 Tentative de connexion pour: ${emailController.text}");

      var response = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      print("📊 Réponse login: $response");

      if (response['token'] != null) {
        // Récupération des informations utilisateur
        String nom = response['user']['nom'];
        String prenom = response['user']['prenom'];
        String role = response['user']['role'];

        Fluttertoast.showToast(
          msg: "✅ Connexion réussie !",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
        );

        // Redirection vers WelcomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WelcomeScreen(
              nom: nom,
              prenom: prenom,
              role: role,
            ),
          ),
        );
      } else {
        String errorMsg = response['error'] ?? 
                         response['message'] ?? 
                         'Erreur lors de la connexion';
        
        Fluttertoast.showToast(
          msg: "❌ $errorMsg",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  String? emailValidator(String? v) {
    if (v == null || v.isEmpty) return "Email obligatoire";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v)) return "Format email invalide";
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Mot de passe obligatoire";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espace en haut
              SizedBox(height: 40),
              
              // Logo avec image
              Container(
                width: 120,
                height: 120,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/images/logo.png', // Chemin de votre image de logo
                    fit: BoxFit.contain,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si l'image n'est pas trouvée
                      return Container(
                        color: Colors.green,
                        child: Icon(
                          Icons.agriculture,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Titre principal
              Text(
                "Bienvenue à SemenceSmart",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 9, 225, 20),
                ),
                textAlign: TextAlign.center,
              ),
              
              // Sous-titre
              SizedBox(height: 10),
              Text(
                "Connectez-vous à votre compte",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Champ Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: emailValidator,
              ),
              SizedBox(height: 20),

              // Champ Mot de passe
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                obscureText: obscurePassword,
                validator: passwordValidator,
              ),
              SizedBox(height: 30),

              // Bouton de connexion
              loading
                  ? Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 17, 236, 28),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "SE CONNECTER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              SizedBox(height: 20),

              // Lien d'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Pas encore de compte ? ",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Inscrivez-vous",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 12, 245, 24),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}