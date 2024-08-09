# What is Marmelo Acaademy

- Marmelo Academy helps teams with diverse talents and backgrounds come together to develop Gen-AI powered applications, providing comprehensive support throughout the process.
- Key features include group matching and Gemini facilitation. After forming a group of five, the AI facilitator Gemini joins the group chat, assisting with brainstorming, refining ideas, and documenting tasks necessary for app development.
- This app connects people with different skills and backgrounds to foster Gen-AI-based global innovation. It is also designed for those who may lack community or struggle with communication.
- By using generative AI to solve challenges, users shift from fearing AI taking jobs to creating valuable new work with AI. Additionally, users can potentially earn revenue by publishing their apps and build a supportive community through team collaboration.


# caution and apology

This application contains API keys and other confidential information about our project. Unfortunately, We must apologize, but this repository only include the listing of folders and files, as well as the preparation of the execution environment.

- assets/
- functions/main.py
- functions/requirements.txt
- lib/ (Except for firebase_options.dart)
- pubspec.yaml

# Getting Started

0. Please Install the Flutter SDK, other necessary software for Flutter application development, and the Firebase CLI.

1. Please Download this repository into your computer and create new flutter project with below code.

```bash
flutter create <your_project_name>
```

2. Please Create and setup new firebase project in firebase console. this process needs your google account and your API key.

You need to configure the features listed below.

- Authenfication
- Extensions ("Build Chatbot with the Gemini API" provided by Google Cloud)
- Firestore Database
- Functions
- Hosting

After that, navigate to the project settings screen on the console and add the applications for the platforms you want to use to the project.

3. Please Link your flutter project to firebase project by running below command　and follow the on-screen instructions to complete the setup.This process need your google account that is used to manage the Firebase project. 

```bash
firebase init
```

After that, run the following command in the root directory of your project. This will create a file named firebase_options.dart in the lib directory directly under the project.

```bash
flutterfire configure
```

Please ensure that the contents of firebase_options.dart match the application information available on the Firebase project's setup screen.

4. Please place or copy the code downloaded from GitHub into your Flutter project.　Then, please run the following code to install the necessary packages for the project.

```bash
flutter pub get
```

5. Please set up Firestore Database and Extenstions.

# Firestore Database
This project achieves flexible implementation by managing prompts for Gemini and some system frameworks in Firestore. Here, we provide the application settings stored in Firebase that are used in this project. Please refer to the [FIRESTORE.md](./FIRESTORE.md)

# Extensions
This project uses "Build Chatbot with the Gemini API" extension in order to integrate Gemini AI into the conversation flow to facilitate the group." Here, we provide the extension settings of chatbot. Please refer to the [CHATBOT.md](./CHATBOT.md)

6. For now, You completes the necessary processes for execution. Please note that when using the Firebase emulator, the Gemini API may time out, so testing in the actual environment is recommended.# Marmelo_Academy
