import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:judica/Judge/judge_home.dart';
import 'package:judica/police/police_home.dart';
import 'package:judica/common_pages/register.dart';
import 'package:judica/user/user_home.dart';
import 'package:judica/common_pages/forgot_password.dart';
// Ensure this is implemented
import '../auth/auth_services.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isDialogVisible = false;
  bool _isPasswordVisible = false; // Added for password visibility toggle
  bool _isLoading = false; // For Google sign-in loading

  // Login function
  Future<void> login() async {
    if (!_validateFields()) return;

    try {
      showLoadingDialog();
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user?.email)
          .get();

      if (mounted) Navigator.pop(context);

      if (userDoc.exists && userDoc.data() != null) {
        String role = userDoc.get('role') ?? '';
        _navigateToHome(role);
      } else {
        _displayMessageToUser('User role not found.');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _displayMessageToUser('Error: ${e.toString()}');
    }
  }

  bool _validateFields() {
    if (emailController.text.trim().isEmpty) {
      _displayMessageToUser('Email cannot be empty');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _displayMessageToUser('Password cannot be empty');
      return false;
    }
    return true;
  }

  void _navigateToHome(String role) {
    Widget? homePage;
    switch (role) {
      case 'Citizen':
        homePage = const UserHome();
        break;
      case 'Police':
        homePage = const PoliceHome();
        break;
      case 'Judge':
        homePage = const AdvocateHome();
        break;
      default:
        _displayMessageToUser('User role not found.');
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => homePage!),
    );
  }

  void showLoadingDialog() {
    if (isDialogVisible) return;

    isDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitCircle(
                    color: Color.fromRGBO(251, 146, 60, 1),
                    size: 50.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please wait...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => isDialogVisible = false);
  }

  void _displayMessageToUser(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      suffixIcon: Icon(icon),
      hintText: hintText,
      enabledBorder: _buildBorder(),
      focusedBorder: _buildBorder(),
    );
  }

  OutlineInputBorder _buildBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Judica"),
        backgroundColor: const Color.fromRGBO(255, 165, 89, 1),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/Background.jpg', fit: BoxFit.cover),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 150.0, left: 10, right: 10),
            child: Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 20),
                _buildTextField(emailController, 'Email', Icons.person_outline),
                const SizedBox(height: 20),
                _buildTextField(passwordController, 'Password', Icons.lock_outline, true),
                _buildForgotPassword(),
                const SizedBox(height: 20),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildSocialLogin(),
                const SizedBox(height: 20),
                _buildRegisterLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 238, 169, 1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 100),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      IconData icon, [bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText && !_isPasswordVisible, // Use the visibility state
        decoration: InputDecoration(
          suffixIcon: obscureText
              ? IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : Icon(icon),
          hintText: hintText,
          enabledBorder: _buildBorder(),
          focusedBorder: _buildBorder(),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        );
      },
      child: const Align(
        alignment: Alignment.centerRight,
        child: Text("Forgot Password?", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(251, 146, 60, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Log In →', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const Text(
          'Or continue with',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  _isLoading = true;
                });
                await AuthServices().signInWithGoogle(context);
                setState(() {
                  _isLoading = false;
                });
              },
              child: _isLoading
                  ? const SpinKitCircle(
                color: Color.fromRGBO(251, 146, 60, 1),
                size: 50.0,
              )
                  : Image.asset('assets/google.png', width: 50),
            ),
            const SizedBox(width: 25),
            GestureDetector(
              onTap: () {
                // Implement Apple sign-in logic
              },
              child: Image.asset('assets/apple.png', width: 50),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
