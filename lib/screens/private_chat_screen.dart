// Import packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart';

// Import other project files
import 'components/user_info.dart';
import 'components/widget_color.dart';

// Main widget of PrivateChatScreen
class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({Key? key}) : super(key: key);
  @override
  ChatScreenState createState() => ChatScreenState();
}

//State for PrivateChatScreen
class ChatScreenState extends State<PrivateChatScreen> {
  final ScrollController _scrollController = ScrollController(); // Controller for scrolling
  final TextEditingController _controller = TextEditingController(); // Controller for text input
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  bool _withAI = false; // Flag to determine if AI is used
  bool _isComplete = false; // Flag to determine if the task is complete
  bool _isSystem = true; // Flag to determine if the message is from the system
  bool _isUserScrolling = false; // Flag to determine if the user is manually scrolling
  String addres = '';

  @override
  void initState() {
    if (UserProfile.islogin == false) {
      Navigator.pushNamed(context,
          '/login_screen'); // Redirect to the login screen forcibly if the user is not logged in or has logged out.
    }
    super.initState();

    FirebaseFirestore.instance.settings = const Settings(
      //host: 'localhost:8080', // Enable only when the Firebase emulator is running.
      sslEnabled: false,
      persistenceEnabled: false,
    );
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        //check if the user is scrolling manually.
        _isUserScrolling = _scrollController.offset <
            _scrollController.position.maxScrollExtent - 100;
      }
    });

    if (UserProfile.chatId != 'null') {
      // Listen for changes in messages collection
      _firestore
          .collection('sessions')
          .doc(UserProfile.chatId)
          .collection('messages')
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          var data = change.doc.data() as Map<String, dynamic>?;

          if (data != null) {
            if (kDebugMode) {
              print('content of document: $data');
            }
            if (change.type == DocumentChangeType.added) {
              if (kDebugMode) {
                print('messaged was added: ${data['prompt']}');
              }
            } else if (change.type == DocumentChangeType.modified) {
              if (kDebugMode) {
                print('messaged was updated: ${data['response']}');
                print(data);
                print('response of AI: ${data['response']}');
              }
              if (data['response'] == null) {
                if (kDebugMode) {
                  print(
                      'response of API was null. check extension configuration and log');
                }
              }
            }
          } else {
            if (kDebugMode) {
              print('Data was not found');
            }
          }
        }
      });

      // Listen for changes in session document
      _firestore
          .collection('sessions')
          .doc(UserProfile.chatId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          // Get document data
          var data = snapshot.data() as Map<String, dynamic>;

          // Check if chatMembers exists
          if (data.containsKey('chat_members')) {
            var chatMembers = data['chat_members'] as Map<String, dynamic>;
            if (kDebugMode) {
              print(chatMembers);
              print(UserProfile.userId);
            }

            String userId = UserProfile.userId;

            if (chatMembers.containsKey(userId)) {
              var userData = chatMembers[userId] as Map<String, dynamic>;

              if (userData.containsKey('complete')) {
                bool complete = userData['complete'];
                setState(() {
                  _isComplete = complete; // Load complete flag from session document stored in firestore
                });
              } else {
                if (kDebugMode) {
                  print('Complete key not found for user $userId');
                }
              }
            } else {
              if (kDebugMode) {
                print('User ID $userId not found in chat_members');
              }
            }
          } else {
            if (kDebugMode) {
              print('chat_members not found in document');
            }
          }
        } else {
          if (kDebugMode) {
            print('Document does not exist');
          }
        }
      });
    } else {
      if (kDebugMode) {
        print('chat does not exist');
      }
    }
  }

  // Send message to Firestore
  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user?.uid).get(); // Get user's document from firestore
    var data = snapshot.data() as Map<String, dynamic>;
    String chatId = data['chat_id']; // Get the ID of the chat that the user is participating in.
    if (_controller.text.isNotEmpty) {
      String message = _controller.text; // Collect text from text input box
      _controller.clear(); // Clear text input box
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('sessions')
            .doc(chatId)
            .collection('messages')
            .doc()
            .set({
          'message': message,
          'user_id': user.uid,
          'displayname': data['displayName'],
          'timestamp': FieldValue.serverTimestamp(),
          'private': true,
          'addres': user.uid,
          'ai': _withAI,
          'role': UserProfile.selectedSkill,
        });
        if (_isSystem == true) {
          DocumentReference docRef =
              _firestore.collection('sessions').doc(chatId); // Get session's document from firestore

          // Add message to individual datapool in the session document in firestore
          DocumentSnapshot docSnapshot = await docRef.get();

          if (docSnapshot.exists) {
            String currentprivate = docSnapshot[user.uid] ?? "";

            await docRef.update({
              user.uid: "$currentprivate, [$message]",
            });
          } else {
            await docRef.update({
              user.uid: "[$message]",
            });
          }
        }
      }
    }
  }

  // Toggle AI usage
  void _selectAI() {
    if (_withAI == true) {
      setState(() {
        _withAI = false;
        _isSystem = true;
      });
    } else {
      setState(() {
        _withAI = true;
        _isSystem = false;
      });
    }
  }

  // Mark task as complete
  void _complete() async {
    final user = FirebaseAuth.instance.currentUser;
    String id = user?.uid ?? '';
    DocumentSnapshot snapshot =
        await _firestore.collection('sessions').doc(UserProfile.chatId).get(); // Get session document
    var data = snapshot.data() as Map<String, dynamic>; // Get data as dictionary
    bool process = data['process']; // Load process flag from sesion document stored in firestore
    var chatMembers = data['chat_members'] as Map<String, dynamic>;
    var memberData = chatMembers[id] as Map<String, dynamic>;
    bool completeStatus = memberData['complete'] ?? false;

    DocumentReference docRef =
        _firestore.collection('sessions').doc(UserProfile.chatId); // Get session document
    if (completeStatus) {
      // Write code for any actions you want to take when completeStatus is true.
      // await docRef.update({
      //   'chat_members.$id.complete': false,
      // });
      // setState(() {
      //   _is_complete = false;
      // });
    } else {
      if (process == false) {
        await docRef.update({
          'chat_members.$id.complete': true,
        });
        setState(() {
          _isComplete = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        title: const Text(
          'Private Chat',
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        //　Display a menu to navigate to another screen.
        child: Container(
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ElevatedButton(// Button of navigation to private chat screen
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  '/chat'); // navigate to group chat screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: messageColor,
                            ),
                            child: const Text('Go to Group Chat Screen'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ElevatedButton( // Button of navigation to project overview screen
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/facilitation_screen');
                            }, // Navigate to project over view screen
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: messageColor,
                            ),
                            child: const Text('Go to Project Overview Screen'),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton( // Button of logout
                    onPressed: () {
                      UserProfile.logout(); // Clear cash data of user
                      Navigator.pushNamed(context,
                          '/login_screen'); // Log out and navigate to login screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: backgroundColor,
                    ),
                    child: const Text('Log out'),
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('sessions')
                  .doc(UserProfile.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {// Get messages from firestore
                if (snapshot.hasError) {
                  return const Text('Error was occurred');
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_isUserScrolling && _scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView( // Widget for message bubbles
                  controller: _scrollController,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    var data = document.data() as Map<String, dynamic>?;

                    if (data != null) {
                      if (data['private'] == false ||
                          data['addres'] != UserProfile.userId) {
                        return Container();
                      } else {
                        final user = FirebaseAuth.instance.currentUser;
                        bool isCurrentUser = data['user_id'] == user?.uid;

                        Color boxColor = getRoleColor(data['role'] ?? '');

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['displayname'] ?? 'Unknown sender',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: boxColor),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MarkdownBody(
                                          data: data['message'] + '\n' ??
                                              'Message was not Found',
                                          styleSheet: getMarkdownStyleSheet(
                                              fontSize: 16.0),
                                        ),
                                        const SizedBox(
                                          height: 18,
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      bottom: -10,
                                      right: -10,
                                      child: IconButton(
                                        iconSize: 16.0,
                                        icon: const Icon(Icons.copy,
                                            color: messageColor),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: data['message'] ?? ''));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Message was Copied')),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    } else {
                      return const ListTile(
                        title: Text('Data was not Found'),
                      );
                    }
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  // Text input box
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: themeColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: themeColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: themeColor,
                        ),
                      ),
                    ),
                    maxLines: 5,
                    minLines: 3,
                    cursorColor: themeColor,
                  ),
                ),
                Column(
                  children: [
                    // Button to send message
                    GestureDetector(
                      onTap: _sendMessage,
                      child: const Row(
                        children: [
                          Icon(Icons.send, color: themeColor),
                          SizedBox(width: 4),
                          Text('Send', style: TextStyle(color: themeColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Button to complete task
                    GestureDetector(
                      onTap: _complete,
                      child: Row(
                        children: [
                          Icon(Icons.task_alt,
                              color: _isComplete ? themeColor : disebleColor),
                          const SizedBox(width: 4),
                          Text(' Done',
                              style: TextStyle(
                                  color:
                                      _isComplete ? themeColor : disebleColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Button to call Gemini assistant
                    GestureDetector(
                      onTap: _selectAI,
                      child: Row(
                        children: [
                          Icon(Icons.assistant,
                              color: _withAI ? themeColor : disebleColor),
                          const SizedBox(width: 4),
                          Text('Assistant',
                              style: TextStyle(
                                  color: _withAI ? themeColor : disebleColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
