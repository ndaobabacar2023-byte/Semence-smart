import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  String role = 'agriculteur';

  void register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() { 
        loading = true; 
      });

      print("🚀 Début de l'inscription...");
      print("📋 Rôle sélectionné: $role");

      // CORRECTION CRITIQUE: Ordre correct des paramètres
      var response = await ApiService.register(
        nomController.text.trim(),
        prenomController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),   // CORRECT: Mot de passe en 4ème
        telephoneController.text.trim(),  // CORRECT: Téléphone en 5ème
        role,
      );

      setState(() { 
        loading = false; 
      });

      print("📊 Réponse API: $response");

      if (response['token'] != null) {
        Fluttertoast.showToast(
          msg: "🎉 Inscription réussie !",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
        );
        
        // Redirection vers l'écran de connexion
        await Future.delayed(Duration(milliseconds: 1500));
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        // Afficher le message d'erreur approprié
        String errorMessage = response['message'] ?? 
                             response['error'] ?? 
                             'Une erreur est survenue lors de l\'inscription';
        
        Fluttertoast.showToast(
          msg: "❌ $errorMessage",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
        
        // Afficher plus de détails en mode debug
        print("❌ Erreur détaillée: $response");
      }
    }
  }

  // Validateurs
  String? nomValidator(String? v) {
    if (v == null || v.isEmpty) return "Le nom est obligatoire";
    return null;
  }

  String? prenomValidator(String? v) {
    if (v == null || v.isEmpty) return "Le prénom est obligatoire";
    return null;
  }

  String? emailValidator(String? v) {
    if (role == 'admin' || role == 'technicien') {
      if (v == null || v.isEmpty) return "Email obligatoire pour ce rôle";
      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!regex.hasMatch(v)) return "Format email invalide";
    }
    return null;
  }

  String? telephoneValidator(String? v) {
    if (role == 'agriculteur') {
      if (v == null || v.isEmpty) return "Téléphone obligatoire pour agriculteur";
      if (v.length < 8) return "Numéro trop court";
    }
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Le mot de passe est obligatoire";
    if (v.length < 6) return "Minimum 6 caractères";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Image
              SizedBox(height: 10),
              Icon(
                Icons.person_add,
                size: 80,
                color: Colors.green[700],
              ),
              SizedBox(height: 20),
              Text(
                "Créer un compte",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Champ Nom
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(
                  labelText: "Nom *",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: nomValidator,
              ),
              SizedBox(height: 15),

              // Champ Prénom
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(
                  labelText: "Prénom *",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: prenomValidator,
              ),
              SizedBox(height: 15),

              // Champ Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email ${(role == 'admin' || role == 'technicien') ? '*' : ''}",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: emailValidator,
              ),
              SizedBox(height: 15),

              // Champ Téléphone (conditionnel)
              if (role == 'agriculteur')
                Column(
                  children: [
                    TextFormField(
                      controller: telephoneController,
                      decoration: InputDecoration(
                        labelText: "Téléphone *",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: telephoneValidator,
                    ),
                    SizedBox(height: 15),
                  ],
                ),

              // Champ Mot de passe
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Mot de passe *",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
                validator: passwordValidator,
              ),
              SizedBox(height: 20),

              // Sélecteur de rôle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: role,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                    items: [
                      DropdownMenuItem(
                        value: 'agriculteur',
                        child: Row(
                          children: [
                            Icon(Icons.agriculture, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Agriculteur'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'technicien',
                        child: Row(
                          children: [
                            Icon(Icons.engineering, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Technicien'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Administrateur'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          role = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Bouton d'inscription
              loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "S'INSCRIRE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              SizedBox(height: 20),

              // Lien vers connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous avez déjà un compte ? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Connectez-vous",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
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