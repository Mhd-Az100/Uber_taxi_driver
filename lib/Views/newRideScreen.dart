import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:over_taxi_driver/Models/rideDetails_model.dart';
import 'package:over_taxi_driver/constant/styleText.dart';
import 'package:over_taxi_driver/main.dart';
import 'package:over_taxi_driver/services/assistantmethod.dart';
import 'package:over_taxi_driver/services/mapKitAssistant.dart';
import 'package:over_taxi_driver/utils/configMaps.dart';
import 'package:over_taxi_driver/widget/CollectFareDialog.dart';
import 'package:over_taxi_driver/widget/progressDialog.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails? rideDetails;
  NewRideScreen({this.rideDetails});
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.500602, 36.296266),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  //===============vars google map==============

  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController? newRideGoogleMapController;
  List<LatLng> polyLineCoordinates = [];
  Set<Marker> markersSet = {};
  Set<Circle> circleSet = {};
  Set<Polyline> polyLineSet = {};
  PolylinePoints polylinePoints = PolylinePoints();
  double paddingmapbottom = 0;
  var geolocator = Geolocator();
  var locationOption =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  Position? mypostion;
  String status = "accepted";
  String durationRide = "";
  bool isRequestingDirection = false;
  String btnTitle = "";
  Color btnColor = Colors.blueAccent;
  Timer? timer;
  int durationCounter = 0;
