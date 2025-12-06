import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/utils/urls.dart';
import 'sign_in_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialOtp;

  const ResetPasswordScreen({super.key, this.initialEmail, this.initialOtp});

  static const String name = '/reset-password';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _email.text = widget.initialEmail!;
    }
    if (widget.initialOtp != null) {
      _otp.text = widget.initialOtp!;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    final email = _email.text.trim().toLowerCase();
    final otp   = _otp.text.trim();
    final pass  = _newPassword.text.trim();
    final confirm = _confirmPassword.text.trim();

    if ([email, otp, pass, confirm].any((e) => e.isEmpty)) {
      _showSnack('All fields are required');
      return;
    }

    if (pass != confirm) {
      _showSnack('Passwords do not match');
      return;
    }

    setState(() => _loading = true);
    try {
      final body = {
        "email": email,
        "OTP": otp,
        "password": pass,
      };

      final url = Urls.recoverResetPasswordUrl;
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint(
          'URL: $url\nMethod: POST\nBody: $body\nStatus Code: ${res.statusCode}\nBody: ${res.body}\n');

      if (res.statusCode == 200) {
        _showSnack('Password changed successfully');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
              (_) => false,
        );
      } else {
        _showSnack('Reset failed');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otp,
              decoration: const InputDecoration(hintText: 'OTP'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Confirm Password'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _resetPassword,
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
