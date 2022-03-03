import 'package:get/get.dart';
import 'package:over_taxi_driver/lang/ar.dart';
import 'package:over_taxi_driver/lang/en.dart';
import 'package:over_taxi_driver/lang/ru.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'ar': ar,
        'ru': ru,
      };
}
