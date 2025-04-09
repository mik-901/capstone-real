import 'package:flutter/material.dart';
import 'home.dart'; // Import your home page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/food.jpg'), // Your background image
            fit: BoxFit.cover, // Or BoxFit.fill, BoxFit.contain, etc.
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85), // Slightly increased opacity for contrast
                borderRadius: BorderRadius.circular(15), // Rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // App Title
                    const Text(
                      'Hostel Mess App',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Username TextField
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person), // Icon inside TextField
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock), // Icon inside TextField
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        backgroundColor: Colors.green, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        elevation: 5, // Shadow effect
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Validation passed, proceed to login
                          if (_usernameController.text == '1' && _passwordController.text == '1') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  username: _usernameController.text,
                                  rollNumber: '12345',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid credentials')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Forgot Password Link (optional)
                    TextButton(
                      onPressed: () {
                        // Optional: Navigate to Forgot Password page
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}