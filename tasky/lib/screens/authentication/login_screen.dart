import 'package:flutter/material.dart';
import 'package:tasky/services/auth.dart';
import 'package:tasky/screens/wrapper.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // attach the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => email = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator:
                    (val) =>
                        val != null && val.length < 6
                            ? 'Password must be 6+ chars'
                            : null,
                onChanged: (val) => setState(() => password = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.signInWithEmailAndPassword(
                      email,
                      password,
                    );
                    if (result == null) {
                      setState(
                        () =>
                            error = 'Could not sign in with those credentials',
                      );
                    } else {
                      setState(() => error = '');
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Wrapper()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                child: Text("Login"),
              ),
              SizedBox(height: 12),
              // 👇 Show error if exists
              Text(error, style: TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text("Go to Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
