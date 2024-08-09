import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Function to get the color associated with a specific role
Color getRoleColor(String role) {
  switch (role) {
    case 'marmelo':
      return themeColor; // color for Marmelo AI
    case 'Leader':
      return const Color.fromARGB(255, 166, 67, 67); // color for Leader
    case 'Marketer':
      return const Color.fromARGB(255, 179, 110, 51); // color for Marketer
    case 'Engineer':
      return const Color.fromARGB(255, 115, 91, 165); // color for Engineer
    case 'Project Manager':
      return const Color.fromARGB(255, 73, 161, 76); // color for Project Manager
    case 'Designer':
      return const Color.fromARGB(255, 188, 86, 150); // color for Designer
    default:
      return const Color.fromARGB(255, 127, 127, 127); // color for Unknown
  }
}

// Function to configure the style sheet for Markdown rendering
MarkdownStyleSheet getMarkdownStyleSheet({
  Color commentColor = messageColor, // Default text color for comments
  double fontSize = 12.0, // Default font size for text
}) {
  return MarkdownStyleSheet(
    p: TextStyle(fontSize: fontSize, color: commentColor), // Paragraph style
    h1: TextStyle(fontSize: fontSize, color: commentColor), // Header 1 style
    h2: TextStyle(fontSize: fontSize, color: commentColor), // Header 2 style
    h3: TextStyle(fontSize: fontSize, color: commentColor), // Header 3 style
    h4: TextStyle(fontSize: fontSize, color: commentColor), // Header 4 style
    h5: TextStyle(fontSize: fontSize, color: commentColor), // Header 5 style
    h6: TextStyle(fontSize: fontSize, color: commentColor), // Header 6 style
    blockquote: TextStyle(fontSize: fontSize, color: commentColor), // Blockquote style
    code: TextStyle(
        fontSize: fontSize, color: commentColor, backgroundColor: Colors.black), // Inline code style
    codeblockDecoration: BoxDecoration(
        color: Colors.black, borderRadius: BorderRadius.circular(4)), // Code block decoration
    listBullet: TextStyle(fontSize: fontSize, color: commentColor), // List bullet style
    tableHead: TextStyle(fontSize: fontSize, color: commentColor), // Table header style
    tableBody: TextStyle(fontSize: fontSize, color: commentColor), // Table body style
    strong: TextStyle(fontSize: fontSize, color: commentColor), // Bold text style
    em: TextStyle(fontSize: fontSize, color: commentColor), // Italic text style
    del: TextStyle(fontSize: fontSize, color: commentColor), // Strikethrough text style
    a: TextStyle(fontSize: fontSize, color: Colors.blueAccent), // Link style
    img: TextStyle(fontSize: fontSize, color: commentColor), // Image style
  );
}

// Configuration of colors used in the application
const Color messageColor = Colors.white; // Default message color
const Color themeColor = Color(0xFF3D6595); // Theme color
const Color backgroundColor = Colors.white; // Background color
const Color disebleColor = Color.fromARGB(255, 187, 187, 187); // Disabled color
