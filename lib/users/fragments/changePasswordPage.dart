import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../api_connection/api_connection.dart';

class changePasswordPage extends StatefulWidget {
  String mobileNumber;

  changePasswordPage(this.mobileNumber, {super.key});

  @override
  State<changePasswordPage> createState() => _changePasswordPageState();
}

class _changePasswordPageState extends State<changePasswordPage> {
  void _backButton() {
    Navigator.pushNamed(context, '/LoginPage');
  }

  late Color myColor;
  late Size mediaSize;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  var counter = 5;
  late Timer _timer;

  late bool _passwordVisible;
  late String validNum;
  var contactNumController;
  var newNumber;
  var _mobileNumber;

  String changeFirstThreeLetters(String mobileNumber, String number) {
  if (mobileNumber.length >= 3) {
    // Combine the new letters with the remaining part of the original string.
    return number + mobileNumber.substring(3);
  } else {
    // Handle cases where the original string is shorter than 3 characters.
    // You can choose to return the original string or handle it differently.
    return mobileNumber;
  }
}

  @override
  void initState() {
    print(widget.mobileNumber);
    validNum = widget.mobileNumber;
    contactNumController = TextEditingController(text: validNum);
    _mobileNumber = contactNumController.text;
    newNumber = changeFirstThreeLetters(_mobileNumber, "0");
    super.initState();
    _passwordVisible = false;
  }

  Future<void> updatePassword() async {
    String password = passwordController.text;
    String contactNum = newNumber;
    
    var url = Uri.parse(API.updatePassword);
    var response = await http.post(url, body: {
      'password': password,
      'contactNum': contactNum,
    });

    if (response.statusCode == 200) {
      // Successfully updated the username
      debugPrint("New Password: ${passwordController.text}");
      Fluttertoast.showToast(msg: "Password updated successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to update password");
    }
  }

  void _countdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
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
        Navigator.pushNamed(context, '/LoginPage');
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
                    "Password Changed",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Redirecting to the login screen...",
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
                    "Error with Signing Up",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Please fill up the necessary information.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showPasswordDoNotMatchDialog() {
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
                    "Passwords do not match.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Please check your password and try again.",
                    style: TextStyle(fontSize: 16),
                  ),
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
          "Change your Password",
          style: TextStyle(
            color: Color.fromRGBO(171, 0, 0, 1),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("New Password"),
        _buildInputField(passwordController,
            isPassword: true, isObscure: _passwordVisible),
        const SizedBox(height: 20),
        _buildGreyText("Confirm Password"),
        _buildInputField(confirmPasswordController,
            isPassword: true, isObscure: _passwordVisible),
        const SizedBox(height: 20),
        _buildSubmitButton(),
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
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off),
          ),
        ),
        obscureText: isPassword ? !isObscure : false,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (passwordController.text.isEmpty ||
            confirmPasswordController.text.isEmpty) {
          _showErrorDialog();
        } else if (passwordController.text != confirmPasswordController.text) {
          _showPasswordDoNotMatchDialog();
        } else {
          updatePassword();
          debugPrint("Password: ${passwordController.text}");
          debugPrint("Number: $newNumber");
          _showDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Submit"),
    );
  }
}
