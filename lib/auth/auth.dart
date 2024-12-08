import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:judica/Judge/judge_home.dart';
import 'package:judica/police/police_home.dart';
import '../common_pages/slpash_screen.dart';
import '../user/user_home.dart'; // Import your splash screen here

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  Future<String> getUserRole(String userEmail) async {
    try {
      DocumentSnapshot userRoleDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get();
      return userRoleDoc['role'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user role: $e');
      }
      return '';
    }
  }

  Future<Widget> getUserHomePage(User? user) async {
    if (user == null) {
      return const SplashScreen(); // Redirect to SplashScreen if the user is not logged in
    }

    String role = await getUserRole(user.email!);

    return switch (role) {
      'Citizen' => const UserHome(),
      'Police' => const PoliceHome(),
      'Judge' => const AdvocateHome(),
      _ => const SplashScreen() // Redirect to SplashScreen if the role is undefined
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          }

          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<Widget>(
              future: getUserHomePage(snapshot.data),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching user role'));
                }
                return snapshot.data ?? const SplashScreen();
              },
            );
          } else {
            return const SplashScreen(); // Show SplashScreen if the user is not authenticated
          }
        },
      ),
    );
  }
}
