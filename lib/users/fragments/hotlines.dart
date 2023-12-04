import 'package:flutter/material.dart';
import 'package:siklabproject/users/fragments/newUserDashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class Hotlines extends StatefulWidget {
  String _mobileNumber;

  Hotlines(this._mobileNumber, {super.key});

  @override
  State<Hotlines> createState() => HotlinesState();
}

class HotlinesState extends State<Hotlines> {
  final List<Map<String, dynamic>> hotlines = [
    {'name': 'ANTIPOLO CITY EMERGENCY HOTLINE', 'number': '8696-9911'},
    {'name': 'NATIONAL HOTLINE', 'number': '911'},
    {'name': 'PNP ', 'number': '117'},
    {'name': 'BFP Central Fire Station', 'number': '8871-2865'},
    {'name': 'BFP Dela Paz Sub Station', 'number': '8571-4648'},
    {'name': 'BFP Mayamot Sub Station', 'number': '8250-0497'},
  ];

  final List<String> BFPManual = [
    'https://bfp.gov.ph/wp-content/uploads/2015/09/BFP-Operational-Procedures-Manual.pdf',
  ];

  _launchPDF(BuildContext context, String pdfUrl) async {
    // ignore: deprecated_member_use
    if (await canLaunch(pdfUrl)) {
      // ignore: deprecated_member_use
      await launch(pdfUrl);
    } else {
      // If the PDF URL couldn't be launched, you can handle the error here.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There is an error opening the PDF file.'),
        ),
      );
    }
  }

  void _backButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => newUserDashboard(widget._mobileNumber)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backButton();
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOVERNMENT HOTLINES',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backButton,
          ),
          backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: const Color.fromARGB(255, 34, 34, 34),
                    backgroundColor: const Color.fromARGB(255, 206, 205, 205),
                  ),
                  onPressed: () {
                    _launchPDF(context, BFPManual[0]);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(
                        top: 24.0, bottom: 24.0, left: 24.0, right: 24.0),
                    child: Text(
                      "BFP ONLINE MANUAL LIBRARY ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: hotlines.length,
                itemBuilder: (context, index) {
                  final hotline = hotlines[index];
                  return Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: ListTile(
                      title: Text(
                        hotline['name'],
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        hotline['number'],
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      trailing: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(255, 11, 11, 1),
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.phone,
                          ),
                          onPressed: () {
                            // ignore: deprecated_member_use
                            launch('tel:${hotline['number']}');
                          },
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
