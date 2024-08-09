// Import packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import 'components/widget_color.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Main MatchedScreen widget
class MatchedScreen extends StatefulWidget {
  const MatchedScreen({Key? key}) : super(key: key);
  @override
  MatchedScreenState createState() => MatchedScreenState();
}

// State for MatchedScreen
class MatchedScreenState extends State<MatchedScreen> {
  List<Map<String, String>> _chatMembers = [];
  List<dynamic> _commonInterest = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Function to load user profile data from Firestore
  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the user document from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
           // Retrieve chat ID from user document
          String chatid = userDoc['chat_id'];
          // Get the chat session document from Firestore
          DocumentSnapshot chatDoc =
              await _firestore.collection('sessions').doc(chatid).get();
          _commonInterest = chatDoc['common_interest'];
          Map<String, Map<String, dynamic>> members =
              Map<String, Map<String, dynamic>>.from(
                  chatDoc['chat_members'] ?? {});
          // Sort member list alphabetically by displayName
          List<Map<String, String>> sortedMembers =
              members.values.map((member) {
            return {
              'displayName': member['displayName'] as String? ?? '',
              'role': member['role'] as String? ?? '',
            };
          }).toList();
          // Sort the members by displayName
          sortedMembers
              .sort((a, b) => a['displayName']!.compareTo(b['displayName']!));
          setState(() {
            _chatMembers = sortedMembers;
          });
          if(kDebugMode){
            print(_chatMembers);
          }
        } else {
          if(kDebugMode){
            print("User document does not exist");
          }
        }
      } else {
        if(kDebugMode){
          print("User is not found");
        }
      }
    } catch (e) {
      if(kDebugMode){
        print('Failed to load profile data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        title: const Text(
          'Match Found',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'A Match Has Been Found !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 20,
                      color: themeColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: _chatMembers.map((member) {
                      Color boxColor = getRoleColor(member['role'] ?? '');
                      return Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                member['displayName'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: messageColor,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                member['role'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: messageColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'Common Interests',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _commonInterest.map((label) {
                      return FilterChip(
                        label: Text(
                          label,
                          style: const TextStyle(
                            color: messageColor,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        selected: false,
                        onSelected: (selected) {},
                        backgroundColor: themeColor,
                        selectedColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: themeColor,
                            width: 0.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go to Group Chat Screen',
                      style: TextStyle(
                        fontSize: 20,
                        color: messageColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat'); // Navigate to group chat screen
                    },
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
