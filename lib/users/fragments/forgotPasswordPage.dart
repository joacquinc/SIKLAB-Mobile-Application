import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:siklabproject/otp_pinput.dart';

class forgotPasswordPage extends StatefulWidget {
  static String verifyID = "";
  @override
  State<forgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<forgotPasswordPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController mobileNumberController = TextEditingController();

  var phone = "";

  var counter = 3;
  late Timer _timer;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  void _BackButton() {
    Navigator.pushNamed(context, '/LoginPage');
  }

  void _countdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        counter--;
        print(counter);
      });
      if (counter == 0) {
        timer.cancel();
      }
    });
  }

  void _nextPage(String phoneNumber) {
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
    _countdown();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OTP_Screen(phoneNumber)),
    );
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
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
                    "Invalid Mobile Number.",
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
        _BackButton();
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
          "Enter your Mobile Number",
          style: TextStyle(
            color: Color.fromRGBO(171, 0, 0, 1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 35),
        _buildGreyText("Mobile Number"),
        _buildInputField(mobileNumberController),
        const SizedBox(height: 35),
        _buildSendOTPButton(),
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

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [LengthLimitingTextInputFormatter(11)],
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.phone_android_sharp),
      ),
    );
  }

  Widget _buildSendOTPButton() {
    return ElevatedButton(
      onPressed: () async {
        var mobileNumberRemoveFirstSubString =
            mobileNumberController.text.substring(1);
        var mobileNumberWithCountryCode =
            "+63$mobileNumberRemoveFirstSubString";

        print(mobileNumberWithCountryCode);

        if (mobileNumberWithCountryCode.length == 13) {
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: mobileNumberWithCountryCode,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (FirebaseAuthException e) {
              print(e);
            },
            codeSent: (String verificationId, int? resendToken) {
              forgotPasswordPage.verifyID = verificationId;
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
          _nextPage(mobileNumberWithCountryCode);
        } else {
          _showErrorDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Send OTP"),
    );
  }
}