//===============================================
  @override
  void initState() {
    super.initState();
    acceptRideRequest();
  }

  @override
  Widget build(BuildContext context) {
    creatIconMarker();
    return Scaffold(
      appBar: AppBar(
        title: Text("New Ride"),
      ),
      body: Stack(
        children: [
          optionRide(),
          googlemap(),
        ],
      ),
    );
  }

  Widget googlemap() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: paddingmapbottom),
      initialCameraPosition: NewRideScreen._kGooglePlex,
      // zoomGesturesEnabled: true,
      // zoomControlsEnabled: true,
      myLocationEnabled: true,
      markers: markersSet,
      circles: circleSet,
      polylines: polyLineSet,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) async {
        _controllerGoogleMap.complete(controller);
        newRideGoogleMapController = controller;
        setState(() {
          paddingmapbottom = 265;
        });
        var currentLatLng =
            LatLng(currentPosition!.latitude, currentPosition!.longitude);
        var pickUpLatLng = widget.rideDetails!.pickup;
        await getplaceDiection(currentLatLng, pickUpLatLng!);
        getRideLiveLocationUpdate();
      },
    );
  }

  Widget optionRide() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ]),
        height: 260,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            children: [
              Text(
                durationRide,
                style: ktextdialog,
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mohamad',
                    style: kNavigateLogin,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.phone_android,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 26,
              ),
              Row(
                children: [
                  Image.asset(
                    "img/place.png",
                    height: 16.0,
                    width: 16.0,
                  ),
                  SizedBox(
                    width: 18.0,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.rideDetails!.pickup_address!,
                        style: TextStyle(fontSize: 18.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Image.asset(
                    "img/place.png",
                    height: 16.0,
                    width: 16.0,
                  ),
                  SizedBox(
                    width: 18.0,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.rideDetails!.dropoff_address!,
                        style: TextStyle(fontSize: 18.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 26.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                // ignore: deprecated_member_use
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                  onPressed: () async {
                    if (status == "accepted") {
                      status = "arrived";
                      String? rideRequestId =
                          widget.rideDetails!.ride_request_id;

                      newRequestsRef
                          .child(rideRequestId!)
                          .child("status")
                          .set(status);

                      setState(() {
                        btnTitle = "Start Trip";
                        btnColor = Colors.indigo;
                      });

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => ProgressDialog(
                          message: "الرجاء الانتظار...",
                        ),
                      );

                      await getplaceDiection(widget.rideDetails!.pickup!,
                          widget.rideDetails!.dropoff!);

                      Navigator.pop(context);
                    } else if (status == "arrived") {
                      status = "onride";
                      String? rideRequestId =
                          widget.rideDetails!.ride_request_id;

                      newRequestsRef
                          .child(rideRequestId!)
                          .child("status")
                          .set(status);

                      setState(() {
                        btnTitle = "End Trip";
                        btnColor = Colors.redAccent;
                      });

                      initTimer();
                    } else if (status == "onride") {
                      endTheTrip();
                    }
                  },
                  color: btnColor,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          btnTitle,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.directions_car,
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
        ),
      ),
    );
  }

  Future<void> getplaceDiection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMehod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details!.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints!);
    polyLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        LatLng(pointLatLng.latitude, pointLatLng.longitude);
        polyLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.indigo[900]!,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newRideGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 70),
    );
    Marker picUpLocalMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        position: pickUpLatLng,
        markerId: MarkerId('pickUpId'));
    Marker dropOffLocalMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      position: dropOffLatLng,
      markerId: MarkerId('pickUpId'),
    );
    setState(() {
      markersSet.add(picUpLocalMarker);
      markersSet.add(dropOffLocalMarker);
    });
    Circle pickUpLocCircle = Circle(
      circleId: CircleId('pickUpId'),
      fillColor: Colors.red.withOpacity(0.7),
      center: pickUpLatLng,
      radius: 100,
      strokeWidth: 4,
      strokeColor: Colors.greenAccent,
    );
    Circle dropOffLocCircle = Circle(
      circleId: CircleId('dropOffId'),
      fillColor: Colors.blueGrey.withOpacity(0.7),
      center: dropOffLatLng,
      radius: 100,
      strokeWidth: 4,
      strokeColor: Colors.red,
    );
    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {
    String? rideRequestId = widget.rideDetails!.ride_request_id;
    newRequestsRef.child(rideRequestId!).child("status").set("accepted");
    newRequestsRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation!.name);
    newRequestsRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation!.phone);
    newRequestsRef.child(rideRequestId).child("car_details").set(
        '${driversInformation!.car_color} - ${driversInformation!.car_model}');
    Map locMap = {
      "latitude": currentPosition!.latitude.toString(),
      "longitude": currentPosition!.longitude.toString(),
    };
    newRequestsRef.child(rideRequestId).child("driver_location").set(locMap);

    driversRef
        .child(currentfirebaseUser!.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void creatIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(11, 11),
      );

      BitmapDescriptor.fromAssetImage(imageConfiguration, "img/car_android.png")
          .then((value) {
        animatingMarkerIcon = value;
      }).catchError((error) {
        print('errooooooooooor${error.toString()}');
      });
    }
  }

  void getRideLiveLocationUpdate() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      mypostion = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);
      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude,
          oldPos.longitude, mPosition.latitude, mPosition.longitude);

      Marker animatingMarker = Marker(
          markerId: MarkerId("animating"),
          position: mPosition,
          icon: animatingMarkerIcon!,
          rotation: rot!,
          infoWindow: InfoWindow(title: "عنواني"));
      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: mPosition, zoom: 17);
        newRideGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
        markersSet
            .removeWhere((marker) => marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
      oldPos = mPosition;
      updateRideDetails();
      String? rideRequestId = widget.rideDetails!.ride_request_id;

      Map locMap = {
        "latitude": currentPosition!.latitude.toString(),
        "longitude": currentPosition!.longitude.toString(),
      };
      newRequestsRef.child(rideRequestId!).child("driver_location").set(locMap);
    });
  }

  void updateRideDetails() async {
    if (isRequestingDirection == false) {
      isRequestingDirection = true;
    }
    if (mypostion == null) {
      return;
    }
    var posLatLng = LatLng(mypostion!.latitude, mypostion!.longitude);
    LatLng destinationLatLng;
    if (status == "accepted") {
      destinationLatLng = widget.rideDetails!.pickup!;
    } else {
      destinationLatLng = widget.rideDetails!.dropoff!;
    }
    var directionDetails = await AssistantMehod.obtainPlaceDirectionDetails(
        posLatLng, destinationLatLng);
    if (directionDetails != null) {
      setState(() {
        durationRide = directionDetails.durationText!;
      });
    }
    isRequestingDirection = false;
  }

  void initTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  void endTheTrip() async {
    timer!.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "الرجاء الانتظار...",
      ),
    );
    var currentLatLng = LatLng(mypostion!.latitude, mypostion!.longitude);
    var directionDetails = await AssistantMehod.obtainPlaceDirectionDetails(
        widget.rideDetails!.pickup!, currentLatLng);
    Navigator.pop(context);
    int fareAmount = AssistantMehod.calculateFares(directionDetails!);

    String? rideRequestId = widget.rideDetails!.ride_request_id;
    newRequestsRef
        .child(rideRequestId!)
        .child("fares")
        .set(fareAmount.toString());

    newRequestsRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription!.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectFareDialog(
        paymentMethod: widget.rideDetails!.payment_method,
        fareAmount: fareAmount,
      ),
    );
    saveEarning(fareAmount);
  }

  void saveEarning(int fareAmount) {
    driversRef
        .child(currentfirebaseUser!.uid)
        .child("earnings")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        double oldEarnings = double.parse(dataSnapshot.value.toString());
        double totalEarnings = fareAmount + oldEarnings;
        driversRef
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      } else {
        double totalEarnings = fareAmount.toDouble();
        driversRef
            .child(currentfirebaseUser!.uid)
            .child("earnings")
            .set(totalEarnings.toStringAsFixed(2));
      }
    });
  }
}
