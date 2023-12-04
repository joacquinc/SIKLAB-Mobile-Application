import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siklabproject/users/fragments/newUserDashboard.dart';
import 'package:siklabproject/users/fragments/userSettingsPage.dart';
import 'package:siklabproject/users/userPreferences/user_preferences.dart';
import '../userPreferences/current_user.dart';
import 'package:http/http.dart' as http;
import '../../api_connection/api_connection.dart';

class userProfile extends StatefulWidget {
  String _mobileNumber;

  userProfile(this._mobileNumber, {super.key});

  @override
  State<userProfile> createState() => userProfileState();
}

class userProfileState extends State<userProfile> {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  late Color myColor;
  late Size mediaSize;

  var counter = 5;
  late Timer _timer;

  late String validNum;
  var contactNumController;
  String usernameFound = '';
  String barangayFound = '';

  @override
  void initState(){
    print(widget._mobileNumber);
    validNum = widget._mobileNumber;
    contactNumController = TextEditingController(text: validNum);
    userProfileEdit(contactNumController.text);
    verifyContactNum(contactNumController.text);
  }

  Future<String?> userProfileEdit(String contactNum) async{
    final response = await http.post(
    Uri.parse(API.getUsername),
    body: {'contactNum': contactNum},
  );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData.containsKey('username')) {
        usernameFound = jsonData['username'].toString();
      } else {
      }
    }else {
      throw Exception('Failed to fetch userID');
    }
  }

  Future<void> verifyContactNum(String contactNum) async {
    final response = await http.post(
      Uri.parse(API.getBarangay),
      body: {'contactNum': contactNum},
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData.containsKey('barangay')) {
        setState(() {
          barangayFound = jsonData['barangay'];
        });
      } else if (jsonData.containsKey('error')) {
        setState(() {
          barangayFound = jsonData['error'];
        });
      } else {
        setState(() {
          barangayFound = "ContactNum not found";
        });
      }
    } else {
      setState(() {
        barangayFound = "Failed to verify contactNum";
      });
    }
  }
  
  void _userSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userSettingsPage(widget._mobileNumber)),
    );
  }

  void _backButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => newUserDashboard(widget._mobileNumber)),
    );
  }

  void _countLog() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
        RememberUser.removeUserInfo().then((value) {
          Navigator.pushNamed(context, '/LoginPage');
        });
      }
    });
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 350,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: 100,
                  color: Colors.red,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      builder: (ctx) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                      context: context,
                    );
                    _countLog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    shadowColor: myColor,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    shadowColor: myColor,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("No"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        _backButton();
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("USER DASHBOARD"),
          backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
          elevation: 50.0,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Center(
            child: Image.network(
              "https://i.imgur.com/nTKKdMR.png",
              width: 240,
            ),
          ),
          const SizedBox(height: 15),
          userInfoItemProfile(Icons.person, usernameFound),
          const SizedBox(height: 15),
          userInfoItemProfile(Icons.home, barangayFound),
          const SizedBox(height: 15),
          userInfoItemProfile(Icons.numbers, contactNumController.text),
          const SizedBox(height: 40),
          _buildEditProfileButton(),
          const SizedBox(height: 15),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget userInfoItemProfile(IconData iconData, String userData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: const Color.fromARGB(255, 241, 239, 239),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(width: 16),
          Text(
            userData,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton(
      onPressed: () {
        // _showEdit();
        _userSettings();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text(
        "Edit Profile",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton(
      onPressed: () {
        _showLogOutDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text(
        "Sign Out",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  // Widget _circularProgressIndicator() {

  // }
}
