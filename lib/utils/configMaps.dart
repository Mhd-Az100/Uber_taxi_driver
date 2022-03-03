import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:over_taxi_driver/Models/drivers_model.dart';
import 'package:over_taxi_driver/Models/sign%20in_model.dart';

String mapkey = "AIzaSyDUYiMp-AWm0TMsuRRWLOFCyRWkgzj8M_I";
User? firebaseUser;
User? currentfirebaseUser;
Users? userCurrentInfo;
StreamSubscription<Position>? homeTabStreamSubscription;
StreamSubscription<Position>? rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();
Position? currentPosition;
Drivers? driversInformation;
