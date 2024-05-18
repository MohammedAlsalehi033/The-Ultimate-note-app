import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hci_project/Screens/NoteScreen.dart';
import '../Style/myColors.dart';

class MyWidgets {

  static Widget curvedNavigationBar(int selectedIndex, Function(int) onTap) {
    return CurvedNavigationBar(
      index: selectedIndex,
      backgroundColor: MyColors.backgroundColor,
      color: MyColors.primaryColor,
      items: <Widget>[
        Icon(Icons.favorite, size: 25, color: MyColors.inactiveColor),
        Icon(Icons.add, size: 30, color: MyColors.inactiveColor),
        Icon(Icons.settings, size: 30, color: MyColors.inactiveColor),
      ],
      onTap: onTap,
    );
  }

  static Widget dummyPage(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 30, color: MyColors.textColor),
      ),
    );
  }

  // Function to create a card widget with note data
  static Widget createNoteCard(String noteID, String noteDate, String noteTitle, String note, BuildContext context, PageController pageController) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteScreen(noteId: noteID, title: noteTitle , initialContent: note, pageController: pageController)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(8), // Added margin
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                noteTitle,
                style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                noteDate.substring(0,16 ),
                style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                note,
                style: TextStyle(
                  color: MyColors.textColor,
                  fontSize: 16,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Function to format the date string
  static String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return dateTime.toString();
  }
}
