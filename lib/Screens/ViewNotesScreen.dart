import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hci_project/Screens/main.dart';
import 'package:hci_project/Style/myColors.dart';
import 'package:hci_project/Widgerts/Widgets.dart';



class ViewNotesPage extends StatefulWidget {
  final PageController pageController;
  const ViewNotesPage({Key? key, required this.pageController}) : super(key: key);

  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,20),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("HCI-users")
                .doc(currentUser!.email!)
                .collection("Notes")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Set the number of columns in the grid
                      mainAxisSpacing: 4.0, // Set the spacing between rows (smaller value)
                      crossAxisSpacing: 4.0, // Set the spacing between columns (smaller value)
                      childAspectRatio: 0.7, // Adjust the aspect ratio for cell size
                    ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                      String noteTitle = data["noteTitle"].toString();
                      String noteItself = data["note"];
                      String noteDate = data["noteDate"];
                      String documentId = documents[index].id;
print(noteDate);




                      return MyWidgets.createNoteCard(documentId,noteDate,noteTitle, noteItself, context, widget.pageController);
                    },
                  );


                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }

  // Function to format the date string
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return dateTime.toString();
  }
}
