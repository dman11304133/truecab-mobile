import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'api_service.dart';
import 'functions.dart';

class AuthService {
  static Future<http.Response> userLoginApi(Map<String, dynamic> body) async {
    return await ApiService.postRaw('api/v1/user/login', body);
  }

  static Future<http.Response> validateMobileForLogin(Map<String, dynamic> body) async {
    return await ApiService.postRaw('api/v1/user/validate-mobile-for-login', body);
  }

  static Future<http.Response> validateMobile(Map<String, dynamic> body) async {
    return await ApiService.postRaw('api/v1/user/validate-mobile', body);
  }

  static Future<http.Response> sendBackendOTP(Map<String, dynamic> body) async {
    return await ApiService.post('api/v1/mobile-otp', body);
  }

  static Future<http.Response> validateBackendOTP(Map<String, dynamic> body) async {
    return await ApiService.post('api/v1/validate-otp', body);
  }

  static phoneAuth(String phone) async {
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

  static registerUser() async {
    bearerToken.clear();
    dynamic result;
    try {
      var token = await FirebaseMessaging.instance.getToken();
      var fcm = token.toString();
      final response = http.MultipartRequest('POST', Uri.parse('${url}api/v1/user/register'));
      response.headers.addAll({'Content-Type': 'application/json'});
      if (proImageFile != null) {
        response.files.add(await http.MultipartFile.fromPath('profile_picture', proImageFile));
      }
      response.fields.addAll({
        "name": name,
        "mobile": phnumber,
        "email": email,
        "device_token": fcm,
        "country": countries[phcode]['code'],
        "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
        'lang': choosenLanguage,
        'email_confirmed': (values == 0) ? '0' : '1'
      });

      var request = await response.send();
      var respon = await http.Response.fromStream(request);

      if (respon.statusCode == 200) {
        var jsonVal = jsonDecode(respon.body);
        bearerToken.add(BearerClass(type: jsonVal['token_type'].toString(), token: jsonVal['access_token'].toString()));
        pref.setString('Bearer', bearerToken[0].token);
        await getUserDetails();
        result = 'true';
      } else if (respon.statusCode == 422) {
        debugPrint(respon.body);
        var error = jsonDecode(respon.body)['errors'];
        result = error[error.keys.toList()[0]].toString().replaceAll('[', '').replaceAll(']', '').toString();
      } else {
        debugPrint(respon.body);
        result = jsonDecode(respon.body)['message'];
      }
      return result;
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  }

  static updatePassword(email, password, loginby) async {
    dynamic result;
    try {
      var response = await http.post(Uri.parse('${url}api/v1/user/update-password'), body: {
        if (loginby == true) 'email': email,
        if (loginby == false) 'mobile': email,
        'password': password
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success'] == true) {
          result = true;
        } else {
          result = jsonDecode(response.body)['message'];
        }
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

  static userLogin() async {
    debugPrint('🔐 [LOGIN] userLogin() called. values=$values, phnumber=$phnumber');
    bearerToken.clear();
    dynamic result;
    try {
      var token = await FirebaseMessaging.instance.getToken();
      var fcm = token.toString();
      debugPrint('🔐 [LOGIN] FCM token obtained: ${fcm.substring(0, 20)}...');
      var body = (values == 0)
            ? {
                "mobile": phnumber,
                'device_token': fcm,
                "login_by": platform == TargetPlatform.android ? 'android' : 'ios',
              }
            : {
                "email": email,
                "otp": otpNumber,
                'device_token': fcm,
                "login_by": platform == TargetPlatform.android ? 'android' : 'ios',
              };
      debugPrint('🔐 [LOGIN] Sending to api/v1/user/login: $body');
      var response = await userLoginApi(body);
      debugPrint('🔐 [LOGIN] Response status: ${response.statusCode}');
      debugPrint('🔐 [LOGIN] Response body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonVal = jsonDecode(response.body);
        bearerToken.add(BearerClass(type: jsonVal['token_type'].toString(), token: jsonVal['access_token'].toString()));
        result = true;
        debugPrint('🔐 [LOGIN] ✅ Login SUCCESS - token received');
        pref.setString('Bearer', bearerToken[0].token);
        package = await PackageInfo.fromPlatform();
        if (platform == TargetPlatform.android && package != null) {
          await FirebaseDatabase.instance.ref().update({'user_package_name': package.packageName.toString()});
        } else if (package != null) {
          await FirebaseDatabase.instance.ref().update({'user_bundle_id': package.packageName.toString()});
        }
      } else {
        debugPrint('🔐 [LOGIN] ❌ Login FAILED - status ${response.statusCode}: ${response.body}');
        result = false;
      }
      return result;
    } catch (e, stack) {
      debugPrint('🔐 [LOGIN] ❌ EXCEPTION: $e');
      debugPrint('🔐 [LOGIN] Stack: $stack');
      if (e is SocketException) {
        internet = false;
      }
    }
  }

  static getUserDetails({id}) async {
    debugPrint('👤 [USER] getUserDetails() called. id=$id, ismulitipleride=$ismulitipleride');
    dynamic result;
    try {
      var endpoint = (ismulitipleride) ? 'api/v1/user?current_ride=$id' : 'api/v1/user';
      debugPrint('👤 [USER] Calling: $endpoint');
      var response = await ApiService.get(endpoint);
      debugPrint('👤 [USER] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var decodedBody = jsonDecode(response.body);
        if (decodedBody['data'] == null) {
          debugPrint('👤 [USER] ❌ data is NULL in response');
          result = false;
          return result;
        }
        debugPrint('👤 [USER] ✅ data received, parsing user details...');
        userDetails = Map<String, dynamic>.from(decodedBody['data']);
        
        debugPrint('👤 [USER] Flags: has_ongoing_ride=${userDetails['has_ongoing_ride']}, onTripRequest=${userDetails['onTripRequest'] != null}');

        favAddress = (userDetails['favouriteLocations'] != null)
            ? userDetails['favouriteLocations']['data'] ?? []
            : [];
        sosData = (userDetails['sos'] != null) ? userDetails['sos']['data'] ?? [] : [];
        if (mapType == '') {
          mapType = userDetails['map_type'] ?? '';
        }
        if (outStationPushStream == null) {
          outStationPush();
        }
        if (userDetails['bannerImage'] != null &&
            userDetails['bannerImage']['data'] != null &&
            userDetails['bannerImage']['data'].toString().startsWith('{')) {
          banners.clear();
          var bannerData = userDetails['bannerImage']['data'];
          if (bannerData['image'] != null) {
            bannerData['image'] = bannerData['image']
                .toString()
                .replaceAll('trucabtt.com', 'trucabtt.com');
          }
          banners.add(bannerData);
        } else {
          banners = (userDetails['bannerImage'] != null)
              ? userDetails['bannerImage']['data'] ?? []
              : [];
          for (var i = 0; i < banners.length; i++) {
            if (banners[i]['image'] != null) {
              banners[i]['image'] = banners[i]['image']
                  .toString()
                  .replaceAll('trucabtt.com', 'trucabtt.com');
            }
          }
        }
        if (userDetails['onTripRequest'] != null) {
          addressList.clear();
          var newRideData = userDetails['onTripRequest']['data'];
          
          // Log entire data object for deep debugging
          debugPrint('👤 [USER_RAW_DATA] ${newRideData.toString()}');
          
          // Force flags if timestamps are present (server-side robustness)
          if (newRideData['accepted_at'] != null && 
              (newRideData['is_accept'] == null || newRideData['is_accept'] == 0)) {
            newRideData['is_accept'] = 1;
            debugPrint('📍 [USER] 🛠️ Forced is_accept=1 (accepted_at was found)');
          }
          if (newRideData['completed_at'] != null && 
              (newRideData['is_completed'] == null || newRideData['is_completed'] == 0)) {
            newRideData['is_completed'] = 1;
            debugPrint('📍 [USER] 🛠️ Forced is_completed=1 (completed_at was found)');
          }

          debugPrint('📍 [USER] onTripRequest Data Found! id=${newRideData['id']}, is_accept=${newRideData['is_accept']}, is_completed=${newRideData['is_completed']}, accepted_at=${newRideData['accepted_at']}');

          if (userRequestData.isEmpty || userRequestData['accepted_at'] != newRideData['accepted_at']) {
            debugPrint('📍 [USER] Ride Accepted or Reset! Clearing polylines.');
            polyline.clear();
            fmpoly.clear();
          } else if (userRequestData.isEmpty || userRequestData['is_driver_arrived'] != newRideData['is_driver_arrived']) {
            debugPrint('📍 [USER] Driver Arrived status changed! Clearing polylines.');
            polyline.clear();
            fmpoly.clear();
          }

          userRequestData = newRideData;
          debugPrint('📍 [USER] Coordinates: pick_lat=${userRequestData['pick_lat']} (${userRequestData['pick_lat'].runtimeType}), drop_lat=${userRequestData['drop_lat']} (${userRequestData['drop_lat'].runtimeType})');
          if (userRequestData['is_driver_arrived'] == 1 && polyline.isEmpty) {
            polyGot = true;
            getPolylines('', '', '', '');
            changeBound = true;
          }
          calculateRunningFare();
          if (userRequestData['transport_type'] == 'taxi') {
            choosenTransportType = 0;
          } else {
            choosenTransportType = 1;
          }
          tripStops = userDetails['onTripRequest']['data']['requestStops']['data'];
          addressList.add(AddressList(
              id: '1',
              type: 'pickup',
              address: userRequestData['pick_address'],
              latlng: LatLng(double.tryParse(userRequestData['pick_lat'].toString()) ?? 0.0, double.tryParse(userRequestData['pick_lng'].toString()) ?? 0.0),
              name: userRequestData['pickup_poc_name'],
              pickup: true,
              number: userRequestData['pickup_poc_mobile'],
              instructions: userRequestData['pickup_poc_instruction']));
          if (tripStops.isNotEmpty) {
            for (var i = 0; i < tripStops.length; i++) {
              addressList.add(AddressList(
                  id: (i + 2).toString(),
                  type: 'drop',
                  pickup: false,
                  address: tripStops[i]['address'],
                  latlng: LatLng(double.tryParse(tripStops[i]['latitude'].toString()) ?? 0.0, double.tryParse(tripStops[i]['longitude'].toString()) ?? 0.0),
                  name: tripStops[i]['poc_name'],
                  number: tripStops[i]['poc_mobile'],
                  instructions: tripStops[i]['poc_instruction']));
            }
          } else if (userDetails['onTripRequest']['data']['is_rental'] != true && userRequestData['drop_lat'] != null) {
            addressList.add(AddressList(
                id: '2',
                type: 'drop',
                pickup: false,
                address: userRequestData['drop_address'],
                latlng: LatLng(double.tryParse(userRequestData['drop_lat'].toString()) ?? 0.0, double.tryParse(userRequestData['drop_lng'].toString()) ?? 0.0),
                name: userRequestData['drop_poc_name'],
                number: userRequestData['drop_poc_mobile'],
                instructions: userRequestData['drop_poc_instruction']));
          }
          if (userRequestData.isNotEmpty) {
            if (rideStreamUpdate == null || rideStreamUpdate?.isPaused == true || rideStreamStart == null || rideStreamStart?.isPaused == true) {
              streamRide();
            }
          } else {
            if (rideStreamUpdate != null || rideStreamUpdate?.isPaused == false || rideStreamStart != null || rideStreamStart?.isPaused == false) {
              rideStreamUpdate?.cancel();
              rideStreamUpdate = null;
              rideStreamStart?.cancel();
              rideStreamStart = null;
            }
          }
          valueNotifierHome.incrementNotifier();
          valueNotifierBook.incrementNotifier();
        } else if (userDetails['metaRequest'] != null) {
          addressList.clear();
          userRequestData = userDetails['metaRequest']['data'];
          tripStops = userDetails['metaRequest']['data']['requestStops']['data'];
          addressList.add(AddressList(
              id: '1',
              type: 'pickup',
              address: userRequestData['pick_address'],
              pickup: true,
              latlng: LatLng(double.tryParse(userRequestData['pick_lat'].toString()) ?? 0.0, double.tryParse(userRequestData['pick_lng'].toString()) ?? 0.0),
              name: userRequestData['pickup_poc_name'],
              number: userRequestData['pickup_poc_mobile'],
              instructions: userRequestData['pickup_poc_instruction']));

          if (tripStops.isNotEmpty) {
            for (var i = 0; i < tripStops.length; i++) {
              addressList.add(AddressList(
                  id: (i + 2).toString(),
                  type: 'drop',
                  pickup: false,
                  address: tripStops[i]['address'],
                  latlng: LatLng(double.tryParse(tripStops[i]['latitude'].toString()) ?? 0.0, double.tryParse(tripStops[i]['longitude'].toString()) ?? 0.0),
                  name: tripStops[i]['poc_name'],
                  number: tripStops[i]['poc_mobile'],
                  instructions: tripStops[i]['poc_instruction']));
            }
          } else if (userDetails['metaRequest']['data']['is_rental'] != true && userRequestData['drop_lat'] != null) {
            addressList.add(AddressList(
                id: '2',
                type: 'drop',
                address: userRequestData['drop_address'],
                pickup: false,
                latlng: LatLng(double.tryParse(userRequestData['drop_lat'].toString()) ?? 0.0, double.tryParse(userRequestData['drop_lng'].toString()) ?? 0.0),
                name: userRequestData['drop_poc_name'],
                number: userRequestData['drop_poc_mobile'],
                instructions: userRequestData['drop_poc_instruction']));
          }
          if (polyline.isEmpty) {
            polyGot = true;
            getPolylines('', '', '', '');
            changeBound = true;
          }

          if (userRequestData['transport_type'] == 'taxi') {
            choosenTransportType = 0;
          } else {
            choosenTransportType = 1;
          }

          // request-meta was already consumed (that's how we got here).
          // Only start streamRide() to monitor for driver acceptance.
          // Do NOT call streamRequest() here — it would loop infinitely
          // because request-meta is already null.
          if (rideStreamUpdate == null || rideStreamUpdate?.isPaused == true || rideStreamStart == null || rideStreamStart?.isPaused == true) {
            streamRide();
          }
          valueNotifierHome.incrementNotifier();
          valueNotifierBook.incrementNotifier();
        } else {
          chatList.clear();
          debugPrint('👤 [USER] ⚠️ onTripRequest is NULL. userRequestData count: ${userRequestData.length}');
          if (userRequestData.isNotEmpty) {
            debugPrint('👤 [USER] 🏁 Last Known Ride status: is_completed=${userRequestData['is_completed']}, is_cancelled=${userRequestData['is_cancelled']}');
          }
          
          // Only clear userRequestData if we are NOT in a specific ride request flow
          // or if the generic endpoint explicitly confirms there are no rides.
          if (id == null) {
            if (userRequestData.isNotEmpty) {
              polyline.clear();
              fmpoly.clear();
            }
            userRequestData = {};
            debugPrint('👤 [USER] 🚫 Global userRequestData CLEARED (Generic Case)');
          } else {
            debugPrint('👤 [USER] ⚠️ Preserved userRequestData (Missing from API but ID was $id)');
          }

          requestStreamStart?.cancel();
          requestStreamEnd?.cancel();
          rideStreamUpdate?.cancel();
          rideStreamStart?.cancel();
          requestStreamEnd = null;
          requestStreamStart = null;
          rideStreamUpdate = null;
          rideStreamStart = null;
          valueNotifierHome.incrementNotifier();
          valueNotifierBook.incrementNotifier();
        }
        if (userDetails['active'] == false || userDetails['active'] == 0) {
          isActive = 'false';
        } else {
          isActive = 'true';
        }
        result = true;
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = false;
      }
    } catch (e, stack) {
      debugPrint('👤 [USER] ❌ EXCEPTION in getUserDetails: $e');
      debugPrint('👤 [USER] Stack: $stack');
      if (e is SocketException) {
        internet = false;
      }
    }
    debugPrint('👤 [USER] RETURNING: $result');
    return result;
  }

  static userLogout() async {
    dynamic result;
    try {
      var response = await http.post(Uri.parse('${url}api/v1/logout'), headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      });
      if (response.statusCode == 200) {
        pref.remove('Bearer');
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } catch (e) {
      if (e is SocketException) {
        result = 'no internet';
        internet = false;
      }
    }
    return result;
  }

  static updateReferral() async {
    dynamic result;
    try {
      var response = await http.post(Uri.parse('${url}api/v1/update/user/referral'),
          headers: {
            'Authorization': 'Bearer ${bearerToken[0].token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"refferal_code": referralCode}));
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success'] == true) {
          result = 'true';
        } else {
          debugPrint(response.body);
          result = 'false';
        }
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'false';
      }
      return result;
    } catch (e) {
      if (e is SocketException) {
        internet = false;
      }
    }
  }

  static otpCall() async {
    debugPrint('📱 [OTP] otpCall() called. isCheckFireBaseOTP=$isCheckFireBaseOTP');
    dynamic result = false;
    try {
      if (isCheckFireBaseOTP == false) {
        debugPrint('📱 [OTP] Firebase OTP is DISABLED, returning false');
        return false;
      }
      var otp = await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
      result = otp.value == true;
      debugPrint('📱 [OTP] Firebase call_FB_OTP value: ${otp.value}, result=$result');
    } catch (e) {
      debugPrint('📱 [OTP] ❌ EXCEPTION: $e');
      if (e is SocketException) {
        internet = false;
        result = 'no Internet';
        valueNotifierHome.incrementNotifier();
      }
    }
    return result;
  }

  static verifyUser(String number) async {
    debugPrint('🔍 [VERIFY] verifyUser() called. number=$number, values=$values, email=$email');
    dynamic val = false;
    try {
      var body = (values == 0) ? {"mobile": number} : {"email": email};
      debugPrint('🔍 [VERIFY] Calling validateMobileForLogin with: $body');
      var response = await validateMobileForLogin(body);
      debugPrint('🔍 [VERIFY] validateMobileForLogin status: ${response.statusCode}');
      debugPrint('🔍 [VERIFY] validateMobileForLogin body: ${response.body}');

      if (response.statusCode == 200) {
        val = jsonDecode(response.body)['success'];
        debugPrint('🔍 [VERIFY] success=$val');

        if (val == true) {
          debugPrint('🔍 [VERIFY] User exists! Calling userLogin()...');
          var check = await userLogin();
          debugPrint('🔍 [VERIFY] userLogin() returned: $check');
          if (check == true) {
            debugPrint('🔍 [VERIFY] Login OK! Calling getUserDetails()...');
            var uCheck = await getUserDetails();
            debugPrint('🔍 [VERIFY] getUserDetails() returned: $uCheck');
            val = uCheck;
          } else {
            debugPrint('🔍 [VERIFY] ❌ userLogin() FAILED');
            val = false;
          }
        } else {
          debugPrint('🔍 [VERIFY] ❌ User does NOT exist on server');
          val = false;
        }
      } else if (response.statusCode == 422) {
        debugPrint('🔍 [VERIFY] ❌ 422 Error: ${response.body}');
        var error = jsonDecode(response.body)['errors'];
        val = error[error.keys.toList()[0]].toString().replaceAll('[', '').replaceAll(']', '').toString();
      } else {
        debugPrint('🔍 [VERIFY] ❌ Error status ${response.statusCode}: ${response.body}');
        val = jsonDecode(response.body)['message'] ?? 'Unknown error';
      }
      debugPrint('🔍 [VERIFY] FINAL RESULT: $val');
      return val ?? false;
    } catch (e, stack) {
      debugPrint('🔍 [VERIFY] ❌ EXCEPTION: $e');
      debugPrint('🔍 [VERIFY] Stack: $stack');
      if (e is SocketException) {
        internet = false;
      }
      return false;
    }
  }

  static userDelete() async {
    dynamic result;
    try {
      var response = await http.post(Uri.parse('${url}api/v1/user/delete-user-account'), headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      });
      if (response.statusCode == 200) {
        pref.remove('Bearer');
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failure';
      }
    } catch (e) {
      if (e is SocketException) {
        result = 'no internet';
        internet = false;
      }
    }
    return result;
  }
}
