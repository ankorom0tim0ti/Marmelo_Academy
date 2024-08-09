// Import dart libraries
import 'dart:async';

// Import packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import 'components/user_info.dart';
import 'components/widget_color.dart';


//  Main MatchingScreen widget
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);
  @override
  MatchingScreenState createState() => MatchingScreenState();
}

//  State for MatchingScreen
class MatchingScreenState extends State<MatchingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Start a timer to trigger a function that checks every 5 seconds whether the matching process is complete by accessing Firestore.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkFirebaseForMatch();
    });
  }

  // Access Firestore to check if the matching process is complete.
  void _checkFirebaseForMatch() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user?.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data['chat_id'] != '') {
          UserProfile.chatId = data['chat_id'];
          if(mounted){
            Navigator.pushReplacementNamed(context, '/matched'); // Navigate to matched screen
          }
        } else {
          if(kDebugMode){
            print("error");
          }
        }
      }
    } catch (e) {
      if(kDebugMode){
        print("Error checking Firebase: $e");
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Functions to determine size of loading indicator
  double sizeofCircule() {
    double widthofWindow = MediaQuery.of(context).size.width * 0.5;
    double maxWidth = 500;
    if (widthofWindow > maxWidth) {
      return maxWidth;
    } else {
      return widthofWindow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        title: const Text(
          'Matching in Progress...',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Text(
                'Matching in Progress...',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColor),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: sizeofCircule(),
                height: sizeofCircule(),
                child: const Center(
                  child: AnimatedCircles(),
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Looking for the Perfect Group for You ...',
                style: TextStyle(
                  color: themeColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You Will Be Notified When a Team Match is Found',
                style: TextStyle(
                  color: themeColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widget of  animation of load indicator
class AnimatedCircles extends StatefulWidget {
  const AnimatedCircles({Key? key}) : super(key: key);
  @override
  AnimatedCirclesState createState() => AnimatedCirclesState();
}

// State for animation of load indeicator
class AnimatedCirclesState extends State<AnimatedCircles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: CirclePainter(_animation.value),
            child: const SizedBox(
              width: 800.0, // ここで幅を設定
              height: 800.0,
            ),
          );
        },
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress;

  CirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final double maxRadius = size.width / 2;
    const  int numCircles = 5;

    for (int i = 0; i < numCircles; i++) {
      final double radius = maxRadius * (i + 1) / numCircles;
      paint.color = const Color.fromARGB(255, 131, 177, 233)
          .withOpacity((1 - i / numCircles) * progress);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
