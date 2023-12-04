import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:siklabproject/users/fragments/newUserDashboard.dart';
import 'package:http/http.dart' as http;
import '../../api_connection/api_connection.dart';

class userReportPagev2 extends StatefulWidget {
  String _mobileNumber;

  userReportPagev2(this._mobileNumber);

  @override
  State<userReportPagev2> createState() => _UserReportPagev2State();
}

class _UserReportPagev2State extends State<userReportPagev2> {
  void _backButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => newUserDashboard(widget._mobileNumber)),
    );
  }

  var counter = 3;
  late Timer _timer;

  void _returnToDashboard(String mobileNumber) {
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

  late String _lat;
  late String _long;
  late double lat, long;
  var lat1;
  var long1;

  //late LatLng markerLocation = LatLng(14.55, 121.02);
  late LatLng markerLocation;
  late MapboxMapController mapController;
  late Symbol marker;

  LatLng coordinates = LatLng(14.6760, 121.0437);

  late String address = '';
//////////////////////////////////////////
  late String validNum;
  var contactNumController;
  var timeStamp = TextEditingController();
  String? userIdFound;
  String? barangay;
  String? formattedDateTime;
  String status = 'Not Resolved';
  String alarmSeverity = "Fire Alarm 1";

  late http.Client client;
  late http.Response response;

  Future<String?> fetchUserID(String contactNum) async {
    final response = await http.post(
      Uri.parse(API.getID),
      body: {'contactNum': contactNum},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData.containsKey('userID')) {
        userIdFound = jsonData['userID'].toString();
      } else {}
    } else {
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
          barangay = jsonData['barangay'];
        });
      } else if (jsonData.containsKey('error')) {
        setState(() {
          barangay = jsonData['error'];
        });
      } else {
        setState(() {
          barangay = "ContactNum not found";
        });
      }
    } else {
      setState(() {
        barangay = "Failed to verify contactNum";
      });
    }
  }

  submitReport() async {
    try {
      var res = await http.post(
        Uri.parse(API.subRep),
        body: {
          'userID': userIdFound,
          'contactNum': validNum,
          'timeStamp': formattedDateTime,
          'latitudeRep': _lat,
          'longitudeRep': _long,
          'barangay': barangay,
          'addressRep': address,
          'assistanceRep': assistance,
          'status': status,
        },
      );

      if (res.statusCode == 200) {
        var resBodySign = jsonDecode(res.body);
        if (resBodySign['Success'] == true) {
          Fluttertoast.showToast(msg: "Thank You for Submitting your Report!");

          _startSSE();

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
          _returnToDashboard(widget._mobileNumber);
        } else {
          Fluttertoast.showToast(msg: "Error Occured, Try Again");
        }
      }
    } catch (e) {
      print("I FOUND HIM CHIEF");
      print(e.toString());
      print("HE OVER HERE");
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _startSSE() async {
    try {
      var stream = await http.Client().send(http.Request(
          'GET', Uri.parse('https://siklabcentral.000webhostapp.com/sse.php')));
      stream.stream.transform(utf8.decoder).listen((data) {
        // Handle SSE data here
        print('Received: $data');
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  submitReportNew() async {
    try {
      var res = await http.post(
        Uri.parse(API.subRep),
        body: {
          'userID': userIdFound,
          'contactNum': validNum,
          'timeStamp': formattedDateTime,
          'latitudeRep': lat1.toString(),
          'longitudeRep': long1.toString(),
          'barangay': barangay,
          'addressRep': address,
          'assistanceRep': assistance,
          'status': status,
          'alarmSeverity' : alarmSeverity,
        },
      );

      if (res.statusCode == 200) {
        var resBodySign = jsonDecode(res.body);
        if (resBodySign['Success'] == true) {
          Fluttertoast.showToast(msg: "Thank You for Submitting your Report!");
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
          _returnToDashboard(widget._mobileNumber);
        } else {
          Fluttertoast.showToast(msg: "Error Occured, Try Again");
        }
      }
    } catch (e) {
      print("I FOUND HIM CHIEF");
      print(e.toString());
      print("HE OVER HERE");
      Fluttertoast.showToast(msg: e.toString());
    }
  }

//////////////////////////////////////////
  final assistanceList = [
    "None",
    "Police Assistance Needed",
    "Advance Cardiac Life Support Needed"
  ];
  String? assistance;

  @override
  void initState() {
    print(widget._mobileNumber);
    validNum = widget._mobileNumber;
    contactNumController = TextEditingController(text: validNum);
    verifyContactNum(contactNumController.text);
    //returnData();
    client = http.Client();
    _getLocation();
    super.initState();
    DateTime now = DateTime.now();
    formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  @override
  void dispose() {
    client.close(); // Close the client when the widget is disposed
    super.dispose();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _lat = '${position.latitude}';
      _long = '${position.longitude}';

      lat = double.parse(_lat);
      long = double.parse(_long);

      markerLocation = LatLng(lat, long);

      mapController
          .addSymbol(
            SymbolOptions(
              geometry: markerLocation,
              iconImage: 'assets/marker.png',
              iconSize: 0.2,
              // iconRotate: data['routes'][0]['legs'][0]['steps'][0]['intersections'][0]['bearings'][0].toDouble()
            ),
          )
          .then((value) => {marker = value});
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        debugPrint(
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}");
        lat = position.latitude;
        long = position.longitude;
        _lat = position.latitude.toString();
        _long = position.longitude.toString();
        _convertLatLngToAddress(lat, long);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _convertLatLngToAddress(double lat, double long) async {
    debugPrint(lat.toString());
    debugPrint(long.toString());
    final placemarks = await placemarkFromCoordinates(lat, long);

    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      final formattedAddress =
          '${placemark.street}, ${placemark.locality} ${placemark.postalCode}';
      setState(() {
        address = formattedAddress;
        debugPrint(address);
        debugPrint(barangay);
      });
    }
  }

  void _onMapCreated(MapboxMapController mapController) {
    this.mapController = mapController;
  }

  void _goToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => newUserDashboard(widget._mobileNumber)),
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
              'REPORT A FIRE INCIDENT',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              _goToDashboard();
            }),
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildMap(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  } // Default coordinates

  Widget _buildMap() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: MapboxMap(
        accessToken:
            'sk.eyJ1IjoiZXpla2llbGNhcHoiLCJhIjoiY2xpd2t2aTB5MGpwZzNzbjV3a20ycWpidSJ9.nCx9DsseQnku9gaDSmim9w',
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: coordinates, // Set the initial coordinates
          zoom: 14,
        ),
        styleString: 'mapbox://styles/ezekielcapz/cliwlgup1004t01qqg0avgzeq',
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: false,
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        dragEnabled: true,
        doubleClickZoomEnabled: true,
        myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
        myLocationRenderMode: MyLocationRenderMode.COMPASS,
        onMapClick: (a, coord) {
          setState(() {
            coordinates = coord; // Update the coordinates
          });

          mapController.updateSymbol(marker, SymbolOptions(geometry: coord));

          lat1 = coordinates.latitude;
          long1 = coordinates.longitude;
          _convertLatLngToAddress(lat1, long1);
        },
        onUserLocationUpdated: (UserLocation location) {},
      ),
    );
  }

  /*Widget _buildSetLocationButton() {
    return ElevatedButton(
      onPressed: () {
        print("Coordinates $coordinates");
        // var lat = coordinates.latitude;
        // var long = coordinates.longitude;
        // debugPrint("Lat: $lat");
        // debugPrint("Long: $long");
        // _convertLatLngToAddress(lat, long);
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        shadowColor: const Color.fromRGBO(105, 105, 105, 1),
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Set Location",
          style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }*/

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreyText("Address: $address"),
        const SizedBox(height: 20),
        _buildGreyText("Barangay: $barangay"),
        const SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: assistance,
            items: assistanceList.map(_assistanceItems).toList(),
            onChanged: (value) => setState(
              () {
                assistance = value;
                debugPrint(value);
              },
            ),
            hint: const Text("Select Special Assistance"),
          ),
        ),
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
        fontSize: 20,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        await fetchUserID(contactNumController.text);
        if (lat1 == null || long1 == null) {
          submitReport();
          debugPrint("User ID: $userIdFound");
          debugPrint("Mobile Number: ${contactNumController?.text}");
          debugPrint("Time: $formattedDateTime");
          debugPrint("Latitude: $lat1");
          debugPrint("Longitude: $long1");
          debugPrint("Barangay: $barangay");
          debugPrint("Address: $address");
          debugPrint("Assistance: $assistance");
          debugPrint("Alarm Severity: $alarmSeverity");
          debugPrint("-----------------------");
        } else {
          submitReportNew();
          debugPrint("User ID: $userIdFound");
          debugPrint("Mobile Number: ${contactNumController?.text}");
          debugPrint("Time: $formattedDateTime");
          debugPrint("Latitude: $_lat");
          debugPrint("Longitude: $_lat");
          debugPrint("Barangay: $barangay");
          debugPrint("Address: $address");
          debugPrint("Assistance: $assistance");
          debugPrint("Alarm Severity: $alarmSeverity");
          debugPrint("-----------------------");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(171, 0, 0, 1),
        shape: const StadiumBorder(),
        elevation: 20,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text(
        "Submit Report",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _assistanceItems(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
}
