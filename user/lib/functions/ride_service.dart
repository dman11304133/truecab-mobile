import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'functions.dart';
import 'auth_service.dart';
import 'ride_state.dart';

class RideService {
  static Future<dynamic> createRequest(String value, String api) async {
    waitingTime = 0;
    try {
      var response = await ApiService.post(api, jsonDecode(value));
      if (response.statusCode == 200) {
        userRequestData = jsonDecode(response.body)['data'];
        if (etaDetails.isNotEmpty && choosenVehicle != null) {
          userRequestData['base_price'] =
              etaDetails[choosenVehicle]['base_price'];
          userRequestData['distance_price'] =
              etaDetails[choosenVehicle]['distance_price'] ?? etaDetails[choosenVehicle]['price_per_distance'];
          userRequestData['time_price'] =
              etaDetails[choosenVehicle]['time_price'] ?? etaDetails[choosenVehicle]['price_per_time'];
          userRequestData['waiting_charge'] =
              etaDetails[choosenVehicle]['waiting_charge'] ?? etaDetails[choosenVehicle]['waiting_charge_per_min'];
          userRequestData['booking_fee'] =
              etaDetails[choosenVehicle]['booking_fee'];
          userRequestData['admin_commission'] =
              etaDetails[choosenVehicle]['admin_commission'];
        }
        streamRequest();
        valueNotifierBook.incrementNotifier();
        return 'success';
      } else {
        debugPrint(response.body);
        final body = jsonDecode(response.body);
        if (body['message'] == 'no drivers available') {
          noDriverFound = true;
        } else {
          tripError = body['message'].toString();
          tripReqError = true;
        }
        valueNotifierBook.incrementNotifier();
        return 'failure';
      }
    } catch (e) {
      if (e is SocketException) internet = false;
      return 'no internet';
    }
  }

  static Future<dynamic> cancelRequest({String? reason, bool autoCancel = false}) async {
    if (userRequestData['id'] == null) return 'failure';
    try {
      final endpoint = 'api/v1/request/cancel';
      final body = {
        'request_id': userRequestData['id'],
        if (reason != null) 'custom_reason': reason,
      };
      
      var response = await ApiService.post(endpoint, body);
      if (response.statusCode == 200) {
        userRequestData = {};
        if (!autoCancel) {
          cancelRequestByUser = true;
        }
        valueNotifierBook.incrementNotifier();
        return 'success';
      }
      return 'failure';
    } catch (e) {
      if (e is SocketException) internet = false;
      return 'no internet';
    }
  }

  static Future<dynamic> getEta({required Map<String, dynamic> body}) async {
    try {
      var response = await ApiService.post('api/v1/request/eta', body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      if (e is SocketException) internet = false;
      return null;
    }
  }

  static Future<dynamic> acceptRequest(body) async {
    dynamic result;
    try {
      var response =
          await ApiService.post('api/v1/request/respond-for-bid', jsonDecode(body));

      if (response.statusCode == 200) {
        ismulitipleride = true;
        await AuthService.getUserDetails(id: userRequestData['id']);
        result = 'success';
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        valueNotifierBook.incrementNotifier();
        result = false;
      }
      return result;
    } catch (e) {
      if (e is SocketException) internet = false;
      return false;
    }
  }
}
