// Import packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import '../components/custom_button.dart';
import '../components/custom_input_field.dart';
import 'components/user_info.dart';
import 'components/widget_color.dart';


// Main widget of ProfileEditScreen
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);
  @override
  ProfileEditScreenState createState() => ProfileEditScreenState();
}

// State for ProfileEditScreen
class ProfileEditScreenState extends State<ProfileEditScreen> {
  String _displayName = '';
  String _employer = '';
  String _dailytasks = '';
  String _universitystudies = '';
  String _reason = '';
  String _interestingAI = '';
  String _holiday = '';
  bool _allFieldsValid = false;
  String _selectedSkill = 'Leader';
  bool _readytoMatch = false;

  Map<String, bool> _selectedInterests = UserProfile.selectedInterests;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    if (UserProfile.islogin == false) {
      Navigator.pushNamed(context, '/login_screen');
    }
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, bool> firestoreInterests =
              Map<String, bool>.from(userDoc['interests'] ?? {});
          setState(() {
            UserProfile.selectedInterests.forEach((key, value) {
              if (firestoreInterests.containsKey(key)) {
                UserProfile.selectedInterests[key] =
                    firestoreInterests[key] ?? false;
              }
            });
            UserProfile.displayName =
                userDoc['displayName'] ?? user.displayName ?? '';
            UserProfile.chatId = userDoc['chat_id'] ?? '';
            UserProfile.selectedSkill =
                userDoc['skill'] ?? UserProfile.selectedSkill;
            UserProfile.userId = user.uid;
            UserProfile.employer = userDoc['employer'] ?? '';
            UserProfile.dailytasks = userDoc['dailytasks'] ?? '';
            UserProfile.universityStudies = userDoc['universitystudies'] ?? '';
            UserProfile.reason = userDoc['reason'] ?? '';
            UserProfile.interestingAI = userDoc['interestingAI'] ?? '';
            UserProfile.holiday = userDoc['holiday'] ?? '';
            _readytoMatch = true;
          });
        } else {
          setState(() {
            _displayName = user.displayName ?? '';
          });
        }
        _displayName = UserProfile.displayName;
        _selectedInterests = UserProfile.selectedInterests;
        _selectedSkill = UserProfile.selectedSkill;
        _employer = UserProfile.employer;
        _dailytasks = UserProfile.dailytasks;
        _universitystudies = UserProfile.universityStudies;
        _reason = UserProfile.reason;
        _interestingAI = UserProfile.interestingAI;
        _holiday = UserProfile.holiday;
      }
    } catch (e) {
      if(kDebugMode){
        print('Failed to load profile data: $e');
      }
    }
  }

  Future<void> _saveProfileData() async {
    try {
      _allFieldsValid = _displayName.isNotEmpty &&
          _selectedSkill.isNotEmpty &&
          _selectedInterests.values.contains(true) &&
          _employer.isNotEmpty &&
          _dailytasks.isNotEmpty &&
          _universitystudies.isNotEmpty &&
          _reason.isNotEmpty &&
          _interestingAI.isNotEmpty &&
          _holiday.isNotEmpty;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _allFieldsValid) {
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': _displayName,
          'skill': _selectedSkill,
          'interests': _selectedInterests,
          'chat_id': UserProfile.chatId,
          'employer': _employer,
          'dailytasks': _dailytasks,
          'universitystudies': _universitystudies,
          'reason': _reason,
          'interestingAI': _interestingAI,
          'holiday': _holiday,
        }, SetOptions(merge: true));
        if(kDebugMode){
          print('Profile data saved successfully');
        }
      }
      _loadProfileData();
    } catch (e) {
      if(kDebugMode){
        print('Failed to save profile data: $e');
      }
    }
  }

  Future<void> _matchStart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'chat_id': '',
          'wait': true,
        });
        if(kDebugMode){
          print('matching start');
        }
      }
      _loadProfileData();
    } catch (e) {
      if(kDebugMode){
        print('Failed to start matching: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: backgroundColor,
          title: const Text(
            'Your Profile',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Your Name',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _displayName,
                    initialValue: _displayName,
                    onChanged: (value) {
                      setState(() {
                        _displayName = value;
                      });
                    },
                    minLines: 1, 
                    maxLines: 1,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Speciality',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: backgroundColor,
                    ),
                    child: Container(
                      height: 260, 
                      decoration: const BoxDecoration(color: backgroundColor),
                      child: ListView(
                        children: UserProfile.skills.map((String value) {
                          bool isSelected = _selectedSkill == value;
                          return ListTile(
                            title: Text(
                              value,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? getRoleColor(value)
                                    : disebleColor,
                              ),
                            ),
                            leading: Radio<String>(
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                  (states) {
                                if (isSelected) {
                                  return getRoleColor(value);
                                } else {
                                  return disebleColor;
                                }
                              }),
                              focusColor: getRoleColor(value),
                              value: value,
                              groupValue: _selectedSkill,
                              onChanged: (String? selectedValue) {
                                setState(() {
                                  _selectedSkill = selectedValue ?? '';
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Your Areas of Interest (Multiple Choices Possible)',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _selectedInterests.keys.map((String key) {
                      return FilterChip(
                        label: Text(
                          key,
                          style: TextStyle(
                            color: _selectedInterests[key]!
                                ? messageColor
                                : themeColor,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        selected: _selectedInterests[key]!,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedInterests[key] = selected;
                          });
                        },
                        backgroundColor: messageColor,
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
                  const SizedBox(height: 20),
                  const Text(
                    'Industry',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _employer,
                    initialValue: _employer,
                    onChanged: (value) {
                      setState(() {
                        _employer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Current Job Responsibility',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _dailytasks,
                    initialValue: _dailytasks,
                    onChanged: (value) {
                      setState(() {
                        _dailytasks = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Major',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _universitystudies,
                    initialValue: _universitystudies,
                    onChanged: (value) {
                      setState(() {
                        _universitystudies = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What interests you about Generative AI',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _reason,
                    initialValue: _reason,
                    onChanged: (value) {
                      setState(() {
                        _reason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What AI tool are you interested in',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _interestingAI,
                    initialValue: _interestingAI,
                    onChanged: (value) {
                      setState(() {
                        _interestingAI = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How I Spend My Days Off',
                    style: TextStyle(
                        color: themeColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomInputField(
                    hintText: _holiday,
                    initialValue: _holiday,
                    onChanged: (value) {
                      setState(() {
                        _holiday = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Save',
                    onPressed: () async {
                      await _saveProfileData();
                      String message = '';
                      if (_allFieldsValid) {
                        message = 'Profile was saved successfully';
                      } else {
                        message = 'There are missing fields in your input';
                      }
                      if(context.mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      }
                      
                    },
                    isEnabled: true,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Go to Matching Screen',
                    onPressed: UserProfile.chatId == "" && _readytoMatch
                        ? () {
                            _matchStart();
                            Navigator.pushNamed(context, '/matching');
                          }
                        : null,
                    isEnabled: UserProfile.chatId == "" && _readytoMatch,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Go to Group Chat Screen',
                    onPressed: UserProfile.chatId != ""
                        ? () {
                            Navigator.pushNamed(context, '/chat');
                          }
                        : null,
                    isEnabled: UserProfile.chatId != "",
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
