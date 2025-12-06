import 'package:flutter/material.dart';
import 'package:task_manager_app/ui/controllers/auth_controller.dart';
import 'package:task_manager_app/ui/screens/sign_in_screen.dart';

class TMAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TMAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = AuthController.userData;

    return AppBar(
      title: Text(user != null ? "${user.firstName} ${user.lastName}" : "Profile"),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await AuthController.clearUserData();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                SignInScreen.name,
                    (_) => false,
              );
            }
          },
        ),
      ],
    );
  }
}
