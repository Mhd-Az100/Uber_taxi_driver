import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:over_taxi_driver/Models/rideDetails_model.dart';
import 'package:over_taxi_driver/constant/styleText.dart';
import 'package:over_taxi_driver/main.dart';
import 'package:over_taxi_driver/services/assistantmethod.dart';
import 'package:over_taxi_driver/utils/configMaps.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails? rideDetails;

  NotificationDialog({this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.0),
            Image.asset(
              "img/taxi.png",
              width: 150.0,
            ),
            SizedBox(
              height: 0.0,
            ),
            Text(
              "طلب توصيل جديد",
              style: knotificationdialogtext,
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "img/place.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text('من'),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Container(
                            child: Text(
                          rideDetails!.pickup_address!,
                          style: TextStyle(fontSize: 18.0),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "img/place.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text('الى'),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                        rideDetails!.dropoff_address!,
                        style: TextStyle(fontSize: 18.0),
                      ))),
                    ],
                  ),
                  SizedBox(height: 0.0),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Divider(
              height: 2.0,
              thickness: 4.0,
            ),
            SizedBox(height: 0.0),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ignore: deprecated_member_use
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 25.0),
                  // ignore: deprecated_member_use
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.green)),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      // checkAvailabilityOfRide(context);
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text("Accept".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(context) {
    rideRequestRef!.once().then((DataSnapshot dataSnapShot) {
      Navigator.pop(context);
      String theRideId = "";
      if (dataSnapShot.value != null) {
        theRideId = dataSnapShot.value.toString();
      } else {
        displayToastMessage("Ride not exists.", context);
      }

      if (theRideId == rideDetails!.ride_request_id) {
        rideRequestRef!.set("accepted");
        AssistantMehod.disableHomeTabLiveLocationUpdates();
        // Get.to(OrdersTabPage());
      } else if (theRideId == "cancelled") {
        displayToastMessage("تم الغاء العملية.", context);
      } else if (theRideId == "timeout") {
        displayToastMessage("انقضت مهلة السائق", context);
      } else {
        displayToastMessage("السائق خارج الخدمة.", context);
      }
    });
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red[200]);
  }
}
