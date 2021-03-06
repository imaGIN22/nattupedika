import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nattupedika/Screens/privacypolicy.dart';
import 'package:nattupedika/models/user.dart';
import 'package:nattupedika/services/auth.dart';
import 'package:nattupedika/services/db.dart';
import 'package:nattupedika/services/notification.dart';

import 'EmergencyTab.dart';
import 'HealthcareTab.dart';
import 'PharmacyTab.dart';
import 'StoresTab.dart';

class CustomerHomePage extends StatefulWidget {
  final User user;

  CustomerHomePage({Key key, @required this.user}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;
  String username = '';

  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  final NotificationService _notification = NotificationService();

//  static const TextStyle optionStyle =
//      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final List<Widget> _widgetOptions = <Widget>[
    Stores(),
    Pharmacy(),
    HealthCare(),
    Emergency(),
  ];

  @override
  void initState() {
    super.initState();
    _notification.registerNotification(widget.user.uid);
    _notification.configLocalNotification();
    _db.getUserName(widget.user.uid).then((value) => username = value);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> onBackPress() {
    _exitDialog();
    return Future.value(false);
  }

  Future<void> _exitDialog() async {
    switch (await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Exit app'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure to exit app?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, 0);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, 1);
                },
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nattupeedikaa'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage:
                            AssetImage("images/emergency_avatar.jpg"),
                        radius: 60.0,
                      ),
                      Text(username),
                    ],
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    title: Text("About"),
                    onTap: () => showAboutDialog(
                        context: context,
                        applicationVersion: '1.1.1',
                        applicationIcon: Image.asset('images/app_icon.png'),
                        applicationName: 'Nattupedika',
                        applicationLegalese:
                            'This application can be used by all audiences.',
                        children: [
                          Text(
                              'An app to connect local businesses with local people which enables people to buy groceries from them.')
                        ]),
                    leading: Icon(Icons.info_outline),
                  ),
                  ListTile(
                    title: Text("Help"),
                    leading: Icon(Icons.help),
                  ),
                  ListTile(
                    title: Text("Log Out"),
                    leading: Icon(Icons.power_settings_new),
                    onTap: () async {
                      await _auth.signOut(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.text_format),
                    title: Text('Privacy policy'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        body: WillPopScope(
            child: _widgetOptions[_selectedIndex], onWillPop: onBackPress),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.green,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.green,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                title: Text('Stores'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_pharmacy),
                title: Text('Pharmacy'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital),
                title: Text('HealthCentre'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call),
                title: Text('Emergency'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
