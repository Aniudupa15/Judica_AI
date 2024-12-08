import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:judica/common_pages/slpash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? email;
  String? mobileNumber;
  String? dateOfBirth;
  String? address;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _requestPermissions();
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc.data()?['username'];
            email = userDoc.data()?['email'];
            mobileNumber = userDoc.data()?['Mobile Number'];
            dateOfBirth = userDoc.data()?['Date of Birth'];
            address = userDoc.data()?['Address'];
            imageUrl = userDoc.data()?['imageUrl'];
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> saveUserData(String field, String value) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.email)
            .update({field: value});

        setState(() {
          if (field == 'username') userName = value;
          if (field == 'email') email = value;
          if (field == 'Mobile Number') mobileNumber = value;
          if (field == 'Date of Birth') dateOfBirth = value;
          if (field == 'Address') address = value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
    }
  }

  Future<void> _showEditDialog(String title, String field, String initialValue) async {
    final TextEditingController controller = TextEditingController(text: initialValue);

    if (field == 'Date of Birth') {
      // Open a date picker for Date of Birth with custom colors
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              primaryColor: const Color.fromRGBO(255, 125, 41, 1), // Primary color for date selection
              hintColor: const Color.fromRGBO(255, 125, 41, 1), // Accent color for buttons
              buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary, // Button text theme
              ),
              colorScheme: const ColorScheme.dark(
                primary: Color.fromRGBO(255, 125, 41, 1), // Custom primary color
                onPrimary: Colors.white, // Text color for primary button
                onSurface: Colors.white, // Text color for surface (calendar days)
              ),
              dialogBackgroundColor: const Color.fromRGBO(250, 249, 246, 1), // Background color
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format the date
        saveUserData(field, controller.text);
        return;
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color.fromRGBO(250, 249, 246, 1), // Same background color as profile page
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $title',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color to match the profile
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Enter new $title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(255, 125, 41, 1), // Cancel button color
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          saveUserData(field, controller.text);
                        }
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 249, 246, 1),
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(2), // Adds space around the avatar for the border
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 125, 41, 1), // Border color
                        shape: BoxShape.circle, // Keeps the container circular
                        border: Border.all(
                          color: const Color.fromRGBO(255, 125, 41, 1), // Border color (change as needed)
                          width: 4, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 85, // Avatar radius
                        backgroundColor: Colors.transparent, // Transparent background inside the avatar
                        child:ClipOval(
                      child: imageUrl != null
                      ? Image.file(
                          File(imageUrl!),
                      fit: BoxFit.cover, // Ensure the image fits the circle properly
                      width: 170, // Adjust width to match radius
                      height: 170, // Adjust height to match radius
                    )
                        : Center( // Show a message when imageUrl is null
                    child: Text(
                    'Click to upload', // Message text
                    textAlign: TextAlign.center, // Center align the text
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          )

        ),
                    ),
                  ),


                  const SizedBox(height: 30),
                  // Editable fields using DialogBox
                  buildEditableField("Name", userName, 'username'),
                  const SizedBox(height: 15),
                  buildEditableField("Email", email, 'email'),
                  const SizedBox(height: 15),
                  buildEditableField("Mobile Number", mobileNumber, 'Mobile Number'),
                  const SizedBox(height: 15),
                  buildEditableField("Date of Birth", dateOfBirth, 'Date of Birth'),
                  const SizedBox(height: 15),
                  buildEditableField("Address", address, 'Address'),
                  const SizedBox(height: 30), // Space before logout button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(String title, String? value, String field) {
    return GestureDetector(
      onTap: () => _showEditDialog(title, field, value ?? ''),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromRGBO(255, 125, 41, 1),
            width: 2,
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Wrap the value with a Flexible widget to avoid overflow
            Flexible(
              child: Text(
                value ?? 'Not Available',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
