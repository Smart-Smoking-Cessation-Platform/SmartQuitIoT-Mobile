import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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

              SizedBox(height: 5),

              // Profile Picture
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
                  backgroundColor: Colors.transparent, 
                ),
              ),

              SizedBox(height: 20),


              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 0), // kéo lên sát avatar
                    decoration: BoxDecoration(
                      color: Color(0xFFF1FFF3), // light green
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Name and Status
                          Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'I Am Gey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Menu Items
                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            color: Color(0xFF0984E3),
                            onTap: () {},
                          ),

                          SizedBox(height: 12),

                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline,
                            title: 'My Coach',
                            color: Color(0xFF0984E3),
                            onTap: () {},
                          ),

                          SizedBox(height: 12),

                          _buildMenuItem(
                            context,
                            icon: Icons.settings_outlined,
                            title: 'Setting',
                            color: Color(0xFF0984E3),
                            onTap: () {},
                          ),

                          SizedBox(height: 12),

                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline,
                            title: 'Help',
                            color: Color(0xFF0984E3),
                            onTap: () {},
                          ),

                          SizedBox(height: 12),

                          _buildMenuItem(
                            context,
                            icon: Icons.logout,
                            title: 'Logout',
                            color: Color(0xFF0984E3),
                            onTap: () {},
                          ),

                          SizedBox(height: 20),
                        ],
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

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
        required String title,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
