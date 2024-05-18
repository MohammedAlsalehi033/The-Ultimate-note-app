import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hci_project/Screens/NoteScreen.dart';

import '../Style/myColors.dart';
import '../Widgerts/Widgets.dart';
import 'SignInPage.dart';
import 'ViewNotesScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyDcrairSv8Odb-Rxr6MEFn359FUg4qY9NU',
    appId: '1:749157065262:android:22d3d92262f009ff7775bf',
    messagingSenderId: '749157065262',
    projectId: 'fir-cdba5',
  ));

  User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(currentUser == null ? SignningWidget() : MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}









class _MainPageState extends State<MainPage> {
  int _selectedItem = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(), // Disable swiping between pages
          children: [
            ViewNotesPage(pageController: pageController),
            NoteScreen(
              noteId: "",
              title: "",
              initialContent: "",
              pageController: pageController,
              index: _selectedItem
            ),
            MyWidgets.dummyPage("Page 3"),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: MyWidgets.curvedNavigationBar(
          _selectedItem,
              (index) {
            setState(() {
              _selectedItem = index;
              pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
