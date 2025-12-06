import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/utils/urls.dart';
import 'reset_password_screen.dart';

class ForgotPasswordVerifyOtpScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordVerifyOtpScreen({super.key, this.email});

  static const String name = '/forgot-password-verify-otp';

  @override
  State<ForgotPasswordVerifyOtpScreen> createState() =>
      _ForgotPasswordVerifyOtpScreenState();
}

class _ForgotPasswordVerifyOtpScreenState
    extends State<ForgotPasswordVerifyOtpScreen> {
  final TextEditingController _otp = TextEditingController();
  bool _loading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final email = (widget.email ?? '').trim().toLowerCase();
    final otp = _otp.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      _showSnack('Email and OTP are required');
      return;
    }

    setState(() => _loading = true);
    try {
      // Try primary endpoint
      final urls = [
        '${Urls.recoverVerifyOtpUrlPrimary}/$email/$otp',
        '${Urls.recoverVerifyOtpUrlAlt}/$email/$otp',
      ];

      for (final url in urls) {
        final res = await http.get(Uri.parse(url));

        debugPrint(
            'URL: $url\nMethod: GET\nStatus Code: ${res.statusCode}\nBody: ${res.body}\n');

        if (res.statusCode == 200) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                initialEmail: email,
                initialOtp: otp,
              ),
            ),
          );
          return;
        }
      }

      _showSnack('Invalid OTP');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailText = widget.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (emailText.isNotEmpty)
              Text('OTP sent to: $emailText'),
            const SizedBox(height: 12),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter OTP'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyOtp,
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
