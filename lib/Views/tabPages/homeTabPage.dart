import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:over_taxi_driver/Models/directDetails_model.dart';
import 'package:over_taxi_driver/Models/drivers_model.dart';
import 'package:over_taxi_driver/Notification/pushNotificationService.dart';
import 'package:over_taxi_driver/constant/colors.dart';
import 'package:over_taxi_driver/main.dart';
import 'package:over_taxi_driver/utils/configMaps.dart';

class HomeTabPage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.500602, 36.296266),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  //===============vars google map==============

  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newGoogleMapController;

  Position? currentPosition;

  var geolocator = Geolocator();

  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinates = [];

  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};

  Set<Circle> circleSet = {};

  DirectionDetails? tripDirectionDetails;
  double paddingmaptop = 150;
//===========================================================
  String driverStatusText = "غير متصل";

  Color driverStatuscolor = Colors.black;

  bool isDriverAvaiable = false;
  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        googlemap(),
        //online & offline driver containar
        backgroundonline(),
        onlineOffline(),
      ],
    );
  }

  Widget googlemap() {
    return GoogleMap(
      padding: EdgeInsets.only(top: paddingmaptop),
      initialCameraPosition: HomeTabPage._kGooglePlex,
      // zoomGesturesEnabled: true,
      // zoomControlsEnabled: true,
      myLocationEnabled: true,
      circles: circleSet,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _controllerGoogleMap.complete(controller);
        newGoogleMapController = controller;
        locatePosition();
        setState(() {
          paddingmaptop = 150;
        });
      },
    );
  }

  Widget backgroundonline() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.black45,
    );
  }

  Widget onlineOffline() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(driverStatuscolor)),
              onPressed: () {
                if (isDriverAvaiable != true) {
                  makeDriverOnlineNow();
                  getLocationLiveUpdate();
                  setState(() {
                    driverStatuscolor = green;
                    driverStatusText = "متصل الآن";
                    isDriverAvaiable = true;
                  });
                  Fluttertoast.showToast(
                      msg: 'انت الآن متصل',
                      backgroundColor: Colors.blueGrey[700]!.withOpacity(0.5));
                } else {
                  setState(() {
                    driverStatuscolor = Colors.black;
                    driverStatusText = "غير متصل";
                    isDriverAvaiable = false;
                  });
                  makeDriverOfflineNow();
                  Fluttertoast.showToast(
                      msg: 'انت الآن غير متصل',
                      backgroundColor: Colors.blueGrey[700]!.withOpacity(0.5));
                }
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      driverStatusText,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 26.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latlngposition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngposition, zoom: 17);
    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    // String? address =
    //     await AssistantMehod.searchCoordinateAddress(position, context);
    // print("this is your Address :: " + address!);
  }

  void getLocationLiveUpdate() {
    homeTabStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvaiable == true) {
        Geofire.setLocation(
            currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
    rideRequestRef!.set("searching");
    rideRequestRef!.onValue.listen((event) {});
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(
      currentfirebaseUser!.uid,
    );
    rideRequestRef!.onDisconnect();
    rideRequestRef!.remove();
    rideRequestRef = null;
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;
    driversRef
        .child(currentfirebaseUser!.uid)
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }
}
