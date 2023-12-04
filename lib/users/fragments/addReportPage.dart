import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _hasInternet = true;

  String formattedDate = '';
  String reportID = '';

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();

    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(now);

    Random random = Random();
    int randomNumber = random.nextInt(100);

    reportID = formattedDate + randomNumber.toString();
    reportID = reportID.replaceAll("-", "");
    print(reportID);
  }

  Future<void> _checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _hasInternet = false;
      });
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REPORT FIRE INCIDENT',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Text(
              'Please enable SIKLAB to access your location.',
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
      ),
      body: Center(
        child: Center(
          child: _hasInternet
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(325, 175),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      shadowColor: const Color.fromRGBO(105, 105, 105, 1),
                      backgroundColor: const Color.fromRGBO(248, 248, 248, 1)),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Image.asset('assets/map.png', height: 90, width: 90),
                      const SizedBox(width: 25),
                      const Text("SELECT LOCATION",
                          style: TextStyle(
                              fontSize: 20, color: Color.fromRGBO(0, 0, 0, 1)))
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: !_hasInternet
          ? FloatingActionButton(
              backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
              onPressed: () {
                _showNoInternetDialog(context);
              },
              tooltip: 'Show Dialog',
              child: const Icon(Icons.warning),
            )
          : null,
    );
  }
}
