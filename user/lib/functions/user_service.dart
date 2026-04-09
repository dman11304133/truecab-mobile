import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'functions.dart';

class UserService {
  static Map<String, dynamic> myReferralCode = {};

  static Future<String> updateProfile(String name, String email, String mobile, String gender, String image) async {
    String result = '';
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${url}api/v1/user/update-profile'));
      request.headers.addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
      request.fields.addAll({
        'name': name,
        'email': email,
        'mobile': mobile,
        'gender': gender,
      });
      if (image.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', image));
      }
      var response = await request.send();
      var respon = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        await getUserDetails();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(respon.body);
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

  static Future<String> updateProfileWithoutImage(String name, String email, String mobile, String gender) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/user/update-profile', {
        'name': name,
        'email': email,
        'mobile': mobile,
        'gender': gender,
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
      var response = await ApiService.get('api/v1/get/referral');
      if (response.statusCode == 200) {
        myReferralCode = jsonDecode(response.body)['data'];
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
