import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_manager_app/data/models/user_model.dart';
import 'package:task_manager_app/data/service/network_caller.dart';
import 'package:task_manager_app/data/utils/urls.dart';
import 'package:task_manager_app/ui/controllers/auth_controller.dart';
import 'package:task_manager_app/ui/screens/forgot_password_email_screen.dart';
import 'package:task_manager_app/ui/screens/main_bottom_nav_holder_screen.dart';
import 'package:task_manager_app/ui/screens/sign_up_screen.dart';
import 'package:task_manager_app/ui/utils/asset_paths.dart';
import 'package:task_manager_app/ui/widgets/screen_background.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String name = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailTEC.dispose();
    _passwordTEC.dispose();
    super.dispose();
  }

  Future<void> _onTapSignIn() async {
    if (_isLoggingIn) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoggingIn = true);

    final Map<String, dynamic> body = {
      'email': _emailTEC.text.trim(),
      'password': _passwordTEC.text,
    };

    final NetworkResponse response =
    await NetworkCaller.postRequest(Urls.loginUrl, body: body);

    setState(() => _isLoggingIn = false);

    if (!response.isSuccess) {
      showSnackBarMessage(
        context,
        response.errorMessage,
      );
      return;
    }

    // SUCCESS: parse token + data
    final decoded = response.body as Map<String, dynamic>;
    final token = decoded['token'] ?? '';
    final userMap = decoded['data'] ?? {};

    if (token.isEmpty || userMap.isEmpty) {
      showSnackBarMessage(context, 'Invalid login response');
      return;
    }

    // Save token + user
    await AuthController.saveAccessToken(token);
    await AuthController.saveUserData(UserModel.fromJson(userMap));

    showSnackBarMessage(context, 'Login successful');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, MainBottomNavHolderScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SvgPicture.asset(AssetPaths.logo, width: 120),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailTEC,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordTEC,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoggingIn ? null : _onTapSignIn,
                      child: _isLoggingIn
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Sign In'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, ForgotPasswordEmailScreen.name),
                    child: const Text('Forgot password?'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, SignUpScreen.name),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
