// ignore_for_file: no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_user/functions/api_service.dart';
import 'package:flutter_user/functions/auth_service.dart';
import 'package:flutter_user/functions/ride_service.dart';
import 'package:flutter_user/functions/map_service.dart';
import 'package:flutter_user/functions/location_service.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/functions/wallet_service.dart';
import 'package:flutter_user/functions/settings_service.dart';
import 'package:flutter_user/functions/user_service.dart';
import 'package:flutter_user/functions/ride_state.dart';
export 'package:flutter_user/functions/ride_state.dart';

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/NavigatorPages/editprofile.dart';
import '../pages/NavigatorPages/history.dart';
import '../pages/NavigatorPages/historydetails.dart';
import '../pages/loadingPage/loadingpage.dart';
import '../pages/login/login.dart';
import '../pages/login/namepage.dart';
import '../pages/login/otp_page.dart';
import '../pages/onTripPage/booking_confirmation.dart';
import '../pages/onTripPage/map_page.dart';
import '../pages/onTripPage/review_page.dart';
import '../pages/referralcode/referral_code.dart';

//languages code
dynamic phcode;
dynamic platform;
dynamic pref;
String isActive = '';
double duration = 30.0;
var audio = 'audio/notification_sound.mp3';
bool internet = true;
// int waitingTime = 0; // moved to ride_state.dart
String gender = '';
bool logout = false;
String packageName = '';
String signKey = '';
dynamic proImageFile;
String phnumber = '';
String email = '';
bool isverifyemail = false;
String name = '';
int currentPage = 0;
bool loginLoading = true;
var values = 0;
bool isfromomobile = true;
bool isLoginemail = false;
String otpNumber = '';
dynamic package;
dynamic currentLocation;
LatLng center = const LatLng(41.4219057, -102.0840772);
String referralCode = '';
String mapStyle = '';
List addressList = [];
// Map userRequestData = {}; // moved to ride_state.dart
// List fmpoly = []; // moved to ride_state.dart
// bool noDriverFound = false; // moved to ride_state.dart
// String tripError = ''; // moved to ride_state.dart
// bool tripReqError = false; // moved to ride_state.dart
Set<Marker> myMarkers = {};
bool serviceEnabled = false;
bool cancelRequestByUser = false;
dynamic outStationPushStream;
dynamic positionStream;
dynamic favLat;
dynamic favLng;
dynamic favSelectedAddress;
int choosenTransportType = 0;
List sosData = [];

//base url — LOCAL DEV
// Android emulator  : http://10.0.2.2/  (points to your PC's localhost)
// Physical device   : use your PC's LAN IP e.g. http://192.168.1.X/
// Production server : https://your-domain.com/
String url =
    'https://trucabtt.com/'; // Restored to production URL as requested.
String mapkey =
    (platform == TargetPlatform.android) ? 'AIzaSyAvf8uEuoFuxAbusVe9ZQPqzG3gBknj3nc' : 'AIzaSyAsTre_lK-ZgKQlo4jJ64c6_gQ291YNSJA';

String mapType = '';

//check internet connection

checkInternetConnection() {
  Connectivity().onConnectivityChanged.listen((connectionState) {
    if (connectionState.contains(ConnectivityResult.none)) {
      internet = false;
      valueNotifierHome.incrementNotifier();
      valueNotifierBook.incrementNotifier();
    } else {
      internet = true;
      valueNotifierHome.incrementNotifier();
      valueNotifierBook.incrementNotifier();
    }
  });
}

getDetailsOfDevice() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.none)) {
    internet = false;
  } else {
    internet = true;
  }
  try {

    pref = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint(e.toString());
  }
}

// dynamic timerLocation;
dynamic locationAllowed;

positionStreamData() {
  LocationService.startTracking((LatLng position) {
    currentLocation = position;
  });
}

//validate email already exist

