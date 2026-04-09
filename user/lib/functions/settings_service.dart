import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'api_service.dart';
import 'functions.dart';

class SettingsService {
  static List sosData = [];
  static List faqData = [];
  static Map<String, dynamic> myFaqPage = {};
  static List generalComplaintList = [];

  static Future<String> getSosData() async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/common/sos/list');
      if (response.statusCode == 200) {
        sosData = jsonDecode(response.body)['data'];
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

  static Future<String> addSos(String name, String number) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/common/sos/store', {'name': name, 'number': number});
      if (response.statusCode == 200) {
        await getSosData();
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

  static Future<String> deleteSos(String id) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/common/sos/delete/$id', {});
      if (response.statusCode == 200) {
        await getSosData();
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

  static Future<bool> notifyAdmin() async {
    var db = FirebaseDatabase.instance.ref();
    bool result = false;
    try {
      if (userRequestData.isNotEmpty) {
        await db.child('SOS/${userRequestData['id']}').update({
          "is_driver": "0",
          "is_user": "1",
          "req_id": userRequestData['id'],
          "serv_loc_id": userRequestData['service_location_id'],
          "updated_at": ServerValue.timestamp
        });
        result = true;
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = false;
      }
    }
    return result;
  }

  static Future<String> getFaqData(double lat, double lng) async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/common/faq/list/$lat/$lng');
      if (response.statusCode == 200) {
        faqData = jsonDecode(response.body)['data'];
        myFaqPage = jsonDecode(response.body)['meta'];
        valueNotifierBook.incrementNotifier();
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

  static Future<String> getFaqPages(String pageUrl) async {
    String result = '';
    try {
      // url here is expected to be the full pagination link or similar
      // If ApiService.get only takes relative paths, we might need adjustment
      var response = await ApiService.get(pageUrl.replaceFirst(url, ''));
      if (response.statusCode == 200) {
        var val = jsonDecode(response.body)['data'];
        for (var element in val) {
          faqData.add(element);
        }
        myFaqPage = jsonDecode(response.body)['meta'];
        valueNotifierBook.incrementNotifier();
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

  static Future<String> getGeneralComplaint(String type) async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/common/complaint-titles?complaint_type=$type');
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

  static Future<String> makeGeneralComplaint(String complaintDesc, int index) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/common/make-complaint', {
        'complaint_title_id': generalComplaintList[index]['id'],
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

  static Future<String> makeRequestComplaint(String requestId, String complaintDesc, int index) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/common/make-complaint', {
        'complaint_title_id': generalComplaintList[index]['id'],
        'description': complaintDesc,
        'request_id': requestId
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
}
