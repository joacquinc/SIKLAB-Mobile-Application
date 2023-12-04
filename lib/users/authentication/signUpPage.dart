import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:siklabproject/api_connection/api_connection.dart';
import 'package:siklabproject/users/model/user.dart';

class signUpPage extends StatefulWidget {
  @override
  State<signUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<signUpPage> {
  void _backButton() {
    Navigator.pushNamed(context, '/LoginPage');
  }

  late Color myColor;
  late Size mediaSize;
  var formKey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var contactNumController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  final barangays = [
    "Brgy. Bagong Nayon",
    "Brgy. Beverly Hills",
    "Brgy. Cupang",
    "Brgy. Dalig",
    "Brgy. Dela Paz",
    "Brgy. Inarawan",
    "Brgy. Mambugan",
    "Brgy. Mayamot",
    "Brgy. San Isidro",
    "Brgy. San Jose",
    "Brgy. San Luis",
    "Brgy. San Roque",
    "Brgy. Santa Cruz"
  ];
 String barangay = 'Brgy. Bagong Nayon'; // Initially selected item

  var counter = 5;
  late Timer _timer;

  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

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
                    "Successfully Signed Up!",
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

validateNumber() async {
    try{
      var resVal = await http.post(
        Uri.parse(API.validateNum),
        body:{
          'contactNum': contactNumController.text.trim(),
        }
      );

      if(resVal.statusCode == 200){
        debugPrint('Passed validateNumber');
        var resBody = jsonDecode(resVal.body);

        if(resBody['numberFound']){
          Fluttertoast.showToast(msg: "Contact Number is already in use");
        }else{
          registerUser();
        }
      }
    }catch(e){
      print(e.toString());
        Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerUser() async {
    User userModel = User(
      1,
      usernameController.text.trim(),
      barangay,
      contactNumController.text.trim(),
      passwordController.text.trim(),
      );

      try{
        var res = await http.post(
          Uri.parse(API.signUp),
          body: userModel.toJson(),
        );

        if(res.statusCode == 200){
          debugPrint('Passed registerUser');
          var resBodySign = jsonDecode(res.body);
          if(resBodySign['Success'] == true){
            Fluttertoast.showToast(msg: "Congratulations!\nYou have Signed Up Successfully.");

            setState((){
              usernameController.clear();
              contactNumController.clear();
              passwordController.clear();
              confirmPasswordController.clear();
            });
            _showDialog();
          }else{
            Fluttertoast.showToast(msg: "Error Occured, Try Again");
            setState((){
              usernameController.clear();
              contactNumController.clear();
              passwordController.clear();
            });
          }
        }
      }catch(e){
        print(e.toString());
        Fluttertoast.showToast(msg: e.toString());
      }
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
                    physics: const BouncingScrollPhysics(),
                    child: _buildBottom(),
                  ),
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
          "Hello!",
          style: TextStyle(
            color: Color.fromRGBO(171, 0, 0, 1),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildGreyText("Please fill up your information"),
        const SizedBox(height: 25),
        _buildGreyText("Name"),
        _buildInputField(usernameController, isName: true),
        const SizedBox(height: 20),
        _buildGreyText("Barangay"),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: barangay,
            items: barangays.map(_barangayItems).toList(),
            onChanged: (value) => setState(
              () {
                barangay = value!;
                debugPrint(value);
              },
            ),
            hint: const Text("Select Barangay"),
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Mobile Number"),
        _buildInputField(contactNumController, isPhone: true),
        const SizedBox(height: 20),
        _buildGreyText("Password"),
        _buildInputField(passwordController,
            isPassword: true, isObscure: _passwordVisible),
        const SizedBox(height: 20),
        _buildGreyText("Confirm Password"),
        _buildInputField(confirmPasswordController,
            isPassword: true, isObscure: _passwordVisible),
        const SizedBox(height: 20),
        _buildSignUpButton(),
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
      {isPassword = false, isPhone = false, isName = false, isObscure = true}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPassword
            ? TextInputType.text
            : isPhone
                ? TextInputType.phone
                : TextInputType.text,
        inputFormatters: isPhone
            ? [LengthLimitingTextInputFormatter(11)]
            : isName
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ]
                : null,
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
              : isPhone
                  ? const Icon(Icons.phone_android_sharp)
                  : null,
        ),
        obscureText: isPassword ? !isObscure : false,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        if(barangay != null){
          validateNumber();
          debugPrint("Name: ${usernameController.text}");
          debugPrint("Barangay: $barangay");
          debugPrint("Mobile Number: ${contactNumController.text}");
          debugPrint("Password: ${passwordController.text}");
          debugPrint("Password: ${confirmPasswordController.text}");
        } else if (usernameController.text.isEmpty ||
            barangay == null ||
            contactNumController.text.isEmpty ||
            passwordController.text.isEmpty ||
            confirmPasswordController.text.isEmpty ||
            contactNumController.text.length < 11 ||
            usernameController.text.trim().isEmpty) {
          _showErrorDialog();
        } else if (passwordController.text != confirmPasswordController.text) {
          _showPasswordDoNotMatchDialog();
        } else {
          //registerUser();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Sign Up"),
    );
  }

  DropdownMenuItem<String> _barangayItems(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
}
