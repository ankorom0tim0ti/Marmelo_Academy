// Import packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import 'components/user_info.dart';
import 'components/widget_color.dart';

// Main FacilitationScreen widget
class FacilitationPage extends StatefulWidget {
  const FacilitationPage({Key? key}) : super(key: key);
  @override
  FacilitationScreen createState() => FacilitationScreen();
}

// State for FacilitaitonScreen
class FacilitationScreen extends State<FacilitationPage> {
  Map<String, dynamic>? data;

  bool isDataLoaded = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> _sessionFacilitation = {};
  List<Map<String, String>> _chatMembers = [];
  List<dynamic> _commonInterest = [];

  @override
  void initState() {
    super.initState();
    if (UserProfile.islogin) {
      _loadData();
    } else {
      Navigator.pushNamed(context,
          '/login_screen'); // Redirect to the login screen forcibly if the user is not logged in or has logged out.
    }
  }

  // Function to load project data from firestore
  void _loadData() async {
    // load data of chat members from firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          String chatid = userDoc['chat_id'];
          DocumentSnapshot chatDoc =
              await _firestore.collection('sessions').doc(chatid).get();
          _commonInterest = chatDoc['common_interest'];
          Map<String, Map<String, dynamic>> members =
              Map<String, Map<String, dynamic>>.from(
                  chatDoc['chat_members'] ?? {});

          List<Map<String, String>> sortedMembers =
              members.values.map((member) {
            return {
              'displayName': member['displayName'] as String? ?? '',
              'role': member['role'] as String? ?? '',
            };
          }).toList();

          sortedMembers
              .sort((a, b) => a['displayName']!.compareTo(b['displayName']!));

          setState(() {
            _chatMembers = sortedMembers;
          });

          if (kDebugMode) {
            print(_chatMembers);
          }
        } else {
          if (kDebugMode) {
            print("User document does not exist");
          }
        }
      } else {
        if (kDebugMode) {
          print("User is not found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load profile data: $e');
      }
    }
    // load facilitation data from firestore
    try {
      DocumentSnapshot sessionDoc =
          await _firestore.collection('sessions').doc(UserProfile.chatId).get();
      if (sessionDoc.exists) {
        Map<String, dynamic> rawData =
            Map<String, dynamic>.from(sessionDoc['facilitation'] ?? {});
        if (kDebugMode) {
          print(rawData);
        }
        if (rawData.isEmpty) {
          setState(() {
            rawData = UserProfile.projectData;
          });
        }

        // sort outer dictionary of facilitation
        var sortedKeys = rawData.keys.toList()..sort();
        Map<String, Map<String, dynamic>> sortedData = {};
        for (var key in sortedKeys) {
          // sort inner dictionary of facilitation
          Map<String, dynamic> innerMap =
              Map<String, dynamic>.from(rawData[key] ?? {});
          var innerKeys = innerMap.keys.toList()..sort();
          Map<String, dynamic> sortedInnerMap = {
            for (var innerKey in innerKeys) innerKey: innerMap[innerKey]
          };

          sortedData[key] = sortedInnerMap;
        }
        // vefrify construction of facilitation
        bool isValidStructure =
            _validateStructure(sortedData, UserProfile.projectData);

        if (isValidStructure) {
          // load facilitation data into cash data
          Map<String, Map<String, dynamic>> updatedProjectData =
              _replaceTBD(UserProfile.projectData, sortedData);
          if (kDebugMode) {
            print(updatedProjectData);
          }

          setState(() {
            _sessionFacilitation = updatedProjectData;
          });
        } else {
          if (kDebugMode) {
            print(
                'Error: Data structure does not match the expected projectData structure.');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  // Function to verify if construction of project data stored in firestore is correct
  bool _validateStructure(Map<String, Map<String, dynamic>> data,
      Map<String, Map<String, dynamic>> reference) {
    // Standardize the keys before comparing the sets of keys."
    Set<String> dataKeys =
        data.keys.map((key) => key.trim().toLowerCase()).toSet();
    Set<String> referenceKeys =
        reference.keys.map((key) => key.trim().toLowerCase()).toSet();

    if (dataKeys.length != referenceKeys.length ||
        !dataKeys.containsAll(referenceKeys)) {
      if (kDebugMode) {
        print('key_of_firestore');
        print(dataKeys);
        print('key_of_reference');
        print(referenceKeys);
      }
      return false;
    }

    for (var key in data.keys) {
      Set<String> dataSubKeys =
          data[key]!.keys.map((subKey) => subKey.trim().toLowerCase()).toSet();
      Set<String> referenceSubKeys = reference[key]!
          .keys
          .map((subKey) => subKey.trim().toLowerCase())
          .toSet();
      if (kDebugMode) {
        print('key_of_firestore_subkeys for $key');
        print(dataSubKeys);
        print('key_of_reference_subkeys for $key');
        print(referenceSubKeys);
      }

      if (dataSubKeys.length != referenceSubKeys.length ||
          !dataSubKeys.containsAll(referenceSubKeys)) {
        if (kDebugMode) {
          print('key_of_firestore_subkeys for $key');
          print(dataSubKeys);
          print('key_of_reference_subkeys for $key');
          print(referenceSubKeys);
        }
        return false;
      }
    }

    return true;
  }

  Map<String, Map<String, dynamic>> _replaceTBD(
      Map<String, Map<String, dynamic>> reference,
      Map<String, Map<String, dynamic>> data) {
    Map<String, Map<String, dynamic>> updatedData = {};

    for (var key in reference.keys) {
      Map<String, dynamic> innerMap = reference[key]!;
      Map<String, dynamic> updatedInnerMap = {};
      for (var innerKey in innerMap.keys) {
        if (innerMap[innerKey] == "TBD" &&
            data[key] != null &&
            data[key]![innerKey] != null) {
          updatedInnerMap[innerKey] = data[key]![innerKey];
        } else {
          updatedInnerMap[innerKey] = innerMap[innerKey];
        }
      }

      updatedData[key] = updatedInnerMap;
    }

    return updatedData;
  }

  // Function for get string data from project overview stored in cash
  String? getValueFromProjectData(String mainKey, String subKey) {
    // Check if main keys exist
    if (_sessionFacilitation.containsKey(mainKey)) {
      // Check if sub keys exist
      Map<String, dynamic>? subMap =
          _sessionFacilitation[mainKey] as Map<String, dynamic>?;
      if (subMap != null && subMap.containsKey(subKey)) {
        return subMap[subKey].toString();
      }
    }
    return null; // If keys are not existed, return null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Project Overview',
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
        ),
        body: _sessionFacilitation.isEmpty
            ? const Center(
                child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ))
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    color: backgroundColor,
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: themeColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Project Members',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: _chatMembers.map((member) {
                              Color boxColor =
                                  getRoleColor(member['role'] ?? '');
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
                              fontWeight: FontWeight.bold,
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
                                    width: 2,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            'Next Meeting Schedule',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${getValueFromProjectData("8 Next Meeting Schedule", "8.1 Month").toString()} / ${getValueFromProjectData("8 Next Meeting Schedule", "8.2 Day").toString()}",
                            style: const TextStyle(color: themeColor),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            '1 Cocept of Project',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 360,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              border: Border.all(color: themeColor, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListView.builder(
                              itemCount:
                                  _sessionFacilitation["1 Project Concept"]
                                      ?.length,
                              itemBuilder: (context, index) {
                                String key =
                                    _sessionFacilitation["1 Project Concept"]!
                                        .keys
                                        .elementAt(index);
                                return ListTile(
                                  title: Text(
                                    key,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: themeColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: MarkdownBody(
                                    data: _sessionFacilitation[
                                        "1 Project Concept"]?[key],
                                    styleSheet: getMarkdownStyleSheet(
                                        commentColor: themeColor, fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            '2 Schedule',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border:
                                  Border.all(color: backgroundColor, width: 2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(
                                    color: themeColor,
                                    width: 2,
                                    borderRadius: BorderRadius.circular(8)),
                                children: _sessionFacilitation["2 Schedule"]
                                        ?.entries
                                        .map((entry) {
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${entry.key}:',
                                              style: const TextStyle(
                                                color: themeColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              entry.value,
                                              style: const TextStyle(
                                                color: themeColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList() ??
                                    [],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            '3 Initial Tasks of Members',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Initial Task of Leader : ${getValueFromProjectData("3 Initial Tasks of Leader", "3.1 User Name") ?? 'TBD'}',
                            style: TextStyle(
                                color: getRoleColor('Leader'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: getRoleColor('Leader'), width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: backgroundColor),
                              child: Column(
                                children: [
                                  Text(
                                    'Task',
                                    style: TextStyle(
                                        color: getRoleColor('Leader'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "3 Initial Tasks of Leader",
                                            "3.2 Task") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Leader'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Details',
                                    style: TextStyle(
                                        color: getRoleColor('Leader'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "3 Initial Tasks of Leader",
                                            "3.3 Task Details") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Leader'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Deadline',
                                    style: TextStyle(
                                        color: getRoleColor('Leader'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "3 Initial Tasks of Leader",
                                            "3.4 Task Deadline") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Leader'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Initial Task of Project Manager : ${getValueFromProjectData("4 Initial Tasks of PM", "4.1 User Name") ?? 'TBD'}',
                            style: TextStyle(
                                color: getRoleColor('Project Manager'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: getRoleColor('Project Manager'),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: backgroundColor),
                              child: Column(
                                children: [
                                  Text(
                                    'Task',
                                    style: TextStyle(
                                        color: getRoleColor('Project Manager'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "4 Initial Tasks of PM",
                                            "4.2 Task") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Project Manager'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Details',
                                    style: TextStyle(
                                        color: getRoleColor('Project Manager'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "4 Initial Tasks of PM",
                                            "4.3 Task Details") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Project Manager'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Deadline',
                                    style: TextStyle(
                                        color: getRoleColor('Project Manager'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "4 Initial Tasks of PM",
                                            "4.4 Task Deadline") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Project Manager'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Initial Task of Designer : ${getValueFromProjectData("5 Initial Tasks of UI/UX Designer", "5.1 User Name") ?? 'TBD'}',
                            style: TextStyle(
                                color: getRoleColor('Designer'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: getRoleColor('Designer'),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: backgroundColor),
                              child: Column(
                                children: [
                                  Text(
                                    'Task',
                                    style: TextStyle(
                                        color: getRoleColor('Designer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "5 Initial Tasks of UI/UX Designer",
                                            "5.2 Task") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Designer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Details',
                                    style: TextStyle(
                                        color: getRoleColor('Designer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "5 Initial Tasks of UI/UX Designer",
                                            "5.3 Task Details") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Designer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Deadline',
                                    style: TextStyle(
                                        color: getRoleColor('Designer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "5 Initial Tasks of UI/UX Designer",
                                            "5.4 Task Deadline") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Designer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Initial Task of Engineer : ${getValueFromProjectData("6 Initial Tasks of Engineer", "6.1 User Name") ?? 'TBD'}',
                            style: TextStyle(
                                color: getRoleColor('Engineer'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: getRoleColor('Engineer'),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: backgroundColor),
                              child: Column(
                                children: [
                                  Text(
                                    'Task',
                                    style: TextStyle(
                                        color: getRoleColor('Engineer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "6 Initial Tasks of Engineer",
                                            "6.2 Task") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Engineer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Details',
                                    style: TextStyle(
                                        color: getRoleColor('Engineer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "6 Initial Tasks of Engineer",
                                            "6.3 Task Details") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Engineer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Deadline',
                                    style: TextStyle(
                                        color: getRoleColor('Engineer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "6 Initial Tasks of Engineer",
                                            "6.4 Task Deadline") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Engineer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Initial Task of Marketer : ${getValueFromProjectData("7 Initial Tasks of Marketer", "7.1 User Name") ?? 'TBD'}',
                            style: TextStyle(
                                color: getRoleColor('Marketer'),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: getRoleColor('Marketer'),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: backgroundColor),
                              child: Column(
                                children: [
                                  Text(
                                    'Task',
                                    style: TextStyle(
                                        color: getRoleColor('Marketer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "7 Initial Tasks of Marketer",
                                            "7.2 Task") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Marketer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Details',
                                    style: TextStyle(
                                        color: getRoleColor('Marketer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "7 Initial Tasks of Marketer",
                                            "7.3 Task Details") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Marketer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Task Deadline',
                                    style: TextStyle(
                                        color: getRoleColor('Marketer'),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getValueFromProjectData(
                                            "7 Initial Tasks of Marketer",
                                            "7.4 Task Deadline") ??
                                        'TBD',
                                    style: TextStyle(
                                      color: getRoleColor('Marketer'),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            '4 Result of the Day',
                            style: TextStyle(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                                border: Border.all(color: themeColor, width: 2),
                                borderRadius: BorderRadius.circular(8.0),
                                color: backgroundColor),
                            child: Text(
                              getValueFromProjectData(
                                      "9 Result of the Day", "9.1 Summary") ??
                                  'TBD',
                              style: const TextStyle(
                                color: themeColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }
}
