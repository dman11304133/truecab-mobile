import 'dart:convert';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'functions.dart';

class AuthService {
  // ─── Login ────────────────────────────────────────────────────────────────

  static Future<dynamic> driverLogin(Map<String, dynamic> params) async {
    return await ApiService.postRaw('api/v1/driver/login', params.map((key, value) => MapEntry(key, value.toString())));
  }

  // ─── Validate Mobile / Email ──────────────────────────────────────────────

  static Future<dynamic> validateMobile(Map<String, dynamic> params) async {
    return await ApiService.postRaw('api/v1/driver/validate-mobile', params.map((key, value) => MapEntry(key, value.toString())));
  }

  static Future<dynamic> validateEmail(Map<String, dynamic> params) async {
    return await ApiService.postRaw('api/v1/driver/validate-mobile', params.map((key, value) => MapEntry(key, value.toString())));
  }

  // ─── OTP (backend-driven) ─────────────────────────────────────────────────

  static Future<dynamic> sendBackendOTP(String mobile, String countryCode) async {
    return await ApiService.postRaw('api/v1/mobile-otp', {
      'mobile': mobile,
      'country_code': countryCode,
    });
  }

  static Future<dynamic> validateBackendOTP(String mobile, String otp) async {
    return await ApiService.postRaw('api/v1/validate-otp', {
      'mobile': mobile,
      'otp': otp,
    });
  }

  // ─── Password Update ──────────────────────────────────────────────────────

