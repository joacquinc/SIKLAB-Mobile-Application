import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siklabproject/api_connection/api_connection.dart';
import 'package:siklabproject/users/fragments/hotlines.dart';
import 'package:siklabproject/users/fragments/userProfile.dart';
import 'package:siklabproject/users/model/report.dart';
import 'package:siklabproject/users/fragments/testReport.dart';
import '../userPreferences/current_user.dart';
import 'package:http/http.dart' as http;
import '../userPreferences/user_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:url_launcher/url_launcher.dart';

class newUserDashboard extends StatefulWidget {
  CurrentUser rememberCurrentUser = Get.put(CurrentUser());

  String _mobileNumber;

  newUserDashboard(this._mobileNumber, {super.key});

  @override
  State<newUserDashboard> createState() => _newUserDashboardState();
}

class _newUserDashboardState extends State<newUserDashboard> {
  void _backButton() {
    Navigator.pushNamed(context, '/LoginPage');
  }

  void _goToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userProfile(widget._mobileNumber)),
    );
  }

  void _goToHotlines() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Hotlines(widget._mobileNumber)),
    );
  }

  void _goToReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => userReportPagev2(widget._mobileNumber)),
    );
  }

  var counter = 3;
  late Timer _timer;

  void _countdown() {
    _showErrorDialog();
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

  _showErrorDialog() {
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
                  Icons.warning_amber_outlined,
                  size: 100,
                  color: Color.fromARGB(255, 255, 137, 2),
                ),
                SizedBox(height: 25),
                Text(
                  "Session Expired",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  "Redirecting you to the login page.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Item> items = [];
  String? validNum;
  var contactNumController;

  @override
  void initState() {
    super.initState();
    print(widget._mobileNumber);
    validNum = widget._mobileNumber;
    contactNumController = TextEditingController(text: validNum);
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse(API.displayData));

    if (response.statusCode == 200) {
      final List<dynamic> jsonItems = jsonDecode(response.body);
      setState(() {
        items = jsonItems.map((json) => Item.fromJson(json)).toList();
      });
      if (widget._mobileNumber == null || widget._mobileNumber.isEmpty) {
        _countdown();
      }
    } else {
      throw Exception('Failed to load items from the server');
    }
  }

  late Size mediaSize;
  late Color myColor;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        //_backButton();
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("USER DASHBOARD"),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.settings),
            //   onPressed: () {
            //     _goToUserSettings();
            //   },
            // ),
            IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  _goToUserProfile();
                }),
          ],
          backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
          elevation: 50.0,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: _buildTop(),
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      "Recent Reports from Antipolo City",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              _buildListView(),
            ],
          ),
        ),
      ),
    );
    /*return GetBuilder(
      init: CurrentUser(),
      initState: (currentState){
        _rememberCurrentUser.getUserInfo();
      },
      builder: (controller){
        return Scaffold(

        );
      },
    );*/
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color.fromARGB(255, 253, 250, 250),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _goToReportPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 212, 212),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.fire_truck_outlined),
                      SizedBox(width: 50),
                      Text("REPORT FIRE"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _goToHotlines();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 212, 212),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 50),
                      Text("VIEW HOTLINES"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _callEmergencyNumber();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 214, 212, 212),
                    shape: const StadiumBorder(),
                    elevation: 20,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.call),
                      SizedBox(width: 50),
                      Text("CALL EMERGENCY"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _callEmergencyNumber() async {
    const url = 'tel:911';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: items.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.fireplace),
              SizedBox(width: 30),
              Flexible(
                child: Text(
                  item.addressRep, // Display the addressRep from the 'items' list
                  overflow: TextOverflow.ellipsis, // Add this line
                ),
              ),
            ],
          ),
          trailing: Flexible(
            child: Text(
              item.timeStamp, // Display the timeStamp from the 'items' list
              overflow: TextOverflow.ellipsis, // Add this line
            ),
          ),
        );
      },
    );
  }*/

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: items.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final item = items[index];

        bool isSelected = false;

        return InkWell(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
            });
            _showLocationOnMap(item.latitudeRep, item.longitudeRep);
          },
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.fireplace,
                  color: isSelected ? Colors.red : Colors.black,
                ),
                SizedBox(width: 30),
                Flexible(
                  child: Text(
                    item.addressRep,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Flexible(
              child: Text(
                item.timeStamp,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.red : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocationOnMap(String latitudeRep, String longitudeRep) {
    final double latitude = double.tryParse(latitudeRep ?? '0.0') ?? 0.0;
    final double longitude = double.tryParse(longitudeRep ?? '0.0') ?? 0.0;

    final map = FlutterMap(
      options: MapOptions(
        center: latlong.LatLng(latitude, longitude),
        zoom: 15.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoiZXpla2llbGNhcHoiLCJhIjoiY2xnODdtcWxhMDcxdjNocWxpOTJpeXlvdCJ9.hYBJ8R_gc4RT9jx0R0nteg',
            'id': 'mapbox/streets-v11',
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: latlong.LatLng(latitude, longitude),
              builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red, // Customize the marker's color
                  size: 40.0, // Customize the marker's size
                ),
              ),
            ),
          ],
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 300, // Adjust the height as needed
              width: 300,
              child: map,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        });
  }
}
