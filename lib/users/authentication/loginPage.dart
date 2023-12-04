import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../api_connection/api_connection.dart';
import '../fragments/newUserDashboard.dart';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../userPreferences/user_preferences.dart';

class loginPage extends StatefulWidget {
  @override
  State<loginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  void _backButton() {
    Navigator.pushNamed(context, '/Home');
  }

  late Color myColor;
  late Size mediaSize;

  bool rememberUser = false;

  late bool _passwordVisible;

  var counter = 3;
  late Timer _timer;

  var formKey = GlobalKey<FormState>();
  var contactNum = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;

  loginUserNow() async {
    try {
      var res = await http.post(
        Uri.parse(API.login),
        body: {
          "contactNum": contactNum.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        var resBodyLogin = jsonDecode(res.body);
        if (resBodyLogin['Success'] == true) {
          Fluttertoast.showToast(
              msg: "Congratulations!\nYou have Logged in Successfully.");

          User userInfo = User.fromJson(resBodyLogin["userData"]);

          await RememberUser.storeUser(userInfo);

          //Get.to(newUserDashboard(contactNum.text));

          _showDialog(contactNum.text);
          // ignore: use_build_context_synchronously
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
        } else {
          Fluttertoast.showToast(
              msg:
                  "Incorrect Credentials! \nPlease write correct contact number or password!");
          setState(() {
            contactNum.clear();
            passwordController.clear();
          });
        }
      }
    } catch (errorMsg) {
      print("Error :: " + errorMsg.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void _countdown(String mobileNumber) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
        debugPrint(mobileNumber);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => UserDashboard(mobileNumber)),
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => newUserDashboard(mobileNumber)),
        );
      }
    });
  }

  void _showDialog(String mobileNumber) {
    _countdown(mobileNumber);
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
                  "Success!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  "Logging in...",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                    "Credentials do not match.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Try again.",
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
          body: Stack(
            children: [
              Positioned(bottom: 0, child: _buildBottom()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
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
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 30),
        _buildGreyText("Mobile Number"),
        _buildInputField(contactNum, isPhone: true),
        const SizedBox(height: 20),
        _buildGreyText("Password"),
        _buildInputField(passwordController,
            isPassword: true, isObscure: _passwordVisible),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        const SizedBox(height: 10),
        _buildLoginButton(),
        const SizedBox(height: 10),
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
      {isPhone = false, isPassword = false, isObscure = true}) {
    return TextField(
      controller: controller,
      keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
      inputFormatters:
          isPassword ? null : [LengthLimitingTextInputFormatter(11)],
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off),
              )
            : isPhone
                ? const Icon(Icons.phone_android_sharp)
                : null,
      ),
      obscureText: isPassword ? !isObscure : false,
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
                value: rememberUser,
                onChanged: (value) {
                  setState(() {
                    rememberUser = value!;
                  });
                }),
            _buildGreyText("Remember Me"),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/ForgotPasswordPage');
          },
          child: _buildGreyText("I forgot my password"),
        )
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        debugPrint("Number: ${contactNum.text}");
        debugPrint("Password: ${passwordController.text}");
        if (contactNum != null) {
          loginUserNow();
          debugPrint("Passed");
        } else if (contactNum.text.isEmpty ||
            passwordController.text.isEmpty ||
            contactNum.text.length < 11) {
          _showErrorDialog();
        } else {}
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Login"),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        debugPrint("Signing up fool!");
        Navigator.pushNamed(context, '/SignUpPage');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Don't have an account? Sign up"),
    );
  }
}
