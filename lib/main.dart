// import library and other files

//import package
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import firebase options file
import 'firebase_options.dart';

// import screen files
import 'screens/login_screen.dart';
import 'screens/matching_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/matched_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/facilitation_screen.dart';
import 'screens/entrance_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/home_page_screen.dart';
import 'screens/termsofsevice_screen.dart';
import 'screens/private_chat_screen.dart';
import 'screens/components/widget_color.dart';

//main function for this application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // cofigurateion for emulator
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    FirebaseFirestore.instance.settings = const Settings(
        //host: 'localhost:8080',
        //sslEnabled: false,
        //persistenceEnabled: false,
        );
    //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseAuth.instance;
  }

  runApp(const MarmeloAcademyApp());
}

//class responsible for managing transitions within the app
class MarmeloAcademyApp extends StatelessWidget {
  const MarmeloAcademyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marmelo Academy',
      theme: ThemeData(
        primaryColor: backgroundColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: themeColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: disebleColor,
        ),
      ),

      //definition of screen navigater
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePageScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/matching': (context) => const MatchingScreen(),
        '/matched': (context) => const MatchedScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile_edit': (context) => const ProfileEditScreen(),
        '/private_chat_screen': (context) => const PrivateChatScreen(),
        '/facilitation_screen': (context) => const FacilitationPage(),
        '/entrance_screen': (context) => const EntranceScreen(),
        '/privacy_policy_screen': (context) => const PrivacyPolicyScreen(),
        '/terms_of_service_screen': (context) => const TermsofServiceScreen(),
      },
    );
  }
}
