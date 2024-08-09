//file for cash data container

// Class representing a user profile with various static properties and methods
class UserProfile {
  // Static variables to store user state and information

  // Indicates if the user is logged in
  static bool islogin = false;
  // Stores the user's ID
  static String userId = "";
  // Stores the chat ID associated with the user
  static String chatId = "";
  // Indicates if the profile is private
  static bool private = false;
  // Stores the display name of the user
  static String displayName = "";
  // Stores the name of the user's employer
  static String employer = '';
  // Stores the user's daily tasks
  static String dailytasks = '';
  // Stores the user's university studies information
  static String universityStudies = '';
  // Stores the user's reason for using the application
  static String reason = '';
  // Stores the user's interest in AI
  static String interestingAI = '';
  // Stores the user's holiday preferences
  static String holiday = '';
  // Stores the user's selected skill
  static String selectedSkill = "Leader";

  // List of skills available for the user to select
  static List<String> skills = [
    'Leader',
    'Marketer',
    'Engineer',
    'Project Manager',
    'Designer'
  ];

  // Map of interests with boolean values indicating if they are selected
  static Map<String, bool> selectedInterests = {
    'Movies and TV': false,
    'Music': false,
    'Games': false,
    'Comedy': false,
    'Sports': false,
    'Academics': false,
    'Technology and Gadgets': false,
    'Language Learning': false,
    'Self-Improvement': false,
    'Fashion and Beauty': false,
    'Travel': false,
    'Gourmet': false,
    'Fitness': false,
    'Pets': false,
    'Entrepreneurship': false,
    'Investing': false,
    'Marketing': false,
    'Career': false,
    'Fashion': false,
    'Beauty and Health': false,
    'Home Appliances': false,
    'Home & Living': false,
    'Kids\' Items & Toys': false,
    'Pet Supplies': false,
    'Cars & Motorcycles': false,
    'Social Media': false,
    'Matching/Dating Apps': false,
    'Health Management Apps': false,
    'Learning Apps': false,
    'Productivity Tools': false,
    'Flea Market Apps': false,
    'News Apps': false,
    'Asset Management Apps': false,
    'Web App Development': false,
    'Mobile App Development': false,
    'Starting an E-Commerce Site': false,
    'Starting a YouTube Channel': false,
  };

  // Map containing project data with various nested maps for different project sections
  static Map<String, Map<String, dynamic>> projectData = {
    "1 Project Concept": {
      "1.1 Target": "TBD",
      "1.2 Problem of Target": "TBD",
      "1.3 Way of Solution": "TBD",
      "1.4 Project Value": "TBD",
      "1.5 Expected Features": "TBD"
    },
    "2 Schedule": {
      "2.1 Month 1": "TBD",
      "2.1.1 Week 1-2": "TBD",
      "2.1.2 Week 3-4": "TBD",
      "2.2 Month 2": "TBD",
      "2.2.1 Week 5-6": "TBD",
      "2.2.2 Week 7-8": "TBD",
      "2.3 Month 3": "TBD",
      "2.3.1 Week 9-10": "TBD",
      "2.3.2 Week 11-12": "TBD"
    },
    "3 Initial Tasks of Leader": {
      "3.1 User Name": "TBD",
      "3.2 Task": "TBD",
      "3.3 Task Details": "TBD",
      "3.4 Task Deadline": "TBD"
    },
    "4 Initial Tasks of PM": {
      "4.1 User Name": "TBD",
      "4.2 Task": "TBD",
      "4.3 Task Details": "TBD",
      "4.4 Task Deadline": "TBD"
    },
    "5 Initial Tasks of UI/UX Designer": {
      "5.1 User Name": "TBD",
      "5.2 Task": "TBD",
      "5.3 Task Details": "TBD",
      "5.4 Task Deadline": "TBD"
    },
    "6 Initial Tasks of Engineer": {
      "6.1 User Name": "TBD",
      "6.2 Task": "TBD",
      "6.3 Task Details": "TBD",
      "6.4 Task Deadline": "TBD"
    },
    "7 Initial Tasks of Marketer": {
      "7.1 User Name": "TBD",
      "7.2 Task": "TBD",
      "7.3 Task Details": "TBD",
      "7.4 Task Deadline": "TBD"
    },
    "8 Next Meeting Schedule": {"8.1 Month": "TBD", "8.2 Day": "TBD"},
    "9 Result of the Day": {"9.1 Summary": "TBD"}
  };