validateEmail(email) async {
  dynamic result;
  try {
    var response = await AuthService.validateMobile(
        (values == 0) ? {'mobile': email} : {'email': email});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = t('text_email_already_taken');
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//language code
var choosenLanguage = '';
var languageDirection = '';

List languagesCode = [
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'English (UK)', 'code': 'en-GB'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {
    'name': 'Portuguese (Portugal)',
    'code': 'pt' //pt-PT
  },
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {
    'name': 'Chinese (PRC)',
    'code': 'zh' //zh-CN
  },
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Somalian', 'code': 'so'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-TW'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

//getting country code

List countries = [];
getCountryCode() async {
  dynamic result;
  try {
    String host = url.replaceAll('https://', '').replaceAll('http://', '').split('/')[0];
    debugPrint('Fetching countries from: ${url}api/v1/countries');
    debugPrint('Using Host header: $host');
    
    final response = await http.get(Uri.parse('${url}api/v1/countries'));

    debugPrint('Countries Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data'];
      phcode =
      (countries.where((element) => element['default'] == true).isNotEmpty)
          ? countries.indexWhere((element) => element['default'] == true)
          : 0;
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//login firebase

String userUid = '';
var verId = '';
int? resendTokenId;
bool phoneAuthCheck = false;
dynamic credentials;

phoneAuth(String phone) async {
  try {
    credentials = null;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
        valueNotifierHome.incrementNotifier();
      },
      forceResendingToken: resendTokenId,
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verId = verificationId;
        resendTokenId = resendToken;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get local bearer token

String lastNotification = '';
List recentSearchesList = [];

getLocalData() async {
  dynamic result;
  bearerToken.clear;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.none)) {
    internet = false;
  } else {
    internet = true;
  }
  try {
    if (pref.containsKey('lastNotification')) {
      lastNotification = pref.getString('lastNotification');
    }
    if (pref.containsKey('autoAddress')) {
      var val = pref.getString('autoAddress');
      storedAutoAddress = jsonDecode(val);
    }
    if (pref.containsKey('outstationpush')) {
      outStationDriver = await loadListFromPrefs();
    }

    if (pref.containsKey('choosenLanguage')) {
      choosenLanguage = pref.getString('choosenLanguage');
      languageDirection = pref.getString('languageDirection');
      if (choosenLanguage.isNotEmpty) {
        if (pref.containsKey('Bearer')) {
          var tokens = pref.getString('Bearer');
          if (tokens != null) {
            bearerToken.add(BearerClass(type: 'Bearer', token: tokens));
            var responce = await getUserDetails();
            if (responce == true) {
              result = '3';
            } else {
              result = '2';
            }
          } else {
            result = '2';
          }
        } else {
          result = '2';
        }
      } else {
        result = '1';
      }
    } else {
      result = '1';
    }
    if (pref.containsKey('recentsearch')) {
      var val = pref.getString('recentsearch');
      recentSearchesList = jsonDecode(val);
      // print(';jhvhjvjkbkj');
      // printWrapped(jsonDecode(val).toString());
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//register user

List<BearerClass> bearerToken = <BearerClass>[];

registerUser() async {
  return await AuthService.registerUser();
}

//update referral code

updateReferral() async {
  return await AuthService.updateReferral();
}

//call firebase otp

otpCall() async {
  return await AuthService.otpCall();
}

// verify user already exist

verifyUser(String number) async {
  return await AuthService.verifyUser(number);
}

acceptRequest(body) async {
  return await RideService.acceptRequest(body);
}

updatePassword(email, password, loginby) async {
  return await AuthService.updatePassword(email, password, loginby);
}

//user login
userLogin() async {
  return await AuthService.userLogin();
}

Map<String, dynamic> userDetails = {};
List favAddress = [];
List tripStops = [];
List banners = [];
// bool ismulitipleride = false; // moved to ride_state.dart
// bool polyGot = false; // moved to ride_state.dart
bool changeBound = false;
//user current state

getUserDetails({id}) async {
  return await AuthService.getUserDetails(id: id);
}



userDelete() async {
  return await AuthService.userDelete();
}


class BearerClass {
  final String type;
  final String token;
  BearerClass({required this.type, required this.token});

  BearerClass.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        token = json['token'];

  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

Map<String, dynamic> driverReq = {};

class ValueNotifying {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifier = ValueNotifying();

class ValueNotifyingHome {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingChat {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingKey {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingNotification {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingLogin {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifyingHome valueNotifierHome = ValueNotifyingHome();
ValueNotifyingChat valueNotifierChat = ValueNotifyingChat();
ValueNotifyingKey valueNotifierKey = ValueNotifyingKey();
ValueNotifyingNotification valueNotifierNotification =
    ValueNotifyingNotification();
ValueNotifyingLogin valueNotifierLogin = ValueNotifyingLogin();
ValueNotifyingTimer valueNotifierTimer = ValueNotifyingTimer();

class ValueNotifyingTimer {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

class ValueNotifyingBook {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifyingBook valueNotifierBook = ValueNotifyingBook();

//sound
AudioCache audioPlayer = AudioCache();
AudioPlayer audioPlayers = AudioPlayer();

//get reverse geo coding

var pickupAddress = '';
var dropAddress = '';

geoCoding(double lat, double lng) async {
  dynamic result;
  try {
    http.Response val;

    if (mapType == 'google') {
      if (Platform.isAndroid) {
        val = await http.get(
            Uri.parse(
                'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'),
            headers: {
              'X-Android-Package': packageName,
              'X-Android-Cert': signKey
            });
      } else {
        val = await http.get(
            Uri.parse(
                'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'),
            headers: {'X-IOS-Bundle-Identifier': packageName});
      }
    } else {
      val = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json'),
      );
    }
    if (val.statusCode == 200) {
      if (mapType == 'google') {
        result = jsonDecode(val.body)['results'][0]['formatted_address'];
      } else {
        result = jsonDecode(val.body)['display_name'].toString();
      }
      return result;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//lang
getlangid() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/user/update-language'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${bearerToken[0].token}',
            },
            body: jsonEncode({"lang": choosenLanguage}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get address auto fill data
List storedAutoAddress = [];
List addAutoFill = [];

getAutocomplete(input, sessionToken, lat, lng) async {
  try {
    addAutoFill.clear();
    if (mapType == 'google') {
      http.Response val;
      if (Platform.isAndroid) {
        val = await http.get(
            Uri.parse(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$mapkey&location=$lat%2C$lng&radius=10000&sessionToken=$sessionToken'),
            headers: {
              'X-Android-Package': packageName,
              'X-Android-Cert': signKey
            });
      } else {
        val = await http.get(
            Uri.parse(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$mapkey&location=$lat%2C$lng&radius=10000&sessionToken=$sessionToken'),
            headers: {'X-IOS-Bundle-Identifier': packageName});
      }

      if (val.statusCode == 200) {
        var result = jsonDecode(val.body);
        for (var element in result['predictions']) {
          addAutoFill.add({
            'place': element['place_id'],
            'description': element['description'],
            'lat': '',
            'lon': ''
          });
          if (storedAutoAddress
              .where((element) => element['place'] == element['place_id'])
              .isEmpty) {
            storedAutoAddress.add({
              'place': element['place_id'],
              'description': element['description'],
              'lat': '',
              'lon': ''
            });
          }
        }
      }

      pref.setString('autoAddress', jsonEncode(storedAutoAddress).toString());
    } else {
      var result = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$input&format=json'));
      for (var element in jsonDecode(result.body)) {
        addAutoFill.add({
          'place': element['place_id'],
          'description': element['display_name'],
          'secondary': '',
          'lat': element['lat'],
          'lon': element['lon']
        });
      }
    }
    valueNotifierHome.incrementNotifier();
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

geoCodingForLatLng(id, sessionToken) async {
  try {
    http.Response val;
    if (Platform.isAndroid) {
      val = await http.get(
          Uri.parse(
              'https://maps.googleapis.com/maps/api/place/details/json?placeid=$id&key=$mapkey&sessionToken=$sessionToken'),
          headers: {
            'X-Android-Package': packageName,
            'X-Android-Cert': signKey
          });
    } else {
      val = await http.get(
          Uri.parse(
              'https://maps.googleapis.com/maps/api/place/details/json?placeid=$id&key=$mapkey&sessionToken=$sessionToken'),
          headers: {'X-IOS-Bundle-Identifier': packageName});
    }

    if (val.statusCode == 200) {
      var result = jsonDecode(val.body)['result']['geometry']['location'];
      return result;
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

//pickup drop address list

class AddressList {
  String address;
  LatLng latlng;
  String id;
  dynamic type;
  dynamic name;
  dynamic number;
  dynamic instructions;
  bool pickup;

  AddressList(
      {required this.id,
      required this.address,
      required this.latlng,
      required this.pickup,
      this.type,
      this.name,
      this.number,
      this.instructions});

  toJson() {}
}

//get polylines
String polyString = '';
List<LatLng> polyList = [];

getPolylines(plat, plng, dlat, dlng) async {
  polyList = await MapService.getPolylines(plat.toString(), plng.toString(), dlat.toString(), dlng.toString());
  polyGot = false;
  valueNotifierBook.incrementNotifier();
  return polyList;
}

class RouteInfo {
  final int distance;
  final String summary;
  final List steps;

  RouteInfo({
    required this.distance,
    required this.summary,
    required this.steps,
  });
}

//polyline decode

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  polyline.clear();

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }
  // print(polyList.toString());

  polyline.add(
    Polyline(
        polylineId: const PolylineId('1'),
        color: Colors.blue,
        visible: true,
        width: 4,
        points: polyList),
  );

  return poly;
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

//get goods list
List goodsTypeList = [];

getGoodsList() async {
  dynamic result;
  goodsTypeList.clear();
  try {
    var response = await http.get(Uri.parse('${url}api/v1/common/goods-types'));
    if (response.statusCode == 200) {
      goodsTypeList = jsonDecode(response.body)['data'];
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//drop stops list
List<DropStops> dropStopList = <DropStops>[];

class DropStops {
  String order;
  double latitude;
  double longitude;
  String? pocName;
  String? pocNumber;
  dynamic pocInstruction;
  String address;

  DropStops(
      {required this.order,
      required this.latitude,
      required this.longitude,
      this.pocName,
      this.pocNumber,
      this.pocInstruction,
      required this.address});

  Map<String, dynamic> toJson() => {
        'order': order,
        'latitude': latitude,
        'longitude': longitude,
        'poc_name': pocName,
        'poc_mobile': pocNumber,
        'poc_instruction': pocInstruction,
        'address': address,
      };
}

// List etaDetails = []; // moved to ride_state.dart
// dynamic choosenVehicle; // moved to ride_state.dart

//eta request
etaRequest({transport, outstation}) async {
  etaDetails.clear();
  final body = (addressList
                    .where((element) => element.type == 'drop')
                    .isNotEmpty &&
                dropStopList.isEmpty)
            ? {
                'pick_lat': (userRequestData.isNotEmpty)
                    ? userRequestData['pick_lat']
                    : addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .latitude,
                'pick_lng': (userRequestData.isNotEmpty)
                    ? userRequestData['pick_lng']
                    : addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .longitude,
                'drop_lat': (userRequestData.isNotEmpty)
                    ? userRequestData['drop_lat']
                    : addressList
                        .lastWhere((e) => e.type == 'drop')
                        .latlng
                        .latitude,
                'drop_lng': (userRequestData.isNotEmpty)
                    ? userRequestData['drop_lng']
                    : addressList
                        .lastWhere((e) => e.type == 'drop')
                        .latlng
                        .longitude,
                'ride_type': 1,
                'transport_type': (transport == null)
                    ? (choosenTransportType == 0)
                        ? 'taxi'
                        : 'delivery'
                    : transport,
                'is_outstation': outstation
              }
            : (dropStopList.isNotEmpty &&
                    addressList
                        .where((element) => element.type == 'drop')
                        .isNotEmpty)
                ? {
                    'pick_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lat']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .latitude,
                    'pick_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lng']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .longitude,
                    'drop_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['drop_lat']
                        : addressList
                            .lastWhere((e) => e.type == 'drop')
                            .latlng
                            .latitude,
                    'drop_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['drop_lng']
                        : addressList
                            .lastWhere((e) => e.type == 'drop')
                            .latlng
                            .longitude,
                    'stops': jsonEncode(dropStopList),
                    'ride_type': 1,
                    'transport_type':
                        (choosenTransportType == 0) ? 'taxi' : 'delivery',
                    'is_outstation': outstation
                  }
                : {
                    'pick_lat': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lat']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .latitude,
                    'pick_lng': (userRequestData.isNotEmpty)
                        ? userRequestData['pick_lng']
                        : addressList
                            .firstWhere((e) => e.type == 'pickup')
                            .latlng
                            .longitude,
                    'ride_type': 1,
                    'transport_type': (transport == null)
                        ? (choosenTransportType == 0)
                            ? 'taxi'
                            : 'delivery'
                        : transport,
                    'is_outstation': outstation
                  };

  final data = await RideService.getEta(body: body);
  if (data != null) {
      etaDetails = data;
      choosenVehicle = (etaDetails
              .where((element) => element['is_default'] == true)
              .isNotEmpty)
          ? etaDetails.indexWhere((element) => element['is_default'] == true)
          : 0;
      valueNotifierBook.incrementNotifier();
      valueNotifierHome.incrementNotifier();
      return 'success';
  }
  return false;
}

etaRequestWithPromo({outstation}) async {
  dynamic result;
  // etaDetails.clear();
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/eta'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: (addressList
                    .where((element) => element.type == 'drop')
                    .isNotEmpty &&
                dropStopList.isEmpty)
            ? jsonEncode({
                'pick_lat': addressList
                    .firstWhere((e) => e.type == 'pickup')
                    .latlng
                    .latitude,
                'pick_lng': addressList
                    .firstWhere((e) => e.type == 'pickup')
                    .latlng
                    .longitude,
                'drop_lat': addressList
                    .firstWhere((e) => e.type == 'drop')
                    .latlng
                    .latitude,
                'drop_lng': addressList
                    .firstWhere((e) => e.type == 'drop')
                    .latlng
                    .longitude,
                'ride_type': 0,
                'promo_code': promoCode,
                'transport_type':
                    (choosenTransportType == 0) ? 'taxi' : 'delivery',
                'is_outstation': outstation
              })
            : (dropStopList.isNotEmpty &&
                    addressList
                        .where((element) => element.type == 'drop')
                        .isNotEmpty)
                ? jsonEncode({
                    'pick_lat': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .latitude,
                    'pick_lng': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .longitude,
                    'drop_lat': addressList
                        .firstWhere((e) => e.type == 'drop')
                        .latlng
                        .latitude,
                    'drop_lng': addressList
                        .firstWhere((e) => e.type == 'drop')
                        .latlng
                        .longitude,
                    'stops': jsonEncode(dropStopList),
                    'ride_type': 0,
                    'promo_code': promoCode,
                    'transport_type':
                        (choosenTransportType == 0) ? 'taxi' : 'delivery',
                    'is_outstation': outstation
                  })
                : jsonEncode({
                    'pick_lat': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .latitude,
                    'pick_lng': addressList
                        .firstWhere((e) => e.type == 'pickup')
                        .latlng
                        .longitude,
                    'ride_type': 0,
                    'promo_code': promoCode,
                    'transport_type':
                        (choosenTransportType == 0) ? 'taxi' : 'delivery',
                    'is_outstation': outstation
                  }));

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      promoCode = '';
      promoStatus = 1;
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      promoStatus = 2;
      // promoCode = '';
      couponerror = true;
      valueNotifierBook.incrementNotifier();

      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//rental eta request

Map<String, dynamic> get myReferralCode => UserService.myReferralCode;
set myReferralCode(Map<String, dynamic> val) => UserService.myReferralCode = val;

getReferral() async => await UserService.getReferral();


rentalEta() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/list-packages'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'pick_lat': (userRequestData.isNotEmpty)
                  ? userRequestData['pick_lat']
                  : addressList
                      .firstWhere((e) => e.type == 'pickup')
                      .latlng
                      .latitude,
              'pick_lng': (userRequestData.isNotEmpty)
                  ? userRequestData['pick_lng']
                  : addressList
                      .firstWhere((e) => e.type == 'pickup')
                      .latlng
                      .longitude,
              'transport_type':
                  (choosenTransportType == 0) ? 'taxi' : 'delivery'
            }));

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      rentalOption = etaDetails[0]['typesWithPrice']['data'];
      rentalChoosenOption = 0;
      choosenVehicle = 0;
      result = true;
      valueNotifierBook.incrementNotifier();
      // printWrapped('rental eta ' + response.body);
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

bool couponerror = false;
rentalRequestWithPromo() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/request/list-packages'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
          'pick_lng': addressList
              .firstWhere((e) => e.type == 'pickup')
              .latlng
              .longitude,
          'ride_type': 0,
          'promo_code': promoCode,
          'transport_type': (choosenTransportType == 0) ? 'taxi' : 'delivery'
        }));

    if (response.statusCode == 200) {
      etaDetails = jsonDecode(response.body)['data'];
      rentalOption = etaDetails[0]['typesWithPrice']['data'];
      rentalChoosenOption = 0;
      promoCode = '';
      promoStatus = 1;
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      promoStatus = 2;
      couponerror = true;
      // promoCode = '';
      valueNotifierBook.incrementNotifier();

      result = false;
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//calculate distance

calculateDistance(lat1, lon1, lat2, lon2) {
  double _lat1 = double.tryParse(lat1.toString()) ?? 0.0;
  double _lon1 = double.tryParse(lon1.toString()) ?? 0.0;
  double _lat2 = double.tryParse(lat2.toString()) ?? 0.0;
  double _lon2 = double.tryParse(lon2.toString()) ?? 0.0;
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((_lat2 - _lat1) * p) / 2 +
      cos(_lat1 * p) * cos(_lat2 * p) * (1 - cos((_lon2 - _lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}



//create request
createRequest(value, api) async {
  return await RideService.createRequest(value, api);
}

//create request

createRequestLater(val, api) async {
  return await RideService.createRequest(val, api);
}

//create request with promo code

createRequestLaterPromo() async {
  dynamic result;
  waitingTime = 0;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'drop_lat':
              addressList.firstWhere((e) => e.id == 'drop').latlng.latitude,
          'drop_lng':
              addressList.firstWhere((e) => e.id == 'drop').latlng.longitude,
          'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
          'ride_type': 0,
          'payment_opt': (etaDetails[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (etaDetails[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'drop_address': addressList.firstWhere((e) => e.id == 'drop').address,
          'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': etaDetails[choosenVehicle]['total']
        }));
    if (response.statusCode == 200) {
      myMarkers.clear();
      streamRequest();
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }

  return result;
}

//create rental request

createRentalRequest() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 0,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));
    if (response.statusCode == 200) {
      userRequestData = jsonDecode(response.body)['data'];
      streamRequest();
      result = 'success';

      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

createRentalRequestWithPromo() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 0,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));
    if (response.statusCode == 200) {
      userRequestData = jsonDecode(response.body)['data'];
      streamRequest();
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        debugPrint(response.body);
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

createRentalRequestLater() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 0,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id']
        }));
    if (response.statusCode == 200) {
      result = 'success';
      streamRequest();
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

createRentalRequestLaterPromo() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/create'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pick_lat':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.latitude,
          'pick_lng':
              addressList.firstWhere((e) => e.id == 'pickup').latlng.longitude,
          'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
          'ride_type': 0,
          'payment_opt': (rentalOption[choosenVehicle]['payment_type']
                      .toString()
                      .split(',')
                      .toList()[payingVia] ==
                  'card')
              ? 0
              : (rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()[payingVia] ==
                      'cash')
                  ? 1
                  : 2,
          'pick_address':
              addressList.firstWhere((e) => e.id == 'pickup').address,
          'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
          'trip_start_time': choosenDateTime.toString().substring(0, 19),
          'is_later': true,
          'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
          'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
        }));
    if (response.statusCode == 200) {
      myMarkers.clear();
      streamRequest();
      valueNotifierBook.incrementNotifier();
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      if (jsonDecode(response.body)['message'] == 'no drivers available') {
        noDriverFound = true;
      } else {
        debugPrint(response.body);
        tripReqError = true;
      }

      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }

  return result;
}

List<RequestCreate> createRequestList = <RequestCreate>[];

class RequestCreate {
  dynamic pickLat;
  dynamic pickLng;
  dynamic dropLat;
  dynamic dropLng;
  dynamic vehicleType;
  dynamic rideType;
  dynamic paymentOpt;
  dynamic pickAddress;
  dynamic dropAddress;
  dynamic promoCodeId;

  RequestCreate(
      {this.pickLat,
      this.pickLng,
      this.dropLat,
      this.dropLng,
      this.vehicleType,
      this.rideType,
      this.paymentOpt,
      this.pickAddress,
      this.dropAddress,
      this.promoCodeId});

  Map<String, dynamic> toJson() => {
        'pick_lat': pickLat,
        'pick_lng': pickLng,
        'drop_lat': dropLat,
        'drop_lng': dropLng,
        'vehicle_type': vehicleType,
        'ride_type': rideType,
        'payment_opt': paymentOpt,
        'pick_address': pickAddress,
        'drop_address': dropAddress,
        'promocode_id': promoCodeId
      };
}


//user cancel later request

cancelLaterRequest(val) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/cancel'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'request_id': val}));
    if (response.statusCode == 200) {
      userRequestData = {};
      if (requestStreamStart?.isPaused == false ||
          requestStreamEnd?.isPaused == false) {
        requestStreamStart?.cancel();
        requestStreamEnd?.cancel();
        requestStreamStart = null;
        requestStreamEnd = null;
      }
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//user cancel request
cancelRequest({bool autoCancel = false}) async {
  return await RideService.cancelRequest(autoCancel: autoCancel);
}

//user cancel request with reason

cancelRequestWithReason(reason) async {
  return await RideService.cancelRequest(reason: reason);
}

//making call to user

makingPhoneCall(phnumber) async {
  var mobileCall = 'tel:$phnumber';
  // ignore: deprecated_member_use
  if (await canLaunch(mobileCall)) {
    // ignore: deprecated_member_use
    await launch(mobileCall);
  } else {
    throw 'Could not launch $mobileCall';
  }
}

//cancellation reason
List cancelReasonsList = [];
cancelReason(reason) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(
          '${url}api/v1/common/cancallation/reasons?arrived=$reason&transport_type=${userRequestData['transport_type']}'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      cancelReasonsList = jsonDecode(response.body)['data'];
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

List<CancelReasonJson> cancelJson = <CancelReasonJson>[];

class CancelReasonJson {
  dynamic requestId;
  dynamic reason;

  CancelReasonJson({this.requestId, this.reason});

  Map<String, dynamic> toJson() {
    return {'request_id': requestId, 'reason': reason};
  }
}

//add user rating

userRating() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/rating'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': userRequestData['id'],
          'rating': review,
          'comment': feedback
        }));
    if (response.statusCode == 200) {
      ismulitipleride = false;
      await getUserDetails();
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//class for realtime database driver data

class NearByDriver {
  double bearing;
  String g;
  String id;
  List l;
  String updatedAt;

  NearByDriver(
      {required this.bearing,
      required this.g,
      required this.id,
      required this.l,
      required this.updatedAt});

  factory NearByDriver.fromJson(Map<String, dynamic> json) {
    return NearByDriver(
        id: json['id'],
        bearing: json['bearing'],
        g: json['g'],
        l: json['l'],
        updatedAt: json['updated_at']);
  }
}

//add favourites location

addFavLocation(name, address, lat, lng, type) async => await UserService.addFavLocation(name, address, lat, lng, type);

//sos data
getSosData() async => await SettingsService.getSosData();

//sos admin notification

notifyAdmin() async {
  var db = FirebaseDatabase.instance.ref();
  try {
    await db.child('SOS/${userRequestData['id']}').update({
      "is_driver": "0",
      "is_user": "1",
      "req_id": userRequestData['id'],
      "serv_loc_id": userRequestData['service_location_id'],
      "updated_at": ServerValue.timestamp
    });
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return true;
}

//get current ride messages

List chatList = [];

getCurrentMessages() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/request/chat-history/${userRequestData['id']}'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        if (chatList.where((element) => element['from_type'] == 2).length !=
            jsonDecode(response.body)['data']
                .where((element) => element['from_type'] == 2)
                .length) {}
        chatList = jsonDecode(response.body)['data'];
        messageSeen();

        valueNotifierBook.incrementNotifier();
      }
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//send chat

sendMessage(chat) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/request/send'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body:
            jsonEncode({'request_id': userRequestData['id'], 'message': chat}));
    if (response.statusCode == 200) {
      await getCurrentMessages();
      FirebaseDatabase.instance
          .ref('requests/${userRequestData['id']}')
          .update({'message_by_user': chatList.length});
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//message seen

messageSeen() async {
  var response = await http.post(Uri.parse('${url}api/v1/request/seen'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': userRequestData['id']}));
  if (response.statusCode == 200) {
    // getCurrentMessages();
  } else {
    debugPrint(response.body);
  }
}

//admin chat

dynamic chatStream;
String unSeenChatCount = '0';
streamAdminchat() async {
  chatStream = FirebaseDatabase.instance
      .ref()
      .child(
          'chats/${(adminChatList.length > 2) ? userDetails['chat_id'] : chatid}')
      .onValue
      .listen((event) async {
    var value =
        Map<String, dynamic>.from(jsonDecode(jsonEncode(event.snapshot.value)));
    if (value['to_id'].toString() == userDetails['id'].toString()) {
      adminChatList.add(jsonDecode(jsonEncode(event.snapshot.value)));
    }
    value.clear();
    if (adminChatList.isNotEmpty) {
      unSeenChatCount =
          adminChatList[adminChatList.length - 1]['count'].toString();
      if (unSeenChatCount == 'null') {
        unSeenChatCount = '0';
      }
    }
    valueNotifierChat.incrementNotifier();
  });
}

//admin chat

List adminChatList = [];
dynamic isnewchat = 1;
dynamic chatid;
getadminCurrentMessages() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/request/admin-chat-history'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      adminChatList.clear();
      isnewchat = jsonDecode(response.body)['data']['new_chat'];
      adminChatList = jsonDecode(response.body)['data']['chats'];
      if (adminChatList.isNotEmpty) {
        chatid = adminChatList[0]['chat_id'];
      }
      if (adminChatList.isNotEmpty && chatStream == null) {
        streamAdminchat();
      }
      unSeenChatCount = '0';
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

sendadminMessage(chat) async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/send-message'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json'
            },
            body: (isnewchat == 1)
                ? jsonEncode({'new_chat': isnewchat, 'message': chat})
                : jsonEncode({
                    'new_chat': 0,
                    'message': chat,
                    'chat_id': chatid,
                  }));
    if (response.statusCode == 200) {
      chatid = jsonDecode(response.body)['data']['chat_id'];
      adminChatList.add({
        'chat_id': chatid,
        'message': jsonDecode(response.body)['data']['message'],
        'from_id': userDetails['id'],
        'to_id': jsonDecode(response.body)['data']['to_id'],
        'user_timezone': jsonDecode(response.body)['data']['user_timezone']
      });
      isnewchat = 0;
      if (adminChatList.isNotEmpty && chatStream == null) {
        streamAdminchat();
      }
      unSeenChatCount = '0';
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      result = 'failed';
      debugPrint(response.body);
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

adminmessageseen() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(
          '${url}api/v1/request/update-notification-count?chat_id=$chatid'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      result = true;
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//add sos

addSos(name, number) async => await SettingsService.addSos(name, number);

//remove sos

deleteSos(id) async => await SettingsService.deleteSos(id);

//open url in browser

openBrowser(browseUrl) async {
  // ignore: deprecated_member_use
  if (await canLaunch(browseUrl)) {
    // ignore: deprecated_member_use
    await launch(browseUrl);
  } else {
    throw 'Could not launch $browseUrl';
  }
}

//get faq
List faqData = [];
Map<String, dynamic> myFaqPage = {};

getFaqData(lat, lng) async => await SettingsService.getFaqData(lat, lng);

getFaqPages(id) async => await SettingsService.getFaqPages(id);

//remove fav address

removeFavAddress(id) async => await UserService.removeFavAddress(id);

//get user referral
// Note: myReferralCode and getReferral() are now defined earlier in the file to avoid duplicates.


//user logout

userLogout() async => await AuthService.userLogout();

//request history
List myHistory = [];
Map<String, dynamic> myHistoryPage = {};

String historyFiltter = 'is_completed=1';
getHistory() async {
  dynamic result;
  try {
    // ignore: prefer_typing_uninitialized_variables
    var response;
    if (historyFiltter == '') {
      response = await http.get(
          Uri.parse('${url}api/v1/request/history?on_trip=0'),
          headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    } else {
      response = await http.get(
          Uri.parse('${url}api/v1/request/history?$historyFiltter'),
          headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    }
    if (response.statusCode == 200) {
      myHistory = jsonDecode(response.body)['data'];
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
    myHistory.removeWhere((element) => element.isEmpty);
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

getHistoryPages(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse('${url}api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        myHistory.add(element);
      });
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
    myHistory.removeWhere((element) => element.isEmpty);
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierBook.incrementNotifier();
    }
  }
  return result;
}

//get wallet history

Map<String, dynamic> get walletBalance => WalletService.walletBalance;
set walletBalance(Map<String, dynamic> value) => WalletService.walletBalance = value;

Map<String, dynamic> get paymentGateways => WalletService.paymentGateways;
set paymentGateways(Map<String, dynamic> value) => WalletService.paymentGateways = value;

List get walletHistory => WalletService.walletHistory;
set walletHistory(List value) => WalletService.walletHistory = value;

Map<String, dynamic> get walletPages => WalletService.walletPages;
set walletPages(Map<String, dynamic> value) => WalletService.walletPages = value;

getWalletHistory() async => await WalletService.getWalletHistory();

getWalletHistoryPage(page) async => await WalletService.getWalletHistoryPage(page);

//get client token for braintree

getClientToken() async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/payment/client/token'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//stripe payment

Map<String, dynamic> get stripeToken => WalletService.stripeToken;
set stripeToken(Map<String, dynamic> value) => WalletService.stripeToken = value;

getStripePayment(money) async => await WalletService.getStripePayment(money);

//stripe add money

addMoneyStripe(amount, nonce) async => await WalletService.addMoneyStripe(amount, nonce);

//stripe pay money

payMoneyStripe(nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/stripe/make-payment-for-ride'),
        headers: {
          'Authorization': 'Bearer ${bearerToken[0].token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'request_id': userRequestData['id'], 'payment_id': nonce}));
    if (response.statusCode == 200) {
      result = 'success';
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//paystack payment
Map<String, dynamic> get paystackCode => WalletService.paystackCode;
set paystackCode(Map<String, dynamic> value) => WalletService.paystackCode = value;

getPaystackPayment(body) async => await WalletService.getPaystackPayment(body);

addMoneyPaystack(amount, nonce) async => await WalletService.addMoneyPaystack(amount, nonce);

//flutterwave

addMoneyFlutterwave(amount, nonce) async => await WalletService.addMoneyFlutterwave(amount, nonce);

//razorpay

addMoneyRazorpay(amount, nonce) async => await WalletService.addMoneyRazorpay(amount, nonce);

//cashfree

Map<String, dynamic> get cftToken => WalletService.cftToken;
set cftToken(Map<String, dynamic> value) => WalletService.cftToken = value;

getCfToken(money, currency) async => await WalletService.getCfToken(money, currency);

Map<String, dynamic> get cfSuccessList => WalletService.cfSuccessList;
set cfSuccessList(Map<String, dynamic> value) => WalletService.cfSuccessList = value;

cashFreePaymentSuccess() async => await WalletService.cashFreePaymentSuccess();

//edit user profile

updateProfile(name, email, mobile, gender, image) async => await UserService.updateProfile(name, email, mobile, gender, image);

updateProfileWithoutImage(name, email, mobile, gender) async => await UserService.updateProfileWithoutImage(name, email, mobile, gender);

//internet true
internetTrue() {
  internet = true;
  valueNotifierHome.incrementNotifier();
}

//make complaint

List generalComplaintList = [];
getGeneralComplaint(type) async => await SettingsService.getGeneralComplaint(type);

makeGeneralComplaint(complaintDesc, index) async => await SettingsService.makeGeneralComplaint(complaintDesc, index);

makeRequestComplaint(requestId, complaintDesc, index) async => await SettingsService.makeRequestComplaint(requestId, complaintDesc, index);

//requestStream
StreamSubscription<DatabaseEvent>? requestStreamStart;
StreamSubscription<DatabaseEvent>? requestStreamEnd;
bool userCancelled = false;

streamRequest() {
  debugPrint('📡 [FIREBASE] streamRequest() called. ID: ${userRequestData['id']}');
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamUpdate?.cancel();
  rideStreamStart?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamUpdate = null;
  rideStreamStart = null;

  if (userRequestData['id'] == null) {
    debugPrint('📡 [FIREBASE] ❌ streamRequest failed: userRequestData["id"] is NULL');
    return;
  }

  requestStreamStart = FirebaseDatabase.instance
      .ref('request-meta')
      .child(userRequestData['id'].toString())
      .onValue
      .handleError((onError) {
    debugPrint('📡 [FIREBASE] ❌ request-meta Error: $onError');
    requestStreamStart?.cancel();
  }).listen((event) async {
    if (event.snapshot.value == null) {
      debugPrint('📡 [FIREBASE] ✅ request-meta: REMOVED via onValue (Ride Likely Accepted). Calling getUserDetails...');
      ismulitipleride = true;
      getUserDetails(id: userRequestData['id']);
      requestStreamStart?.cancel();
    } else {
      debugPrint('📡 [FIREBASE] 🔍 request-meta: Data present (${event.snapshot.value})');
    }
  });
}

StreamSubscription<DatabaseEvent>? rideStreamStart;

StreamSubscription<DatabaseEvent>? rideStreamUpdate;

streamRide() {
  debugPrint('📡 [FIREBASE] streamRide() called. ID: ${userRequestData['id']}');
  waitingTime = 0;
  requestStreamEnd?.cancel();
  requestStreamStart?.cancel();
  rideStreamUpdate?.cancel();
  rideStreamStart?.cancel();
  requestStreamStart = null;
  requestStreamEnd = null;
  rideStreamUpdate = null;
  rideStreamStart = null;

  if (userRequestData['id'] == null) {
    debugPrint('📡 [FIREBASE] ❌ streamRide failed: userRequestData["id"] is NULL');
    return;
  }

  rideStreamUpdate = FirebaseDatabase.instance
      .ref('requests/${userRequestData['id']}')
      .onChildChanged
      .handleError((onError) {
    debugPrint('📡 [FIREBASE] ❌ ride-stream Error: $onError');
    rideStreamUpdate?.cancel();
  }).listen((DatabaseEvent event) async {
    debugPrint('📡 [FIREBASE] 🔄 ride-stream: CHILD_CHANGED (${event.snapshot.key})');
    if (event.snapshot.key.toString() == 'modified_by_driver') {
      ismulitipleride = true;
      getUserDetails(id: userRequestData['id']);
    } else if (event.snapshot.key.toString() == 'message_by_driver') {
      getCurrentMessages();
    } else if (event.snapshot.key.toString() == 'cancelled_by_driver') {
      requestCancelledByDriver = true;
      ismulitipleride = true;
      // getUserDetails(id: userRequestData['id']);
      getUserDetails();
    } else if (event.snapshot.key.toString() == 'total_waiting_time') {
      var val = event.snapshot.value.toString();
      waitingTime = int.parse(val);
      valueNotifierBook.incrementNotifier();
    } else if (event.snapshot.key.toString() == 'is_accept' || 
               event.snapshot.key.toString() == 'is_completed' || 
               event.snapshot.key.toString() == 'is_driver_arrived' ||
               event.snapshot.key.toString() == 'is_trip_start' ||
               event.snapshot.key.toString() == 'total_distance' ||
               event.snapshot.key.toString() == 'total_time' ||
               event.snapshot.key.toString() == 'is_paid') {
      debugPrint('📡 [FIREBASE] 🏁 sync state: ${event.snapshot.key} = ${event.snapshot.value}');
      if (userRequestData.isNotEmpty) {
        var newVal = (event.snapshot.value == true) ? 1 : (event.snapshot.value == false ? 0 : event.snapshot.value);
        userRequestData[event.snapshot.key.toString()] = newVal;
        calculateRunningFare();
        valueNotifierHome.incrementNotifier();
        valueNotifierBook.incrementNotifier();
      }
      getUserDetails(id: userRequestData['id']);
    }
  });

  rideStreamStart = FirebaseDatabase.instance
      .ref('requests/${userRequestData['id']}')
      .onChildAdded
      .handleError((onError) {
    rideStreamStart?.cancel();
  }).listen((DatabaseEvent event) async {
    // if (event.snapshot.key.toString() == 'message_by_driver') {
    //   getCurrentMessages();
    // } else
    if (event.snapshot.key.toString() == 'cancelled_by_driver') {
      requestCancelledByDriver = true;
      ismulitipleride = true;
      // getUserDetails(id: userRequestData['id']);
      getUserDetails();
    } else if (event.snapshot.key.toString() == 'modified_by_driver') {
      ismulitipleride = true;
      getUserDetails(id: userRequestData['id']);
    } else if (event.snapshot.key.toString() == 'total_waiting_time') {
      var val = event.snapshot.value.toString();
      waitingTime = int.parse(val);
      valueNotifierBook.incrementNotifier();
    } else if (event.snapshot.key.toString() == 'is_accept' || 
               event.snapshot.key.toString() == 'is_completed' ||
               event.snapshot.key.toString() == 'total_distance' ||
               event.snapshot.key.toString() == 'total_time') {
      debugPrint('📡 [FIREBASE] 🏁 sync state: ${event.snapshot.key} = ${event.snapshot.value}');
      if (userRequestData.isNotEmpty) {
        var newVal = (event.snapshot.value == true) ? 1 : (event.snapshot.value == false ? 0 : event.snapshot.value);
        userRequestData[event.snapshot.key.toString()] = newVal;
        calculateRunningFare();
        valueNotifierHome.incrementNotifier();
        valueNotifierBook.incrementNotifier();
      }
      getUserDetails(id: userRequestData['id']);
    }
  });
}

//helper to parse server date
DateTime? parseServerDate(dynamic date) {
  if (date == null) return null;
  String s = date.toString().trim();
  if (s.isEmpty) return null;
  
  // Force UTC parsing for raw MySQL timestamps (e.g. "2026-04-13 20:55:00")
  // by replacing the space with 'T' and appending 'Z' if missing.
  if (!s.endsWith('Z') && !s.contains('+') && s.contains('-') && s.contains(':')) {
    s = '${s.replaceFirst(' ', 'T')}Z';
  }
  
  final iso = DateTime.tryParse(s);
  return iso;
}

//calculate running fare
calculateRunningFare() {
  final bool tripStarted = userRequestData.isNotEmpty &&
      (userRequestData['is_trip_start'].toString() == '1' ||
          userRequestData['is_trip_start'] == 1);

  final bool driverArrived = userRequestData.isNotEmpty &&
      (userRequestData['is_driver_arrived'].toString() == '1' ||
          userRequestData['is_driver_arrived'] == 1);

  final bool rideAccepted = userRequestData.isNotEmpty &&
      userRequestData['accepted_at'] != null;

  if (!rideAccepted) return;

  // Pricing fields with fallbacks
  var basePrice = userRequestData['base_price'] ??
      userRequestData['base_fare'] ??
      (userRequestData['type'] != null
          ? (userRequestData['type']['base_price'] ??
              userRequestData['type']['base_fare'])
          : 0);

  var distPrice = userRequestData['price_per_distance'] ??
      userRequestData['distance_price'] ??
      userRequestData['price_per_km'] ??
      (userRequestData['type'] != null
          ? (userRequestData['type']['price_per_distance'] ??
              userRequestData['type']['distance_price'] ??
              userRequestData['type']['price_per_km'])
          : 0);

  var timePrice = userRequestData['price_per_time'] ??
      userRequestData['time_price'] ??
      userRequestData['price_per_min'] ??
      (userRequestData['type'] != null
          ? (userRequestData['type']['price_per_time'] ??
              userRequestData['type']['time_price'] ??
              userRequestData['type']['price_per_min'])
          : 0);

  var waitingPrice = userRequestData['waiting_charge'] ??
      userRequestData['waiting_charge_per_min'] ??
      (userRequestData['type'] != null
          ? (userRequestData['type']['waiting_charge'] ??
              userRequestData['type']['waiting_charge_per_min'])
          : 0);

  var baseDistance = userRequestData['base_distance'] ??
      (userRequestData['type'] != null
          ? userRequestData['type']['base_distance']
          : 0);

  var bookingFee = userRequestData['booking_fee'] ??
      (userRequestData['type'] != null
          ? userRequestData['type']['booking_fee']
          : 0);

  var convFee = userRequestData['admin_commission'] ??
      (userRequestData['type'] != null
          ? userRequestData['type']['admin_commission']
          : 0);

  double base = double.tryParse(basePrice.toString()) ?? 0;
  double dPrice = double.tryParse(distPrice.toString()) ?? 0;
  double tPrice = double.tryParse(timePrice.toString()) ?? 0;
  double wPrice = double.tryParse(waitingPrice.toString()) ?? 0;
  double bDist = double.tryParse(baseDistance.toString()) ?? 0;
  double bFee = double.tryParse(bookingFee.toString()) ?? 0;
  double cFee = double.tryParse(convFee.toString()) ?? 0;

  double total;

  if (tripStarted) {
    // Current distance from server
    double dist = double.tryParse(
            (userRequestData['total_distance'] ??
                    userRequestData['distance'] ??
                    0)
                .toString()) ??
        0;

    // Time is now calculated absolutely using raw UTC timestamp from server
    DateTime? startTime = parseServerDate(userRequestData['raw_trip_start_time'] ?? userRequestData['trip_start_time']);
    double time = 0;
    if (startTime != null) {
      time = DateTime.now().difference(startTime).inSeconds / 60.0;
    } else {
      time = double.tryParse((userRequestData['total_time'] ?? 0).toString()) ?? 0;
    }

    // Waiting Time Logic
    DateTime? arrivedTime = parseServerDate(userRequestData['raw_arrived_at'] ?? userRequestData['arrived_at']);
    
    // 1. Pre-Trip Wait (Absolute: Arrived -> Start)
    double preTripWaitSecs = 0;
    if (arrivedTime != null && startTime != null) {
      preTripWaitSecs = startTime.difference(arrivedTime).inSeconds.toDouble();
    }
    
    // 2. In-Trip Wait (Recorded during movement/stops)
    // We use 'calculated_waiting_time' from server which usually contains total 
    // but we subtract the pre-trip part if the server is already tracking it there.
    // However, if we trust the driver's 'waiting_time_after_start' field if available.
    double inTripWaitSecs = double.tryParse((userRequestData['waiting_time_after_start'] ?? 0).toString()) ?? 0;
    
    // Fallback: If inTripWaitSecs is 0, check if calculated_waiting_time has anything
    if (inTripWaitSecs == 0) {
      double totalWaitServer = double.tryParse((userRequestData['calculated_waiting_time'] ?? 0).toString()) ?? 0;
      // If server total is greater than our absolute pre-trip, the extra is likely in-trip wait
      if (totalWaitServer > preTripWaitSecs) {
        inTripWaitSecs = totalWaitServer - preTripWaitSecs;
      }
    }

    // Free Waiting Time (Minutes)
    double freeWaitBefore = double.tryParse((userRequestData['free_waiting_time_in_mins_before_trip_start'] ?? 0).toString()) ?? 0;
    double freeWaitAfter = double.tryParse((userRequestData['free_waiting_time_in_mins_after_trip_start'] ?? 0).toString()) ?? 0;

    double billablePreWaitMins = max(0, (preTripWaitSecs / 60.0) - freeWaitBefore);
    double billableInWaitMins = max(0, (inTripWaitSecs / 60.0) - freeWaitAfter);
    double totalWaitMins = billablePreWaitMins + billableInWaitMins;

    debugPrint(
        '📍 [CALC_FARE] Trip: base=$base dist=$dist time=$time totalWaitMins=$totalWaitMins (pre=$billablePreWaitMins in=$billableInWaitMins)');

    total = base +
        ((dist > bDist) ? ((dist - bDist) * dPrice) : 0) +
        (time * tPrice) +
        (totalWaitMins * wPrice) +
        bFee +
        cFee;
  } else if (driverArrived) {
    // Driver waiting before trip starts
    DateTime? arrivedTime = parseServerDate(userRequestData['arrived_at']);
    double waitTimeSecs = 0;
    if (arrivedTime != null) {
      waitTimeSecs = DateTime.now().difference(arrivedTime).inSeconds.toDouble();
    } else {
      waitTimeSecs = double.tryParse(
            (userRequestData['calculated_waiting_time'] ?? 0).toString()) ?? 0;
    }
    
    double freeWaitBefore = double.tryParse((userRequestData['free_waiting_time_in_mins_before_trip_start'] ?? 0).toString()) ?? 0;
    double billableWaitMins = max(0, (waitTimeSecs / 60.0) - freeWaitBefore);
    
    total = base + (billableWaitMins * wPrice) + bFee + cFee;
    debugPrint('📍 [CALC_FARE] Waiting: base=$base billableWaitMins=$billableWaitMins');
  } else {
    // Standard base + fees
    total = base + bFee + cFee;
  }

  userRequestData['running_fare'] = total.toStringAsFixed(2);
  debugPrint('📍 [CALC_FARE] Result: ${userRequestData['running_fare']}');
}

//request notification
List notificationHistory = [];
Map<String, dynamic> notificationHistoryPage = {};

getnotificationHistory() async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      notificationHistory = jsonDecode(response.body)['data'];
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
    notificationHistory.removeWhere((element) => element.isEmpty);
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getNotificationPages(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/get-notification?$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        notificationHistory.add(element);
      });
      notificationHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//delete notification
deleteNotification(id) async {
  dynamic result;

  try {
    var response = await http.get(
        Uri.parse('${url}api/v1/notifications/delete-notification/$id'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});
    if (response.statusCode == 200) {
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

sharewalletfun({mobile, role, amount}) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse('${url}api/v1/payment/wallet/transfer-money-from-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${bearerToken[0].token}',
        },
        body: jsonEncode({'mobile': mobile, 'role': role, 'amount': amount}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

sendOTPtoEmail(String email) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/send-mail-otp'),
        headers: {},
        body: {'email': email});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      result = 'Something went wrong';
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

emailVerify(String email, otpNumber) async {
  dynamic val;
  try {
    var response = await http.post(Uri.parse('${url}api/v1/validate-email-otp'),
        headers: {},
        body: {"email": email, "otp": otpNumber});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        val = 'success';
      } else {
        debugPrint(response.body);
        val = 'failed';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      val = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      val = 'Something went wrong';
    }
    return val;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

paymentMethod(payment) async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse('${url}api/v1/request/user/payment-method'),
            headers: {
              'Authorization': 'Bearer ${bearerToken[0].token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'request_id': userRequestData['id'],
              'payment_opt': (payment == 'card')
                  ? 0
                  : (payment == 'cash')
                      ? 1
                      : (payment == 'wallet')
                          ? 2
                          : 4
            }));
    if (response.statusCode == 200) {
      FirebaseDatabase.instance
          .ref('requests')
          .child(userRequestData['id'])
          .update({'modified_by_user': ServerValue.timestamp});
      ismulitipleride = true;
      await getUserDetails(id: userRequestData['id']);
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

String isemailmodule = '1';
bool isCheckFireBaseOTP = false;
getemailmodule() async {
  dynamic res;
  try {
      var response = await http.get(
          Uri.parse('${url}api/v1/user/get-admin-details'),
          headers: {});
    if (response.statusCode == 200) {
      debugPrint('getemailmodule response: ${response.body}');
      isemailmodule = jsonDecode(response.body)['enable_email_otp'];
      isCheckFireBaseOTP = jsonDecode(response.body)['firebase_otp_enabled'];

      res = 'success';
    } else {
      debugPrint(response.body);
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }

  return res;
}

sendOTPtoMobile(String mobile, String countryCode) async {
  dynamic result;
  try {
    var response = await http.post(
      Uri.parse('${url}api/v1/mobile-otp'),
      body: {'mobile': mobile, 'country_code': countryCode},
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = jsonDecode(response.body)['message'] ?? 'something went wrong';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      result = 'something went wrong';
    }
    return result;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

validateSmsOtp(String mobile, String otp) async {
  dynamic result;
  try {
    var response = await http.post(
      Uri.parse('${url}api/v1/validate-otp'),
      body: {'mobile': mobile, 'otp': otp},
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        debugPrint(response.body);
        result = jsonDecode(response.body)['message'] ?? 'something went wrong';
      }
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      result = 'something went wrong';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
  return result;
}

List outStationList = [];
outStationListFun() async {
  dynamic result;
  try {
    final response = await http.get(
        Uri.parse('${url}api/v1/request/outstation_rides'),
        headers: {'Authorization': 'Bearer ${bearerToken[0].token}'});

    if (response.statusCode == 200) {
      outStationList = jsonDecode(response.body)['data'];
      result = 'success';
      valueNotifierBook.incrementNotifier();
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else {
      debugPrint(response.body);
      result = 'failure';
      valueNotifierBook.incrementNotifier();
    }
    outStationList.removeWhere((element) => element.isEmpty);
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierBook.incrementNotifier();
    }
  }

  return result;
}

List loginImages = [];
getLandingImages() async {
  dynamic result;
  try {
    final response = await http.get(Uri.parse('${url}api/v1/driver/documents'));

    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data']['countries']['data'];
      loginImages.clear();
      List _images = jsonDecode(response.body)['data']['onboarding']['data'];
      for (var element in _images) {
        if (element['screen'] == 'user') {
          loginImages.add(element);
        }
      }
      phcode =
          (countries.where((element) => element['default'] == true).isNotEmpty)
              ? countries.indexWhere((element) => element['default'] == true)
              : 0;
      result = 'success';
    } else {
      debugPrint(response.body);
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Future<void> saveListToPrefs(List<dynamic> list) async {
  final prefs = await SharedPreferences.getInstance();
  // Serialize the list to JSON
  final jsonString = json.encode(list);
  // Save the JSON string to shared preferences
  await prefs.setString('outstationpush', jsonString);
}

// Define a function to load the list from shared preferences
Future<List<dynamic>> loadListFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // Get the JSON string from shared preferences
  final jsonString = prefs.getString('outstationpush');
  if (jsonString != null) {
    // Parse the JSON string back into a list
    final List<dynamic> list = json.decode(jsonString);
    return list;
  }
  // Return an empty list if no data was found in shared preferences
  return [];
}

List outStationDriver = [];

//push notification
outStationPush() async {
  outStationPushStream = FirebaseDatabase.instance
      .ref()
      .child('bid-meta')
      .orderByChild('user_id')
      .equalTo(userDetails['id'].toString())
      .onValue
      .listen((event) async {
    if (jsonDecode(jsonEncode(event.snapshot.value)) != null) {
      Map rides = jsonDecode(jsonEncode(event.snapshot.value));
      rides.forEach((key, value) {
        if (value['drivers'] != null) {
          Map drivers = value['drivers'];
          drivers.forEach((k, v) {
            if (outStationDriver
                .where((e) => e['id'] == key && e['driver'] == k)
                .isEmpty) {
              outStationDriver
                  .add({'id': key, 'driver': k, 'price': v['price']});
              saveListToPrefs(outStationDriver);
              // pref.setString('outstationpush', json.encode(outStationDriver));
              RemoteNotification noti = RemoteNotification(
                  title: t('text_got_new_driver'),
                  body:
                      '${v['driver_name']} ${t('text_bid_ride_amount_of')} ${v['price']}');
              showRideNotification(noti);
            }
          });
        }
      });
    }
  });
}
