import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:siklabproject/users/fragments/changePasswordPage.dart';
import 'package:siklabproject/users/fragments/forgotPasswordPage.dart';

class OTP_Screen extends StatefulWidget {
  static String verifyID = "";
  String phoneNumber;

  OTP_Screen(this.phoneNumber, {super.key});

  @override
  State<OTP_Screen> createState() => _OTP_ScreenState();
}

class _OTP_ScreenState extends State<OTP_Screen> {
  String? mtoken = "";
  final pinController = TextEditingController();

  late Color myColor;
  late Size mediaSize;

  late int _countdownSeconds = 90;
  Timer? _countdownTimer;

  var counter = 3;
  late Timer _timer;

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 60,
    textStyle: const TextStyle(fontSize: 22, color: Colors.black),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 241, 241, 241),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: Colors.black),
    ),
  );

  void _backButton() {
    Navigator.pushNamed(context, '/ForgotPasswordPage');
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

  void _VerificationComplete() {
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
      MaterialPageRoute(
          builder: (context) => changePasswordPage(widget.phoneNumber)),
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    requestPermission();

    if (_countdownTimer == null) {
      startCountdownTimer();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel the timer if it exists
    super.dispose();
  }

  void startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User Granted Permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User denied permission");
    }
  }

  void _resendOTP() async {
    try {
      // Call verifyPhoneNumber again to resend OTP
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle verification completion if auto-retrieval is enabled
          // Not needed in this case since we're using manual code entry
        },
        verificationFailed: (FirebaseAuthException e) {
          defaultPinTheme.copyBorderWith(
            border: Border.all(color: Colors.redAccent),
          );
          pinController.text = "";
          print("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) async {
          OTP_Screen.verifyID = verificationId;
          print("OTP Resent!");
          _countdownSeconds = 60;
          startCountdownTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // This callback will be invoked when the auto-retrieval of OTP times out
          // Not needed in this case since we're using manual code entry
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print("Error resending OTP: $e");
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "OTP Verification",
          style: TextStyle(
            color: Color.fromRGBO(171, 0, 0, 1),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Enter one-time password sent on "),
        _buildGreyText(widget.phoneNumber),
        const SizedBox(height: 20),
        _buildPinputField(),
        const SizedBox(height: 20),
        Text(
          _countdownSeconds > 0
              ? 'Did not receive OTP? Resend in $_countdownSeconds seconds'
              : 'Did not receive OTP? Resend now!',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 15),
        _buildResendOTPButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    );
  }

  Widget _buildPinputField() {
    return Pinput(
      //androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
      controller: pinController,
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          border: Border.all(color: Colors.black),
        ),
      ),
      onCompleted: (pin) async {
        print(pin);
        try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: forgotPasswordPage.verifyID,
            smsCode: pin,
          );

          await auth.signInWithCredential(credential);
          _VerificationComplete();
        } catch (e) {
          defaultPinTheme.copyBorderWith(
            border: Border.all(color: Colors.redAccent),
          );
          print(pin);
          print("Mali otp mo pre");
          print(e);
          pinController.text = "";
        }
      },
    );
  }

  Widget _buildResendOTPButton() {
    return ElevatedButton(
      onPressed: _countdownSeconds > 0 ? null : _resendOTP,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(350, 50),
        shape: const StadiumBorder(),
        shadowColor: const Color.fromRGBO(105, 105, 105, 1),
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
      ),
      child: const Text(
        "Resend OTP",
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
