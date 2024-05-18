import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hci_project/Screens/main.dart';
import 'package:hci_project/Style/myColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class SignningWidget extends StatefulWidget {
  const SignningWidget({Key? key}) : super(key: key);

  @override
  _SignningWidgetState createState() => _SignningWidgetState();
}

class _SignningWidgetState extends State<SignningWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder:(context)=> Scaffold(backgroundColor: MyColors.backgroundColor,
        body: Center(
          child: ElevatedButton(child: Text("Sign In with Google"),onPressed: ()async{
          signInWithGoogle(context);
              },),
        )),
      ),
    );
  }
}


Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Check if a user is already signed in
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // If user is already signed in, navigate to MyApp directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
      print("User signed in: ${currentUser.displayName} (${currentUser.email})");

      return;
    }

    // Initialize GoogleSignIn
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();

    if (googleSignInAccount == null) {
      // The user canceled the sign-in process
      return;
    }

    // Obtain the GoogleSignInAuthentication object
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    // Create a new credential using the GoogleSignInAuthentication object
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    // Sign in to Firebase with the Google Auth credentials
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);

    // Print user information to the console
    final User user = userCredential.user!;
    print("User signed in: ${user.displayName} (${user.email})");


    var collection = FirebaseFirestore.instance.collection('HCI-users');
    collection
        .doc(user.email!)
        .set({
      'noteTitle': 20,
      'noteDate': "whatever",
      'note': "whatever you wrote",
      'favorate': "Favorate",
        })
        .then((_) => print('Added'))
        .catchError((error) => print('Add failed: $error'));

    // Navigate to MyApp after sign-in
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  } catch (e) {
    print("Error during Google sign in: $e");
  }
}


Future<UserCredential> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  // Create a credential from the access token
  final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}
