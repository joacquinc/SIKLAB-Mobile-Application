import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:siklabproject/users/fragments/userProfile.dart';
import '../../api_connection/api_connection.dart';
import '../userPreferences/user_preferences.dart';

class userSettingsPage extends StatefulWidget {
  String _mobileNumber;

  userSettingsPage(this._mobileNumber, {super.key});

  @override
  State<userSettingsPage> createState() => _UserSettingsPageState();
}

  /*signOutUser() async {
      var resultResponse = await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.grey,
          title: const Text (
            "Logout",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure\nyou want to log out?",
          ),
          actions: [
            TextButton(
              onPressed: (){
                Get.back();
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.black, 
                ),
              ),
            ),
            TextButton(
              onPressed: (){
                Get.back(result: "loggedOut");
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black, 
                ),
              ),
            ),
          ],
        ),
      );

      if(resultResponse == "loggedOut"){
          //remove user data from local storage
          RememberUser.removeUserInfo()
            .then((value){
              Get.off(loginPage());
            }
          );
      }else{

      }
    }*/



class _UserSettingsPageState extends State<userSettingsPage> {
  void _backButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userProfile(widget._mobileNumber)),
    );
  }

  /*void _stay() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userSettingsPage(widget._mobileNumber)),
    );
  }*/

  late Color myColor;
  late Size mediaSize;
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController barangayController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  var counter = 5;
  late Timer _timer;

  late bool _passwordVisible;

  late String validNum;
  var contactNumController;
  String usernameFound = '';
  String barangayFound = '';

  @override
  void initState() {
    print(widget._mobileNumber);
    validNum = widget._mobileNumber;
    contactNumController = TextEditingController(text: validNum);
    //userProfilePHP(contactNumController.text);
    //verifyContactNum(contactNumController.text);
    super.initState();
  }
  
  /*updateUser(String contactNum, String newUsername) async {
    var response = await http.post(
      Uri.parse(API.updateUsername),
      body: {
        'contactNum' : contactNumController.text,
        'username': usernameFound,
      },
    );

    if (response.statusCode == 200) {
      // Handle the response here
      Fluttertoast.showToast(msg: "Username updated successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to update username");
    }
  }*/

  Future<void> updateUsername() async {
    String username = usernameFound;
    String contactNum = contactNumController.text;
    
    var url = Uri.parse(API.updateUsername);
    var response = await http.post(url, body: {
      'username': username,
      'contactNum': contactNum,
    });

    if (response.statusCode == 200) {
      // Successfully updated the username
      Fluttertoast.showToast(msg: "Username updated successfully");
      _backButton();

    } else {
      Fluttertoast.showToast(msg: "Failed to update username");
    }
  }

  Future<void> updatePassword() async {
    String password = newPasswordController.text;
    String contactNum = contactNumController.text;
    
    var url = Uri.parse(API.updatePassword);
    var response = await http.post(url, body: {
      'password': password,
      'contactNum': contactNum,
    });

    if (response.statusCode == 200) {
      // Successfully updated the username
      debugPrint("New Password: ${newPasswordController.text}");
      Fluttertoast.showToast(msg: "Password updated successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to update password");
    }
  }

  /*Future<String?> userProfilePHP(String contactNum) async{
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
  }*/

  /*Future<void> verifyContactNum(String contactNum) async {
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
  }*/

  void _countdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
        Navigator.pushNamed(context, '/LoginPage');
      }
    });
  }

  void _countLog() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
        RememberUser.removeUserInfo().then((value){Navigator.pushNamed(context, '/LoginPage');});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _showChangePasswordDialog() {
    _passwordVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildGreyText("New password"),
                _buildPasswordInputField(newPasswordController,
                    isPassword: true, isObscure: _passwordVisible),
                const SizedBox(height: 15),
                _buildGreyText("Confirm new password"),
                _buildPasswordInputField(confirmPasswordController,
                    isPassword: true, isObscure: _passwordVisible),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("New Password: ${newPasswordController.text}");
                    debugPrint("CNP: ${confirmPasswordController.text}");

                    _passwordValidation(
                        newPasswordController.text,
                        confirmPasswordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    shadowColor: myColor,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Save"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                      shape: const StadiumBorder(),
                      elevation: 20,
                      shadowColor: myColor,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("No")),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog() {
    _countdown();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(12.0),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_sharp,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 25),
                  Text(
                    "Successfully Updated",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Redirecting to the user dashboard...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(12.0),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_sharp,
                  size: 100,
                  color: Color.fromARGB(255, 255, 0, 0),
                ),
                SizedBox(height: 25),
                Text(
                  "Error with Updating Details",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  "Please double check and try again.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogOutDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
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
                        _countLog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
                        shape: const StadiumBorder(),
                        elevation: 20,
                        shadowColor: myColor,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text("Yes")),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 214, 214, 214),
                        shape: const StadiumBorder(),
                        elevation: 20,
                        shadowColor: myColor,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text("Back")),
                ],
              ),
            ),
          );
        });
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
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/firetruck.png"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.4), BlendMode.dstATop),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  SingleChildScrollView(
                      physics: BouncingScrollPhysics(), child: _buildBottom()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Positioned(
        bottom: 0,
        child: Card(
          color: Colors.white.withOpacity(0.75),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Details",
          style: TextStyle(
            color: Color.fromRGBO(171, 0, 0, 1),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildGreyText(
            "For security and confidential reasons, you can only update your name. Please contact the administrator if you have any concerns."),
        const SizedBox(height: 25),
        _buildGreyText("Name"),
        _buildInputField(nameController, isName: true),
        const SizedBox(height: 30),
        
        _buildEditButton(),
        const SizedBox(height: 10),
        _buildChangePasswordButton(),
        const SizedBox(height: 10),
        //_buildLogOutButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPhone = false, bool isName = false, bool isBarangay = false}) {
    TextEditingController? textController;

    if (isName) {
      textController = TextEditingController();
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      child: TextField(
        controller: nameController,
        onChanged: (value) {
          if (isName) {
            usernameFound = value;
          }
          // Other processing for other cases.
        },
        inputFormatters: isName
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
              ]
            : null,
        decoration: InputDecoration(
          suffixIcon: isName
              ? const Icon(Icons.account_box)
              : isPhone
                  ? const Icon(Icons.phone_android_sharp)
                  : null,
        ),
        enabled: isName,
      ),
    );
  }


   Widget _buildEditButton() {
     return ElevatedButton(
       onPressed: () {
        if(usernameFound == '' || usernameFound == null){
          _showErrorDialog();
        }else{
          updateUsername();
          debugPrint(contactNumController.text);
          debugPrint(usernameFound);
        }
       },
       style: ElevatedButton.styleFrom(
         backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
         shape: const StadiumBorder(),
         elevation: 20,
         shadowColor: myColor,
         minimumSize: const Size.fromHeight(50),
       ),
       child: const Text("Update Information"),
     );
   }

  // void _updateButtonPressed() {
  //   debugPrint("Mobile Number: ${widget._mobileNumber}");
  //   debugPrint("Name: ${nameController.text}");
  //   debugPrint("Barangay: ${barangayController.text}");
  //   debugPrint("Mobile Number: ${mobileNumberController.text}");
  //   //u are wondering why these info are null on terminal, don't u worry wala pang database
  //
  //   if (nameController.text.isEmpty || nameController.text.trim().isEmpty) {
  //     _showErrorDialog();
  //   } else {
  //     debugPrint("Happy kiddo");
  //   }
  // }

  Widget _buildChangePasswordButton() {
    return ElevatedButton(
      onPressed: () {
        _showChangePasswordDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Change Password"),
    );
  }

  Widget _buildLogOutButton() {
    return ElevatedButton(
      onPressed: () {
        _showLogOutDialog();
        //signOutUser();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Log Out"),
    );
  }

  Widget _buildPasswordInputField(TextEditingController controller,
      {isPassword = false, isObscure = true}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(_passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                )
              : null,
        ),
        obscureText: isPassword ? !isObscure : false,
      ),
    );
  }

  void _passwordValidation(String newPassword, String confirmPassword) {
    debugPrint("New Password: $newPassword");
    debugPrint("Confirm New Password: $confirmPassword");

    if (newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      debugPrint("May error sa input pre");
      _showErrorDialog();
    } else if (newPassword != confirmPassword) {
      debugPrint("Di same password pre");
    } else {
      debugPrint("YAY PASOK");
      updatePassword();
      _showDialog();

    }
  }
}
