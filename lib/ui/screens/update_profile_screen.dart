import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager_app/data/models/user_model.dart';
import 'package:task_manager_app/data/service/network_caller.dart';
import 'package:task_manager_app/data/utils/urls.dart';
import 'package:task_manager_app/ui/controllers/auth_controller.dart';
import 'package:task_manager_app/ui/widgets/centered_circular_progress.dart';
import 'package:task_manager_app/ui/widgets/screen_background.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import 'package:task_manager_app/ui/widgets/tm_app_bar.dart';

import '../widgets/photo_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  static const String name = '/update-profile';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _firstNameTEC = TextEditingController();
  final TextEditingController _lastNameTEC = TextEditingController();
  final TextEditingController _mobileTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();

    final UserModel user = AuthController.userData!;

    _emailTEC.text = user.email;
    _firstNameTEC.text = user.firstName;
    _lastNameTEC.text = user.lastName;
    _mobileTEC.text = user.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TMAppBar(),   // FIXED: removed invalid parameter
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                /// IMAGE PICKER
                GestureDetector(
                  onTap: _pickImage,
                  child: PhotoPicker(pickedImage: _pickedImage),
                ),

                /// EMAIL (LOCKED)
                TextFormField(
                  enabled: false,
                  controller: _emailTEC,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),

                /// FIRST NAME
                TextFormField(
                  controller: _firstNameTEC,
                  decoration: const InputDecoration(hintText: 'First Name'),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter first name' : null,
                ),

                /// LAST NAME
                TextFormField(
                  controller: _lastNameTEC,
                  decoration: const InputDecoration(hintText: 'Last Name'),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter last name' : null,
                ),

                /// MOBILE
                TextFormField(
                  controller: _mobileTEC,
                  decoration: const InputDecoration(hintText: 'Mobile'),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Enter mobile number' : null,
                ),

                /// PASSWORD (OPTIONAL)
                TextFormField(
                  obscureText: true,
                  controller: _passwordTEC,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator: (value) {
                    if (value!.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                /// SUBMIT BUTTON
                Visibility(
                  visible: !_updateInProgress,
                  replacement: const CenteredCircularProgress(),
                  child: FilledButton(
                    onPressed: _onTapUpdateButton,
                    child: const Icon(Icons.arrow_circle_right_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      _pickedImage = image;
      setState(() {});
    }
  }

  void _onTapUpdateButton() {
    if (_formKey.currentState!.validate()) {
      _updateProfile();
    }
  }

  Future<void> _updateProfile() async {
    _updateInProgress = true;
    setState(() {});

    final Map<String, dynamic> body = {
      "email": _emailTEC.text.trim(),
      "firstName": _firstNameTEC.text.trim(),
      "lastName": _lastNameTEC.text.trim(),
      "mobile": _mobileTEC.text.trim(),
    };

    /// Add password only if user typed it
    if (_passwordTEC.text.isNotEmpty) {
      body['password'] = _passwordTEC.text;
    }

    /// Add image if selected
    if (_pickedImage != null) {
      Uint8List bytes = await _pickedImage!.readAsBytes();
      body['photo'] = base64Encode(bytes);
    }

    final NetworkResponse response =
    await NetworkCaller.postRequest(Urls.updateProfileUrl, body: body);

    _updateInProgress = false;
    setState(() {});

    if (!response.isSuccess) {
      showSnackBarMessage(context, response.errorMessage);
      return;
    }

    /// Update local user data
    final updated = {
      "_id": AuthController.userData!.id,
      ...body,
    };

    await AuthController.updateUserData(UserModel.fromJson(updated));

    showSnackBarMessage(context, 'Profile updated successfully!');
  }
}