  // Function to log out the user and clear all cached data
  static void logout() {
    islogin = false;
    userId = "";
    chatId = "";
    private = false;
    displayName = "";
    employer = '';
    dailytasks = '';
    universityStudies = '';
    reason = '';
    interestingAI = '';
    holiday = '';
    selectedSkill = "Leader";
    selectedInterests = {
      'Movies and TV': false,
      'Music': false,
      'Games': false,
      'Comedy': false,
      'Sports': false,
      'Academics': false,
      'Technology and Gadgets': false,
      'Language Learning': false,
      'Self-Improvement': false,
      'Fashion and Beauty': false,
      'Travel': false,
      'Gourmet': false,
      'Fitness': false,
      'Pets': false,
      'Entrepreneurship': false,
      'Investing': false,
      'Marketing': false,
      'Career': false,
      'Fashion': false,
      'Beauty and Health': false,
      'Home Appliances': false,
      'Home & Living': false,
      'Kids\' Items & Toys': false,
      'Pet Supplies': false,
      'Cars & Motorcycles': false,
      'Social Media': false,
      'Matching/Dating Apps': false,
      'Health Management Apps': false,
      'Learning Apps': false,
      'Productivity Tools': false,
      'Flea Market Apps': false,
      'News Apps': false,
      'Asset Management Apps': false,
      'Web App Development': false,
      'Mobile App Development': false,
      'Starting an E-Commerce Site': false,
      'Starting a YouTube Channel': false,
    };
    projectData = {
      "1 Project Concept": {
        "1.1 Target": "TBD",
        "1.2 Problem of Target": "TBD",
        "1.3 Way of Solution": "TBD",
        "1.4 Project Value": "TBD",
        "1.5 Expected Features": "TBD"
      },
      "2 Schedule": {
        "2.1 Month 1": "TBD",
        "2.1.1 Week 1-2": "TBD",
        "2.1.2 Week 3-4": "TBD",
        "2.2 Month 2": "TBD",
        "2.2.1 Week 5-6": "TBD",
        "2.2.2 Week 7-8": "TBD",
        "2.3 Month 3": "TBD",
        "2.3.1 Week 9-10": "TBD",
        "2.3.2 Week 11-12": "TBD"
      },
      "3 Initial Tasks of Leader": {
        "3.1 User Name": "TBD",
        "3.2 Task": "TBD",
        "3.3 Task Details": "TBD",
        "3.4 Task Deadline": "TBD"
      },
      "4 Initial Tasks of PM": {
        "4.1 User Name": "TBD",
        "4.2 Task": "TBD",
        "4.3 Task Details": "TBD",
        "4.4 Task Deadline": "TBD"
      },
      "5 Initial Tasks of UI/UX Designer": {
        "5.1 User Name": "TBD",
        "5.2 Task": "TBD",
        "5.3 Task Details": "TBD",
        "5.4 Task Deadline": "TBD"
      },
      "6 Initial Tasks of Engineer": {
        "6.1 User Name": "TBD",
        "6.2 Task": "TBD",
        "6.3 Task Details": "TBD",
        "6.4 Task Deadline": "TBD"
      },
      "7 Initial Tasks of Marketer": {
        "7.1 User Name": "TBD",
        "7.2 Task": "TBD",
        "7.3 Task Details": "TBD",
        "7.4 Task Deadline": "TBD"
      },
      "8 Next Meeting Schedule": {"8.1 Month": "TBD", "8.2 Day": "TBD"},
      "9 Result of the Day": {"9.1 Summary": "TBD"}
    };
  }
}
