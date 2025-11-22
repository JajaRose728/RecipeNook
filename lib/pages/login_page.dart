import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'home_page.dart';

// --- COLORS ---
const Color _colorCreamBackground = Color(0xFFF0D597);
const Color _colorCardBeige = Color(0xFFE9DDCB);
const Color _colorDarkGreen = Color(0xFF4F6D44);
const Color _colorButtonGreen = Color(0xFFA8C67B);
const Color _colorInputText = Color(0xFF6A5A69);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool loading = false;

  void login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter username and password"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() => loading = true);

    try {
      await _authService.login(username, password);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(currentUsername: username)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => loading = false);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return Container(
      height: 60,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: _colorInputText, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          labelText: labelText,
          labelStyle: TextStyle(color: _colorInputText.withOpacity(0.7), fontWeight: FontWeight.w500),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _colorInputText.withOpacity(0.4), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _colorInputText.withOpacity(0.4), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _colorDarkGreen, width: 2.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 400 ? 400.0 : screenWidth * 0.85;

    return Scaffold(
      backgroundColor: _colorCreamBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                decoration: BoxDecoration(
                  color: _colorCardBeige,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Logo Image ---
                    // Logo
                    Image.asset(
                      'assets/logo.png',
                      height: 160,  // Bigger logo
                      width: 160,   // Maintain square aspect
                    ),
                    const SizedBox(height: 12), // Reduced spacing to title

// Title
                    const Text(
                      "RecipeNook",
                      style: TextStyle(
                        fontFamily: 'Cookie',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _colorDarkGreen,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Username & Password Fields
                    _buildInputField(controller: _usernameController, labelText: "Username"),
                    const SizedBox(height: 18),
                    _buildInputField(controller: _passwordController, labelText: "Password", obscureText: true),
                    const SizedBox(height: 36),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorButtonGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 6,
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            : const Text(
                          "Login",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage()));
                        }
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: _colorInputText.withOpacity(0.9),
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
