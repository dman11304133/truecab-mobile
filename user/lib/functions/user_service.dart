import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'functions.dart';

class UserService {
  static Map<String, dynamic> myReferralCode = {};

  static Future<String> updateProfile(String? name, String? email, String? mobile, String? gender, String? image) async {
    String result = 'failure';
    try {
      debugPrint('👤 [PROFILE_UPDATE] Calling api/v1/user/profile');
      
      var request = http.MultipartRequest('POST', Uri.parse('${url}api/v1/user/profile'));
      request.headers.addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
      request.fields.addAll({
        'name': name ?? '',
        'email': email ?? '',
        'mobile': mobile ?? '',
        'gender': gender ?? '',
      });
      
      if (image != null && image.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', image));
      }

      var streamingResponse = await request.send();
      var response = await http.Response.fromStream(streamingResponse);
      
      debugPrint('👤 [PROFILE_UPDATE] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        await getUserDetails();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint('⚠️ [PROFILE_UPDATE] Failure: ${response.body}');
        result = 'failure';
      }
    } catch (e) {
      debugPrint('🚨 [PROFILE_UPDATE] Exception: $e');
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> updateProfileWithoutImage(String? name, String? email, String? mobile, String? gender) async {
    String result = 'failure';
    try {
      debugPrint('👤 [PROFILE_UPDATE_NO_IMG] Calling api/v1/user/profile');
      
      var response = await ApiService.post('api/v1/user/profile', {
        'name': name ?? '',
        'email': email ?? '',
        'mobile': mobile ?? '',
        'gender': gender ?? '',
      });

      debugPrint('👤 [PROFILE_UPDATE_NO_IMG] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        await getUserDetails();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint('⚠️ [PROFILE_UPDATE_NO_IMG] Failure: ${response.body}');
        result = 'failure';
      }
    } catch (e) {
      debugPrint('🚨 [PROFILE_UPDATE_NO_IMG] Exception: $e');
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> addFavLocation(String name, String address, double lat, double lng, String type) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/user/add-favourite-location', {
        'pick_address': address,
        'pick_lat': lat,
        'pick_lng': lng,
        'drop_address': address,
        'drop_lat': lat,
        'drop_lng': lng,
        'address_name': name,
        'address_type': type,
      });
      if (response.statusCode == 200) {
        await getUserDetails();
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

  static Future<String> removeFavAddress(String id) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/user/delete-favourite-location/$id', {});
      if (response.statusCode == 200) {
        await getUserDetails();
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

  static Future<String> getReferral() async {
    String result = '';
    try {
      debugPrint('UserService.getReferral() [API] Calling: ${url}api/v1/get/referral');
      var response = await http.get(Uri.parse('${url}api/v1/get/referral'), headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 15));
      
      debugPrint('UserService.getReferral() [API] Status: ${response.statusCode}');
      debugPrint('UserService.getReferral() [API] Response: ${response.body}');
      
      if (response.statusCode == 200) {
        myReferralCode = jsonDecode(response.body)['data'] ?? {};
        debugPrint('UserService.myReferralCode updated: $myReferralCode');
        result = 'success';
        valueNotifierBook.incrementNotifier();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint('UserService.getReferral() [API] Failed: ${response.body}');
        result = 'failure';
      }
    } catch (e) {
      debugPrint('UserService.getReferral() [API] Exception: $e');
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      } else {
        result = 'error: $e';
      }
    }
    return result;
  }

  static Future<void> getCountryCode() async {
    try {
      var response = await http.get(Uri.parse('${url}api/v1/countries'));
      if (response.statusCode == 200) {
        countries = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> getLocalData() async {
    pref = await SharedPreferences.getInstance();
    if (pref.getString('Bearer') != null) {
      bearerToken.add(BearerClass(type: 'Bearer', token: pref.getString('Bearer')!));
    }
  }
}