  static Future<dynamic> updatePassword(String credential, String password, bool loginByEmail) async {
    dynamic result;
    try {
      var response = await ApiService.postRaw('api/v1/driver/update-password', {
        if (loginByEmail) 'email': credential,
        if (!loginByEmail) 'mobile': credential,
        'password': password,
        'role': ischeckownerordriver,
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

  // ─── Verify user exists and login ─────────────────────────────────────────

  static Future<dynamic> verifyUser(String number) async {
    dynamic val;
    try {
      debugPrint('🚗 [VERIFY] verifyUser called. number=$number, values=$values, role=$ischeckownerordriver');
      var response = await ApiService.postRaw(
          'api/v1/driver/validate-mobile-for-login',
          (values == 0)
              ? {'mobile': number, 'role': ischeckownerordriver}
              : {'email': number, 'role': ischeckownerordriver});
      
      debugPrint('🚗 [VERIFY] response status: ${response.statusCode}');
      debugPrint('🚗 [VERIFY] response body: ${response.body}');

      if (response.statusCode == 200) {
        val = jsonDecode(response.body)['success'];
        debugPrint('🚗 [VERIFY] validate success=$val');
        if (val == true) {
          var check = await loginDriver();
          debugPrint('🚗 [VERIFY] loginDriver returned: $check');
          if (check == true) {
            var uCheck = await getUserDetails();
            debugPrint('🚗 [VERIFY] getUserDetails returned: $uCheck');
            val = uCheck;
          } else {
            val = false;
          }
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
        debugPrint(response.body);
        val = jsonDecode(response.body)['message'];
      }
    } catch (e) {
      debugPrint('🚗 [VERIFY] ❌ ERROR: $e');
      if (e is SocketException) {
        val = 'no internet';
        internet = false;
      } else {
        val = 'Error: $e';
      }
    }
    debugPrint('🚗 [VERIFY] FINAL RESULT: $val');
    return val;
  }

  // ─── Full driver login flow ───────────────────────────────────────────────

  static Future<dynamic> loginDriver() async {
    bearerToken.clear();
    dynamic result;
    try {
      var token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 15)).catchError((e) {
        debugPrint('🚗 [AUTH] Firebase getToken timed out or failed: $e');
        return 'no_token_available';
      });
      var fcm = token.toString();
      debugPrint('🚗 [LOGIN] loginDriver called. phnumber=$phnumber, fcm=${fcm.substring(0, 20)}...');
      var response = await AuthService.driverLogin(
        (values == 0)
            ? {
                'mobile': phnumber,
                'device_token': fcm,
                'login_by': platform.toString().contains('android') ? 'android' : 'ios',
                'role': ischeckownerordriver,
              }
            : {
                'email': email,
                'otp': otpNumber,
                'device_token': fcm,
                'login_by': platform.toString().contains('android') ? 'android' : 'ios',
                'role': ischeckownerordriver,
              },
      );
      debugPrint('🚗 [LOGIN] response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonVal = jsonDecode(response.body);
        if (ischeckownerordriver == 'driver') {
          platforms.invokeMethod('login');
        }
        bearerToken.add(BearerClass(
            type: jsonVal['token_type'].toString(),
            token: jsonVal['access_token'].toString()));
        pref.setString('Bearer', bearerToken[0].token);
        debugPrint('🚗 [LOGIN] ✅ Token saved: ${bearerToken[0].token.substring(0, 20)}...');
        
        package = await PackageInfo.fromPlatform();
        if (package != null) {
          if (platform == TargetPlatform.android) {
            await FirebaseDatabase.instance
                .ref()
                .update({'driver_package_name': package.packageName.toString()});
          } else {
            await FirebaseDatabase.instance
                .ref()
                .update({'driver_bundle_id': package.packageName.toString()});
          }
        }
        result = true;
      } else {
        debugPrint('🚗 [LOGIN] ❌ FAILED: ${response.body}');
        result = false;
      }
    } catch (e) {
      debugPrint('🚗 [LOGIN] ❌ EXCEPTION: $e');
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  static Future<String> userLogout() async {
    dynamic result;
    var id = userDetails['id'];
    var role = userDetails['role'];
    try {
      var response = await ApiService.post('api/v1/logout', {});
      if (response.statusCode == 200) {
        platforms.invokeMethod('logout');
        if (role != 'owner') {
          final position = FirebaseDatabase.instance.ref();
          position.child('drivers/driver_$id').update({'is_active': 0});
        }
        rideStreamStart?.cancel();
        rideStreamChanges?.cancel();
        requestStreamEnd?.cancel();
        requestStreamStart?.cancel();
        rideStreamStart = null;
        rideStreamChanges = null;
        requestStreamStart = null;
        requestStreamEnd = null;
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

  // ─── Register Driver ──────────────────────────────────────────────────────

  static Future<dynamic> registerDriver() async {
    bearerToken.clear();
    dynamic result;
    try {
      var token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 15)).catchError((e) {
        debugPrint('🚗 [AUTH] Firebase getToken timed out or failed: $e');
        return 'no_token_available';
      });
      var fcm = token.toString();
      final response = ApiService.buildMultipartRequest(
          'POST', 'api/v1/driver/register');

      if (proImageFile1 != null) {
        response.files.add(
            await ApiService.multipartFile('profile_picture', proImageFile1));
      }
      response.fields.addAll({
        'name': name,
        'mobile': phnumber,
        'email': email,
        'device_token': fcm,
        'country': countries[phcode]['code'],
        'service_location_id': myServiceId.toString(),
        'login_by': platform.toString().contains('android') ? 'android' : 'ios',
        'vehicle_types': jsonEncode(vehicletypelist),
        'car_make': vehicleMakeId.toString(),
        'car_model': vehicleModelId.toString(),
        'car_color': vehicleColor,
        'car_number': vehicleNumber,
        'vehicle_year': modelYear,
        'lang': choosenLanguage,
        'custom_make': mycustommake,
        'custom_model': mycustommodel,
      });
      var request = await response.send();
      var respon = await ApiService.responseFromStream(request);

      if (request.statusCode == 200) {
        var jsonVal = jsonDecode(respon.body);
        if (ischeckownerordriver == 'driver') {
          platforms.invokeMethod('login');
        }
        bearerToken.add(BearerClass(
            type: jsonVal['token_type'].toString(),
            token: jsonVal['access_token'].toString()));
        pref.setString('Bearer', bearerToken[0].token);
        await getUserDetails();
        if (package != null) {
          await FirebaseDatabase.instance.ref().update(
              platform.toString().contains('android')
                  ? {'driver_package_name': package.packageName.toString()}
                  : {'driver_bundle_id': package.packageName.toString()});
        }
        result = 'true';
      } else if (respon.statusCode == 422) {
        debugPrint(respon.body);
        var error = jsonDecode(respon.body)['errors'];
        result = error[error.keys.toList()[0]]
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '')
            .toString();
      } else {
        debugPrint(respon.body);
        result = jsonDecode(respon.body)['message'];
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  // ─── Register Owner ───────────────────────────────────────────────────────

  static Future<dynamic> registerOwner() async {
    bearerToken.clear();
    dynamic result;
    try {
      var token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 15)).catchError((e) {
        debugPrint('🚗 [AUTH] Firebase getToken timed out or failed: $e');
        return 'no_token_available';
      });
      var fcm = token.toString();
      final response = ApiService.buildMultipartRequest(
          'POST', 'api/v1/owner/register');

      if (proImageFile1 != null) {
        response.files.add(
            await ApiService.multipartFile('profile_picture', proImageFile1));
      }
      response.fields.addAll({
        'name': name,
        'mobile': phnumber,
        'email': email,
        'address': companyAddress,
        'postal_code': postalCode,
        'city': city,
        'tax_number': taxNumber,
        'company_name': companyName,
        'device_token': fcm,
        'country': countries[phcode]['code'],
        'service_location_id': myServiceId.toString(),
        'login_by': platform.toString().contains('android') ? 'android' : 'ios',
        'lang': choosenLanguage,
      });
      var request = await response.send();
      var respon = await ApiService.responseFromStream(request);

      if (respon.statusCode == 200) {
        var jsonVal = jsonDecode(respon.body);
        bearerToken.add(BearerClass(
            type: jsonVal['token_type'].toString(),
            token: jsonVal['access_token'].toString()));
        pref.setString('Bearer', bearerToken[0].token);
        await getUserDetails();
        if (package != null) {
          await FirebaseDatabase.instance.ref().update(
              platform.toString().contains('android')
                  ? {'driver_package_name': package.packageName.toString()}
                  : {'driver_bundle_id': package.packageName.toString()});
        }
        result = 'true';
      } else if (respon.statusCode == 422) {
        debugPrint(respon.body);
        var error = jsonDecode(respon.body)['errors'];
        result = error[error.keys.toList()[0]]
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '')
            .toString();
      } else {
        debugPrint(respon.body);
        result = jsonDecode(respon.body)['message'];
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }
  static Future<dynamic> userDelete() async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/user/delete', {});
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
        result = 'no internet';
        internet = false;
      }
    }
    return result;
  }
}
