// Import dart libararies
import 'dart:math';

// Import packages
import 'package:flutter/material.dart';

// Import other project files
import 'components/widget_color.dart';

// Main HomePageScreen widget
class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key}) : super(key: key);
  @override
  HomePageScreenState createState() => HomePageScreenState();
}

// State for HomePageScren
class HomePageScreenState extends State<HomePageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int ballCount = 6;
  final List<Color> ballColors = [
    getRoleColor('marmelo'),
    const Color.fromARGB(255, 221, 108, 180),
    const Color.fromARGB(255, 83, 194, 88),
    const Color.fromARGB(255, 125, 94, 194),
    const Color.fromARGB(255, 226, 144, 77),
    const Color.fromARGB(255, 230, 81, 81)
  ];

  @override
  void initState() {
    super.initState();
    // Set up for Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() {
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
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
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enroll',
              style: TextStyle(
                fontSize: 14,
                color: messageColor,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login_screen'); // Navigate to login screen
            },
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BallPainter(
                      animation: _controller,
                      ballCount: ballCount,
                      ballColors: ballColors,
                    ),
                    child: Image.asset(
                      'assets/marmelo_character.png',
                      height: 400,
                      width: 800,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            const Text('Match on the web, co-create your dream service',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: themeColor,
                    fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 80,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enroll in Marmelo Academy',
                  style: TextStyle(
                      fontSize: 22,
                      color: messageColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login_screen'); // Navigate to private chat screen
                },
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Image.asset(
              'assets/features.png',
              width: 600,
              height: 300,
            ),
            const SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/matched.png',
                          width:
                              MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0),
                          child: Text(
                            'Marmelo Academy’s unique algorithm matches you with the best project group! Get matched and start your project immediately!',
                            style: TextStyle(
                                fontSize: 18,
                                color: themeColor,
                                fontWeight: FontWeight.bold),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0),
                          child: Text(
                            'Gemini AI will facilitate your project as a tutor with full commitment! It will maximize the productivity of your group!',
                            style: TextStyle(
                                fontSize: 18,
                                color: themeColor,
                                fontWeight: FontWeight.bold),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/group_chat.png',
                          width:
                              MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/private_chat.png',
                          width:
                              MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style:
                                  DefaultTextStyle.of(context).style.copyWith(
                                        fontSize: 18,
                                        color: themeColor,
                                        decoration:
                                            TextDecoration.none,
                                      ),
                              children: const <InlineSpan>[
                                TextSpan(
                                  text:
                                      'Struggling with ideas? Want to ask project questions privately ? Then call on Gemini AI in Private Chat Assistant mode!',
                                  style: TextStyle(
                                      color: themeColor,
                                      decoration: TextDecoration.none),
                                ),
                                WidgetSpan(
                                  child: Icon(
                                    Icons.assistant,
                                    color: themeColor,
                                    size: 24,
                                  ),
                                ),
                                TextSpan(
                                  text: ' <- Press this icon to ask to Gemini!',
                                  style: TextStyle(
                                      color: themeColor,
                                      decoration: TextDecoration.none),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0),
                          child: Text(
                            'Too busy taking minutes during meetings to keep up with the discussion? With Marmelo Academy, Gemini AI summarizes and outputs the meeting minutes for you! From project overviews to schedules and member tasks, everything is managed automatically!',
                            style: TextStyle(
                                fontSize: 18,
                                color: themeColor,
                                fontWeight: FontWeight.bold),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/marmelo_overview.png',
                          width:
                              MediaQuery.of(context).size.width * 0.4,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                ),
                child: const Text(
                  'Enroll in Marmelo Academy',
                  style: TextStyle(
                      fontSize: 22,
                      color: messageColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login_screen'); // Navigate to login screen
                },
              ),
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/privacy_policy_screen'); // Navigate to privary policy screen
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: themeColor,
                    decoration: TextDecoration.underline,
                    decorationColor: themeColor,
                    decorationThickness: 2,
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/terms_of_service_screen'); // Navigate to terms of service screen
                },
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: themeColor,
                    decoration: TextDecoration.underline,
                    decorationColor: themeColor,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Class for ball animation
class BallPainter extends CustomPainter {
  final Animation<double> animation;
  final int ballCount;
  final List<Color> ballColors;

  BallPainter(
      {required this.animation,
      required this.ballCount,
      required this.ballColors});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width * 0.701;
    final double centerY = size.height / 2;
    final double radius = size.width * 0.235;
    final double ballSize = size.width / 21;

    for (int i = 0; i < ballCount; i++) {
      
      final double linearProgress =
          (animation.value + i * (1 - cos(1 * pi)) / ballCount / 6.0) % 1.0;
      final double progress =
          (1 - cos((linearProgress) * pi)) / 2;

      final double angle = 2 * pi * progress - pi;
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);

      final paint = Paint()
        ..color = ballColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), ballSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
