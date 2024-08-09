// Import packages
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Import other project files
import 'components/widget_color.dart';
import 'components/entrance_message.dart';

// Main EntranceScreen widget of entrance screen.
class EntranceScreen extends StatelessWidget {
  const EntranceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Entrance',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor, 
        surfaceTintColor: backgroundColor,
      ),
      body: PageView(
        children: [
          // First page container
          Container(
            color: backgroundColor,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    // Title of first page
                    const Text(
                      'Addmision Rules',
                      style: TextStyle(
                        fontSize: 24,
                        color: themeColor,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Container for displaying admission policy mission
                    Container(
                      width: 800, 
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: MarkdownBody(
                          data: addmisionPolicyMission,
                          styleSheet: getMarkdownStyleSheet(
                              commentColor: themeColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container for displaying admission policy introduction
                    Container(
                      width: 800,
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: MarkdownBody(
                          data: addmisionPolicyIntroduction,
                          styleSheet: getMarkdownStyleSheet(
                              commentColor: themeColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container for displaying admission policy user
                    Container(
                      width: 800, 
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: MarkdownBody(
                          data: addmisionPolicyUser,
                          styleSheet: getMarkdownStyleSheet(
                              commentColor: themeColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container for displaying admission policy goal
                    Container(
                      width: 800, 
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: MarkdownBody(
                          data: addmisionPolicyGoal,
                          styleSheet: getMarkdownStyleSheet(
                              commentColor: themeColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Image widget to display an image asset
                    Image.asset(
                      'assets/entrance_1.png', 
                      width: 240,
                    ),
                    const SizedBox(height: 40),
                    // Button to navigate to profile edit screen
                    ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile_edit'); // Navigate to profile edit screen
                    },
                    child: const Text('Next'),
                  ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Second page container
          Container(
            color: backgroundColor,
            child: SingleChildScrollView(
                child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const SizedBox(height: 20),
                  // Title of second page
                  const Text(
                    'Curriculum',
                    style: TextStyle(
                      fontSize: 24,
                      color: themeColor,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Widget of flowchart of curriculm
                  Image.asset(
                      'assets/curriculum.png', 
                      width: 700,
                    ),
                  const SizedBox(height: 40),
                  // Button to navigate to profile edit screen
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile_edit'); // Navigate to profile edit screen
                    },
                    child: const Text('Next'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
