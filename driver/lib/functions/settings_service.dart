import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'api_service.dart';
import 'functions.dart';

class SettingsService {
  static Future<String> addSos(String name, String number) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/common/sos/store', {
        'name': name,
        'number': number,
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

  static Future<String> deleteSos(id) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/common/sos/delete/$id', {});
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

  static Future<String> getFaqData(lat, lng) async {
    dynamic result;
    try {
      var response = await ApiService.get('api/v1/common/faq/list/$lat/$lng');
      if (response.statusCode == 200) {
        faqData = jsonDecode(response.body)['data'];
        myFaqPage = jsonDecode(response.body)['meta'];
        valueNotifierHome.incrementNotifier();
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

  static Future<String> getFaqPages(id) async {
    dynamic result;
    try {
      var response = await ApiService.get('api/v1/common/faq/list/$id');
      if (response.statusCode == 200) {
        var val = jsonDecode(response.body)['data'];
        for (var element in val) {
          faqData.add(element);
        }
        myFaqPage = jsonDecode(response.body)['meta'];
        valueNotifierHome.incrementNotifier();
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

  static Future<String> getGeneralComplaint(type) async {
    dynamic result;
    try {
      var response = await ApiService.get(
        'api/v1/common/complaint-titles?complaint_type=$type&transport_type=${userDetails['transport_type']}',
      );
      if (response.statusCode == 200) {
        generalComplaintList = jsonDecode(response.body)['data'];
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> makeGeneralComplaint(String complaintDesc) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/common/make-complaint', {
        'complaint_title_id': generalComplaintList[complaintType]['id'],
        'description': complaintDesc,
      });
      if (response.statusCode == 200) {
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> makeRequestComplaint(String complaintDesc) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/common/make-complaint', {
        'complaint_title_id': generalComplaintList[complaintType]['id'],
        'description': complaintDesc,
        'request_id': myHistory[selectedHistory]['id'],
      });
      if (response.statusCode == 200) {
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failed';
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<bool> notifyAdmin() async {
    var db = FirebaseDatabase.instance.ref();
    dynamic result;
    try {
      await db.child('SOS/${driverReq['id']}').update({
        "is_driver": "1",
        "is_user": "0",
        "req_id": driverReq['id'],
        "serv_loc_id": driverReq['service_location_id'],
        "updated_at": ServerValue.timestamp
      });
      result = true;
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = false;
      }
    }
    return result;
  }
}
