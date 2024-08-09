// Import packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Import other project files
import 'components/widget_color.dart';
import 'components/termsofservice.dart';

// Main widget of PrivaryPolicyScreen
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);
  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

// State for PrivacyPolicyScreen
class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            Image.asset(
              'assets/marmelo_logo.png',
              width: 80,
            ),
            const SizedBox(width: 20),
            const Text(
              'Marmelo Academy',
              style: TextStyle(
                  fontSize: 18, color: themeColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                MarkdownBody(
                  data: privacyPolicy,
                  styleSheet: getMarkdownStyleSheet(
                      commentColor: themeColor, fontSize: 16.0),
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/'); // Navigate to homepage screen
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Return to Home Page',
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
    );
  }
}
