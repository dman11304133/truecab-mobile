import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'functions.dart';
import '../translation/translation.dart';

class UserService {
  static Future<String> updateProfile(String name, String email, dynamic image) async {
    dynamic result;
    try {
      var response = http.MultipartRequest(
        'POST',
        Uri.parse('${url}api/v1/user/driver-profile'),
      );
      response.headers.addAll({'Authorization': 'Bearer ${bearerToken[0].token}'});
      if (image != null) {
        response.files.add(await http.MultipartFile.fromPath('profile_picture', image));
      }

      response.fields['email'] = email;
      response.fields['name'] = name;
      var request = await response.send();
      var respon = await http.Response.fromStream(request);
      final val = jsonDecode(respon.body);

      if (request.statusCode == 200) {
        result = 'success';
        if (val['success'] == true) {
          await getUserDetails();
        }
      } else if (request.statusCode == 401) {
        result = 'logout';
      } else if (request.statusCode == 422) {
        debugPrint(respon.body);
        var error = jsonDecode(respon.body)['errors'];
        result = error[error.keys.toList()[0]].toString().replaceAll('[', '').replaceAll(']', '').toString();
      } else {
        debugPrint(val);
        result = jsonDecode(respon.body)['message'];
      }
    } catch (e) {
      result = languages[choosenLanguage]['text_email_already_taken'];
      if (e is SocketException) {
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> getBankInfo() async {
    bankData.clear();
    dynamic result;
    try {
      var response = await ApiService.get('api/v1/user/get-bank-info');
      if (response.statusCode == 200) {
        result = 'success';
        bankData = jsonDecode(response.body)['data'];
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

  static Future<String> addBankData(String accName, String accNo, String bankCode, String bankName) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/user/update-bank-info', {
        'account_name': accName,
        'account_no': accNo,
        'bank_code': bankCode,
        'bank_name': bankName
      });

      if (response.statusCode == 200) {
        await getBankInfo();
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else if (response.statusCode == 422) {
        debugPrint(response.body);
        var error = jsonDecode(response.body)['errors'];
        result = error[error.keys.toList()[0]].toString().replaceAll('[', '').replaceAll(']', '').toString();
      } else {
        debugPrint(response.body);
        result = jsonDecode(response.body)['message'];
      }
    } catch (e) {
      if (e is SocketException) {
        result = 'no internet';
        internet = false;
      }
    }
    return result;
  }

  static Future<String> getReferral() async {
    dynamic result;
    try {
      var response = await ApiService.get('api/v1/get/referral');
      if (response.statusCode == 200) {
        result = 'success';
        myReferralCode = jsonDecode(response.body)['data'];
        valueNotifierHome.incrementNotifier();
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

  static Future<String> updateProfileWithoutImage(String name, String email) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/user/driver-profile', {
        'name': name,
        'email': email,
      });

      if (response.statusCode == 200) {
        result = 'success';
        await getUserDetails();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else if (response.statusCode == 422) {
        debugPrint(response.body);
        var error = jsonDecode(response.body)['errors'];
        result = error[error.keys.toList()[0]].toString().replaceAll('[', '').replaceAll(']', '').toString();
      } else {
        debugPrint(response.body);
        result = jsonDecode(response.body)['message'];
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
