// Import packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import '../components/custom_button.dart';
import '../components/custom_input_field.dart';
import 'components/user_info.dart';
import 'components/widget_color.dart';
import 'components/termsofservice.dart';


// Main widget of RegisterScreen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

// State for RegisterScreen
class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _acceptterms = false;
  final String _terms = terms;
  String _name = '';
  bool _isLoading = false;
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUserData(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _name,
        'email': user.email,
        'skill': UserProfile.selectedSkill,
        'interests': UserProfile.selectedInterests,
        'chat_id': ''
      });
      if(kDebugMode){
        print('User data saved successfully');
      }
    } catch (e) {
      if(kDebugMode){
        print('Failed to save user data: $e');
      }
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        await _saveUserData(userCredential.user!);
        if (mounted) {
          if(kDebugMode){
            print('Registered user: ${userCredential.user?.email}');
          }
          UserProfile.islogin = true;
          Navigator.pushNamed(context, '/profile_edit');
        }
      } catch (e) {
        if(kDebugMode){
          print(e);
        }
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to Sign Up';
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms of Service',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeColor,
            ),
          ),
          backgroundColor: backgroundColor,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: _terms,
                    styleSheet: getMarkdownStyleSheet(
                        commentColor: themeColor, fontSize: 16.0),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptterms,
                        fillColor: WidgetStateProperty.all(backgroundColor),
                        checkColor: themeColor,
                        side: const BorderSide(color: themeColor, width: 2.0),
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptterms = value ?? false;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      const Text(
                        'Accept Terms',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(themeColor),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: messageColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/marmelo_logo.png',
                    width: 600,
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: 'Your Name',
                    initialValue: '',
                    onChanged: (value) => _name = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Input your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: 'Your Email',
                    initialValue: '',
                    onChanged: (value) => _email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Input Your Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: 'Password',
                    initialValue: '',
                    isPassword: true,
                    onChanged: (value) => _password = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: 'Verify Password',
                    initialValue: '',
                    isPassword: true,
                    onChanged: (value) => value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Velify Your Password';
                      }
                      if (value != _password) {
                        return 'Password was not Matched';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        )
                      : CustomButton(
                          isEnabled: false,
                          text: 'Create Account',
                          onPressed: _acceptterms ? _register : null,
                        ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _showDialog(context);
                    },
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: themeColor,
                              fontFamily: 'Inter',
                              decoration: TextDecoration.underline,
                              decorationColor: themeColor,
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
