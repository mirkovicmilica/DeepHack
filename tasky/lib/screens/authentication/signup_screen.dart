import 'package:flutter/material.dart';
import 'package:tasky/services/auth.dart';
import 'package:tasky/screens/wrapper.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  String name = '';
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name Field
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter your name' : null,
                onChanged: (val) => setState(() => name = val),
              ),
              // Email Field
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator:
                    (val) =>
                        val == null || !val.contains('@')
                            ? 'Enter a valid email'
                            : null,
                onChanged: (val) => setState(() => email = val),
              ),
              // Password Field
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator:
                    (val) =>
                        val != null && val.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                onChanged: (val) => setState(() => password = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.registerWithEmailAndPassword(
                      email,
                      password,
                    );
                    if (result == null) {
                      setState(() => error = 'Registration failed');
                    } else {
                      print("registered: ${result.uid}");

                      // Remove all routes and let Wrapper handle navigation
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Wrapper()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                child: Text("Sign Up"),
              ),
              SizedBox(height: 12),
              Text(error, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
