// Import packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

//Import other project files
import 'components/widget_color.dart';
import 'components/termsofservice.dart';

// Main widget of TermsofServiceScreen
class TermsofServiceScreen extends StatefulWidget {
  const TermsofServiceScreen({Key? key}) : super(key: key);
  @override
  TermsofServiceScreenState createState() => TermsofServiceScreenState();
}

// Stare for TermsofServiceScreen
class TermsofServiceScreenState extends State<TermsofServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
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
                  data: terms,
                  styleSheet: getMarkdownStyleSheet(
                      commentColor: themeColor, fontSize: 16.0),
                ),
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/');
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
