import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController(text: 'John Doe');
  final TextEditingController phoneController = TextEditingController(text: '+44 555 5555 55');
  final TextEditingController emailController = TextEditingController(text: 'example@example.com');
  final TextEditingController addressController = TextEditingController(text: '123 Main Street');
  final TextEditingController dobController = TextEditingController(text: '01/01/1990');

  bool pushNotifications = true;
  bool darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFF1DD1A1),
              Color(0xFF00D09E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Profile Picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage("lib/assets/profile.png"),
                ),
              ),

              SizedBox(height: 20),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.98, // rộng hơn một chút
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF1FFF3), // light green
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Username
                            TextFormField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Phone
                            TextFormField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: "Phone",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Email
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Address
                            TextFormField(
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: "Address",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

                            // Date of Birth
                            TextFormField(
                              controller: dobController,
                              decoration: InputDecoration(
                                labelText: "Date of Birth",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 25),

                            // Push Notifications
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Push Notifications',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Switch(
                                  value: pushNotifications,
                                  onChanged: (value) {
                                    setState(() {
                                      pushNotifications = value;
                                    });
                                  },
                                  activeColor: Color(0xFF1DD1A1),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            // Dark Theme
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dark Theme',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Switch(
                                  value: darkTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      darkTheme = value;
                                    });
                                  },
                                  activeColor: Color(0xFF1DD1A1),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),

                            // Update Button
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1DD1A1),
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
