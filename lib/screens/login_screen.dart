// Import packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Import other project files
import '../components/custom_button.dart';
import '../components/custom_input_field.dart';
import 'components/user_info.dart';
import 'components/widget_color.dart';
import 'components/termsofservice.dart';

// Main LoginScreen widget
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

// State for LoginScreen
class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to login using firebase authentication
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        if (mounted) {
          if (kDebugMode) {
            print('Logged in user: ${userCredential.user?.email}');
          }
          await _navigateAfterLogin(userCredential.user!);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Login was failed. Please check your ID and password';
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

  // Function to login with google account using firebase authentication
  Future<void> _googleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      GoogleAuthProvider authProvider = GoogleAuthProvider();
      UserCredential userCredential = await _auth.signInWithPopup(authProvider);

      if (userCredential.user != null) {
        if (kDebugMode) {
          print('Google logged in user: ${userCredential.user?.email}');
        }
        await _navigateAfterLogin(userCredential.user!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google sign-in: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to log in with your Google Account. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to determine if it is the user's first login and navigate to either the profile edit screen or the entrance screen accordingly after login
  Future<void> _navigateAfterLogin(User user) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        UserProfile.islogin = true;
        if (mounted) {
          Navigator.pushReplacementNamed(
              context, '/profile_edit'); // Navigate to profile edit screen
        }
      } else {
        UserProfile.islogin = true;
        if (mounted) {
          Navigator.pushReplacementNamed(context,
              '/entrance_screen'); // Navigate to entrance screen if it is the user's first login.
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context,
            '/login_screen'); // Navigate to login screen if login process was failed
      }
    }
  }

  // Function to show Privacy policy as dialog
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Privacy Policy',
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
                    data: privacyPolicy,
                    styleSheet: getMarkdownStyleSheet(
                        commentColor: themeColor, fontSize: 14),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const Text('Match on the web, co-create your dream service',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeColor,
                      )),
                  const SizedBox(height: 90),
                  CustomInputField(
                    hintText: 'ID',
                    initialValue: '',
                    onChanged: (value) => _email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Input your ID';
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
                        return 'Input your password';
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
                      ? const SizedBox(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                        )
                      : CustomButton(
                          isEnabled: true,
                          text: 'Log in',
                          onPressed: _login,
                        ),
                  const SizedBox(height: 20),
                  const Text(
                    'or',
                    style: TextStyle(color: themeColor),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _googleSignIn();
                    },
                    child: Image.asset(
                      'assets/Google_login.png',
                      width: 160,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Disabled for debugging in the actual environment
                      Navigator.pushNamed(
                          context, '/register'); // Navigate to register screen
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: themeColor,
                          decoration: TextDecoration.underline,
                          decorationColor: themeColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      _showDialog(context);
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: themeColor,
                          decoration: TextDecoration.underline,
                          decorationColor: themeColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
