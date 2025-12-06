import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/utils/urls.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String name = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName  = TextEditingController();
  final TextEditingController _email     = TextEditingController();
  final TextEditingController _mobile    = TextEditingController();
  final TextEditingController _password  = TextEditingController();

  bool _loading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    final email    = _email.text.trim().toLowerCase();
    final first    = _firstName.text.trim();
    final last     = _lastName.text.trim();
    final mobile   = _mobile.text.trim();
    final password = _password.text.trim();

    if ([email, first, last, mobile, password].any((e) => e.isEmpty)) {
      _showSnack('All fields are required');
      return;
    }

    setState(() => _loading = true);
    try {
      final body = {
        "email": email,
        "firstName": first,
        "lastName": last,
        "mobile": mobile,
        "password": password,
      };

      final url = Urls.registrationUrl;
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint(
          'URL: $url\nMethod: POST\nBody: $body\nStatus Code: ${res.statusCode}\nBody: ${res.body}\n');

      if (res.statusCode == 200) {
        _showSnack('Successfully created account');
        if (!mounted) return;
        Navigator.pop(context); // back to Sign In
      } else {
        _showSnack('Registration failed');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _firstName,
              decoration: const InputDecoration(hintText: 'First name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastName,
              decoration: const InputDecoration(hintText: 'Last name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Mobile'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSignUp,
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
