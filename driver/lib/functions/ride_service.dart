import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'functions.dart';

class RideService {
  static Future<dynamic> acceptRequest() async {
    try {
      var response = await ApiService.post('api/v1/request/respond', {
        'request_id': driverReq['id'],
        'is_accept': 1
      });

      if (response.statusCode == 200) {
        return 'success';
      } else {
        var body = jsonDecode(response.body);
        if (body['message'] == 'request already cancelled') {
          return 'cancelled';
        }
        if (body['message'] == 'request accepted by another driver') {
          return 'already_accepted';
        }
        debugPrint(response.body);
        return 'failed';
      }
    } catch (e) {
      if (e is SocketException) internet = false;
      return 'failed';
    }
  }

  static Future<dynamic> startTrip({String? otp}) async {
    try {
      final body = {
        'request_id': driverReq['id'],
        'pick_lat': driverReq['pick_lat'],
        'pick_lng': driverReq['pick_lng'],
        if (otp != null) 'ride_otp': otp
      };
      
      var response = await ApiService.post('api/v1/request/started', body);
      if (response.statusCode == 200) {
        return 'success';
      } else {
        try {
          var respBody = jsonDecode(response.body);
          if (response.statusCode == 500 && respBody['message'] == 'request cancelled') {
            await getUserDetails();
          }
        } catch (e) {}
      }
      return 'failure';
    } catch (e) {
      if (e is SocketException) internet = false;
      return 'no internet';
    }
  }

  static Future<dynamic> endTrip(Map<String, dynamic> body) async {
    try {
      var response = await ApiService.post('api/v1/request/end', body);
      if (response.statusCode == 200) {
        return 'success';
      } else {
        try {
          var respBody = jsonDecode(response.body);
          if (response.statusCode == 500 && respBody['message'] == 'request cancelled') {
            await getUserDetails();
          }
        } catch (e) {}
      }
      return 'failure';
    } catch (e) {
      if (e is SocketException) internet = false;
      return 'no internet';
    }
  }
}
