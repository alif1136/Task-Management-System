import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/utils/urls.dart';
import 'forgot_password_verify_otp_screen.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  static const String name = '/forgot-password-email';

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _email = TextEditingController();
  bool _loading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final email = _email.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showSnack('Email is required');
      return;
    }

    setState(() => _loading = true);
    try {
      final url = '${Urls.recoverVerifyEmailUrl}/$email';
      final res = await http.get(Uri.parse(url));

      debugPrint(
          'URL: $url\nMethod: GET\nStatus Code: ${res.statusCode}\nBody: ${res.body}\n');

      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotPasswordVerifyOtpScreen(email: email),
          ),
        );
      } else {
        _showSnack('Failed to send OTP');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
