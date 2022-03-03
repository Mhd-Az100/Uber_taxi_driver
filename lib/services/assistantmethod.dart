import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:over_taxi_driver/Models/directDetails_model.dart';
import 'package:over_taxi_driver/services/requestAssistans.dart';
import 'package:over_taxi_driver/utils/configMaps.dart';

class AssistantMehod {
  //get places
  // static Future<String?> searchCoordinateAddress(
  //     Position position, context) async {
  //   String placeAddress = "";
  //   String st1, st2, st3, st4;
  //   String? url =
  //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
  //   var res = await RequestAssistant.getRequsest(url);
  //   if (res != "failed") {
  //     placeAddress = res["results"][0]["formatted_address"];
  //     // st1 = res["results"][1]["address_components"][0]["long_name"];
  //     // st2 = res["results"][1]["address_components"][1]["long_name"];
  //     // st3 = res["results"][1]["address_components"][2]["long_name"];
  //     // st4 = res["results"][1]["address_components"][4]["long_name"];
  //     // placeAddress = st1 + " " + st2 + " " + st3 + " " + st4;
  //     Address userPickUpAddress = Address();
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.placeName = placeAddress;
  //     Provider.of<AppData>(context, listen: false)
  //         .updatePickUpLocationAddress(userPickUpAddress);
  //   }
  //   return placeAddress;
  // }

// get details direction places
  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";

    var res = await RequestAssistant.getRequsest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;

    return totalFareAmount.truncate();
  }

  // static void getCurrentOnlineUserInfo() async {
  //   firebaseUser = FirebaseAuth.instance.currentUser;
  //   String userId = firebaseUser!.uid;
  //   DatabaseReference reference =
  //       FirebaseDatabase.instance.reference().child("users").child(userId);

  //   reference.once().then((DataSnapshot dataSnapShot) {
  //     if (dataSnapShot.value != null) {
  //       userCurrentInfo = Users.fromSnapshot(dataSnapShot);
  //     }
  //   });
  // }
  static void disableHomeTabLiveLocationUpdates() {
    homeTabStreamSubscription!.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static void enableHomeTapLocationUpdate() {
    homeTabStreamSubscription!.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
  }
}
