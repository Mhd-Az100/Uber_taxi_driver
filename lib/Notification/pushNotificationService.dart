import 'dart:io' show Platform;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:over_taxi_driver/Models/rideDetails_model.dart';
import 'package:over_taxi_driver/Notification/notificationDialog.dart';
import 'package:over_taxi_driver/main.dart';
import 'package:over_taxi_driver/utils/configMaps.dart';

class PushNotificationService {
// Crude counter to make messages unique

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

//========================firebase messaging========================
  Future initialize(context) async {
    var initialzationsettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationsettingsAndroid);
    flutterLocalNotificationsPlugin!.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
      print('reseve message1!');

      if (notification != null && android != null && !kIsWeb) {
        print('reseve message2!');
        flutterLocalNotificationsPlugin!.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel!.id,
                channel!.name,
                channel!.description,
                //      one that already exists in example app.
                playSound: true,
                icon: 'launch_background',
              ),
            ));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));
      }
    });
    Future<void> onActionSelected(String value) async {
      switch (value) {
        case 'subscribe':
          {
            print(
                'FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
            await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
            print(
                'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
          }
          break;
        case 'unsubscribe':
          {
            print(
                'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".');
            await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
            print(
                'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.');
          }
          break;
        case 'get_apns_token':
          {
            if (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS) {
              print('FlutterFire Messaging Example: Getting APNs token...');
              String? token = await FirebaseMessaging.instance.getAPNSToken();
              print('FlutterFire Messaging Example: Got APNs token: $token');
            } else {
              print(
                  'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.');
            }
          }
          break;
        default:
          break;
      }
    }
  }

  Future<String?> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('tooooooookeeen    $token');
    driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      rideRequestId = message['ride_request_id'];
    } else {
      rideRequestId = message['ride_request_id'];
    }

    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    newRequestsRef
        .child(rideRequestId)
        .once()
        .then((DataSnapshot? dataSnapShot) {
      if (dataSnapShot!.value != null) {
        assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();

        double pickUpLocationLat =
            double.parse(dataSnapShot.value['pickup']['latitude'].toString());
        double pickUpLocationLng =
            double.parse(dataSnapShot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapShot.value['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng =
            double.parse(dataSnapShot.value['dropoff']['longitude'].toString());
        String dropOffAddress =
            dataSnapShot.value['dropoff_address'].toString();

        String paymentMethod = dataSnapShot.value['payment_method'].toString();

        String rider_name = dataSnapShot.value["rider_name"];
        String rider_phone = dataSnapShot.value["rider_phone"];

        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickup_address = pickUpAddress;
        rideDetails.dropoff_address = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;
        rideDetails.rider_name = rider_name;
        rideDetails.rider_phone = rider_phone;

        print("Information :: ");
        print(rideDetails.pickup_address);
        print(rideDetails.dropoff_address);
        print('befor show dialog ');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(
            rideDetails: rideDetails,
          ),
        );
      } else {
        print('datasnapshot value null ');
        print('iddd $rideRequestId');
      }
    });
  }
}
