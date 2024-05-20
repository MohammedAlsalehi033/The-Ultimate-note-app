import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hci_project/Screens/main.dart';
import '../Style/myColors.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import "package:http/http.dart" as http;
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NoteScreen extends StatefulWidget {
  final String noteId;
  final String title;
  final String initialContent;
  final PageController pageController;

  const NoteScreen({
    Key? key,
    required this.noteId,
    required this.title,
    required this.initialContent,
    required this.pageController,  int? index,
  }) : super(key: key);



  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _textEditingController;
  late TextEditingController _textTitleEditingController;
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isSaving = false;
  List<String> fullSentence = [""];
  List<Map<String, String>> chatHistory = [];

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _recognizedSpeech = ''; // To hold recognized speech




  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialContent);
    _textTitleEditingController = TextEditingController(text: widget.title);
    _initSpeech();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _textTitleEditingController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    print(fullSentence.last);
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedSpeech = result.recognizedWords;
    });

    if (result.finalResult) {
      setState(() {
        _textEditingController.text += " " + _recognizedSpeech;
      });
    }
    fullSentence.add(_recognizedSpeech);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: MyColors.textColor),
        actions: [ IconButton(
          onPressed:
          _deleteNote,
          icon:
          Icon(Icons.delete),
        ),
          IconButton(
            onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
            icon:
            Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          ),
        ],
        centerTitle: true,
        title: TextField(
          style: TextStyle(color: MyColors.textColor),
          controller: _textTitleEditingController,
          decoration: InputDecoration(
            hintText: 'Enter your note Title...',
            hintStyle: TextStyle(color: MyColors.textColor),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: MyColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display recognized speech
              Text(
                'Recognized Speech:',
                style: TextStyle(color: MyColors.textColor),
              ),
              Text(
                _recognizedSpeech, // Display recognized speech
                style: TextStyle(color: MyColors.textColor),
              ),
              SizedBox(height: 16),
              TextField(
                style: TextStyle(color: MyColors.textColor),
                controller: _textEditingController,
                maxLines: null, // Allow for multiline input
                decoration: InputDecoration(
                  hintText: 'Enter your note here...',
                  hintStyle: TextStyle(color: MyColors.textColor),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FloatingActionButton(
            backgroundColor: MyColors.primaryColor, // Adjust color as needed
            child: Icon(Icons.camera_alt,
                color: MyColors.inactiveColor), // Replace with desired icon
            onPressed: () {
              _pickImage();

            },
          ),
          SizedBox(width: 16),

          FloatingActionButton(
            backgroundColor: MyColors.primaryColor, // Adjust color as needed
            child: Icon(Icons.help,
                color: MyColors.inactiveColor), // Replace with desired icon
            onPressed: () {
              _showChatDialog();
            },
          ),
          SizedBox(width: 16), // Adjust spacing between buttons as needed
          _isSaving
              ? CircularProgressIndicator() // Show loading indicator while saving
              : FloatingActionButton(
            backgroundColor: MyColors.primaryColor,
            child: Icon(Icons.save, color: MyColors.inactiveColor),
            onPressed: _isSaving
                ? null
                : _saveNote, // Disable button if saving is in progress
          ),



        ],
      ),
    );
  }
  File? _Image;
  Future<void> _pickImage()async {
    final _pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (_pickedImage != null){
      setState(() {
        _Image = File(_pickedImage.path);
        _processImage();
      });
    }

  }

  Future<void> _processImage() async {
    final inputImage = InputImage.fromFilePath(_Image!.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;

    // Ensure extracted text starts with a new line
    extractedText = '\n$extractedText';

    setState(() {
      // Append extracted text to the current text in the note
      _textEditingController.text += extractedText;
    });
  }



  Future<void> _showChatDialog() async {
    String userInput = '';
    final TextEditingController textEditingController =
    TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assistant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(labelText: 'Enter your query'),
                  onChanged: (value) {
                    userInput = value;
                  },
                ),
                SizedBox(height: 16),
                Text('Note Content:'),
                Text(_textEditingController.text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _chatWithGPT(userInput);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }





  Future<void> _chatWithGPT(String userInput) async {
    final List<Map<String, String>> messages = [];
    const String OpenAiKey = 'ChatGPT-Key';

    messages.add({
      'role': 'user',
      'content': userInput,
    });
    messages.add({
      'role': 'user',
      'content': _textEditingController.text,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
          'Bearer ${dotenv.env["GPT"]}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
        jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        print(content);

        messages.add({
          'role': 'assistant',
          'content': content,
        });

        // Show dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Assistant'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: messages
                      .map(
                        (message) => ListTile(
                      title: Text(
                        message['role'] == 'user'
                            ? 'You'
                            : 'Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(message['content']!),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                      .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        print('An internal error occurred');
      }
    } catch (e) {
      print(e.toString());
    }
  }


  // Function to save the note
  Future<void> _saveNote() async {
    setState(() {
      _isSaving = true; // Set saving flag to true when saving starts
    });
    try {
      // Check if it's a new note or an existing one
      if (widget.noteId.isEmpty) {
        // Add a new document to Firestore
        await FirebaseFirestore.instance
            .collection('HCI-users')
            .doc(currentUser!.email!)
            .collection("Notes")
            .doc()
            .set({
          'noteTitle': _textTitleEditingController.text,
          'noteDate': DateTime.now().toString(),
          'note': _textEditingController.text,
          'favorate': false,
        });
      } else {
        // Update an existing document in Firestore
        await FirebaseFirestore.instance
            .collection('HCI-users')
            .doc(currentUser!.email!)
            .collection("Notes")
            .doc(widget.noteId)
            .update({
          'noteTitle': _textTitleEditingController.text,
          'noteDate': DateTime.now().toString(),
          'note': _textEditingController.text,
        });
      }

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Note stored successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the AlertDialog
                if (!widget.noteId.isEmpty) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
                }
                setState(() {
                  // Clear text fields and reset saving flag
                  _textEditingController.clear();
                  _textTitleEditingController.clear();
                  _isSaving = false;
                  // Animate to page 0 in the page controller
                  widget.pageController.animateToPage(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.bounceIn);
                });
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error if saving fails
      print('Error storing note: $e');
      setState(() {
        _isSaving = false; // Reset saving flag if an error occurs
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _deleteNote() async {
    try {
      print(widget.noteId);
      print("here was ot");
      if (widget.noteId != "") {
        // If the note has an ID (i.e., it's an existing note), delete it from Firestore
        await FirebaseFirestore.instance
            .collection('HCI-users')
            .doc(currentUser!.email!)
            .collection("Notes")
            .doc(widget.noteId)
            .delete();

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Note deleted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the AlertDialog
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()));
                  setState(() {
                    // Clear text fields and reset saving flag
                    _textEditingController.clear();
                    _textTitleEditingController.clear();
                    _isSaving = false;
                    // Animate to page 0 in the page controller
                    widget.pageController.animateToPage(0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.bounceIn);
                  });
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // If the note doesn't have an ID, it's a new note, so just clear the text fields
        _textEditingController.clear();
        _textTitleEditingController.clear();
        // Animate to page 0 in the page controller
        widget.pageController.animateToPage(0,
            duration: Duration(milliseconds: 300), curve: Curves.bounceIn);

      }
    } catch (e) {
      // Show error if deletion fails
      print('Error deleting note: $e');
    }
  }
}
