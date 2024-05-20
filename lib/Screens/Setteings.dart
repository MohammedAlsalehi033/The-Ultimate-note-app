import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Style/myColors.dart';  // Update the import path as needed
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = MyColors.isDarkMode;
  bool _notificationsEnabled = false;
  Color _selectedPrimaryColor = MyColors.primaryColor;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      MyColors.isDarkMode = _isDarkMode;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      int? primaryColorValue = prefs.getInt('primaryColor');
      if (primaryColorValue != null) {
        _selectedPrimaryColor = Color(primaryColorValue);
        MyColors.primaryColor = _selectedPrimaryColor;
      }
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
    prefs.setInt('primaryColor', _selectedPrimaryColor.value);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      MyColors.isDarkMode = value;
      _saveSettings();
    });
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      _saveSettings();
    });
  }

  void _changePrimaryColor(Color color) {
    setState(() {
      _selectedPrimaryColor = color;
      MyColors.primaryColor = color;
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: MyColors.textColor)),
        backgroundColor: MyColors.primaryColor,
      ),
      backgroundColor: MyColors.backgroundColor,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Dark Mode', style: TextStyle(color: MyColors.textColor)),
            value: _isDarkMode,
            onChanged: _toggleTheme,
          ),
          SwitchListTile(
            title: Text('Enable Notifications', style: TextStyle(color: MyColors.textColor)),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          ListTile(
            title: Text('Select Primary Color', style: TextStyle(color: MyColors.textColor)),
            trailing: CircleAvatar(
              backgroundColor: _selectedPrimaryColor,
            ),
            onTap: () {
              _showColorPicker();
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Primary Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedPrimaryColor,
              availableColors: [
                MyColors.defaultPrimaryColor,
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.orange[400]!,
                Colors.purple,
                Colors.brown,

              ],
              onColorChanged: _changePrimaryColor,
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
  }
}
