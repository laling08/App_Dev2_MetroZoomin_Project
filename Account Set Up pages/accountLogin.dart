import 'package:flutter/material.dart';
import 'package:metrozoom/CreatePinScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountSetUpScreen(),
    );
  }
}

class AccountSetUpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Picture Placeholder
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  Positioned(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(Icons.edit, size: 15),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // Input Fields
              _buildTextField("Username"),
              _buildTextField("Full name"),
              _buildTextField("Date of birth", icon: Icons.calendar_today),
              _buildTextField("Email", icon: Icons.email),
              _buildTextField("Phone Number", icon: Icons.phone),

              _buildDropdown("Gender"),
              _buildTextField("Create Pin"),

              const SizedBox(height: 30),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreatePinScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Continue", style: TextStyle(color: Colors.white),),
              ),

              const SizedBox(height: 20),

              // Dots Indicator
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 8),
                  SizedBox(width: 5),
                  Icon(Icons.circle_outlined, size: 8),
                  SizedBox(width: 5),
                  Icon(Icons.circle_outlined, size: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(String label, {IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

Widget _buildDropdown(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<String>(
      items: ['Male', 'Female']
          .map((e) => DropdownMenuItem(child: Text(e), value: e))
          .toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
