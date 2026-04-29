import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => loading = true);

      var response = await ApiService.register(
        nomController.text,
        prenomController.text,
        emailController.text,
        passwordController.text,
        telephoneController.text,
        role,
      );

      setState(() => loading = false);

      print("RESPONSE: $response");

      if (response != null && response['token'] != null) {
        Fluttertoast.showToast(
          msg: "✅ Inscription réussie",
          backgroundColor: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "❌ Erreur inscription",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
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
                        Icon(Icons.person_add,
                            color: Colors.white, size: 70),

                        SizedBox(height: 20),

                        Text("Inscription",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 20),

                        // NOM
                        TextFormField(
                          controller: nomController,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Nom", Icons.person),
                          validator: (value) =>
                              value!.isEmpty ? "Champ obligatoire" : null,
                        ),

                        SizedBox(height: 15),

                        // PRENOM
                        TextFormField(
                          controller: prenomController,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Prénom", Icons.person_outline),
                          validator: (value) =>
                              value!.isEmpty ? "Champ obligatoire" : null,
                        ),

                        SizedBox(height: 15),

                        // EMAIL
                        TextFormField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Email", Icons.email),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email requis";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15),

                        // TELEPHONE
                        TextFormField(
                          controller: telephoneController,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Téléphone", Icons.phone),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Téléphone requis";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 15),

                        // PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Mot de passe", Icons.lock),
                          validator: (value) =>
                              value!.length < 6 ? "Min 6 caractères" : null,
                        ),

                        SizedBox(height: 20),

                        // ROLE - SEULEMENT AGRICULTEUR ET TECHNICIEN
                        DropdownButtonFormField<String>(
                          value: role,
                          dropdownColor: Colors.black,
                          style: TextStyle(color: Colors.white),
                          decoration: inputStyle("Rôle", Icons.group),
                          items: [
                            DropdownMenuItem(
                                value: 'agriculteur',
                                child: Text('Agriculteur')),
                            DropdownMenuItem(
                                value: 'technicien',
                                child: Text('Technicien')),
                            // Admin supprimé - accessible uniquement par base de données
                          ],
                          onChanged: (v) {
                            setState(() => role = v!);
                          },
                        ),

                        SizedBox(height: 30),

                        loading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: Text("S'INSCRIRE",
                                    style: TextStyle(color: Colors.white)),
                              ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginScreen()),
                            );
                          },
                          child: Text("Se connecter",
                              style: TextStyle(color: Colors.greenAccent)),
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