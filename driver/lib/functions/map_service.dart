import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'functions.dart';

class MapService {
  static Future<List<LatLng>> getPolylines(bool animate) async {
    List<LatLng> polyList = [];
    String pickLat = '';
    String pickLng = '';
    String dropLat = '';
    String dropLng = '';

    if (driverReq.isEmpty ||
        (driverReq['accepted_at'] != null &&
            driverReq['is_driver_arrived'] == 0) ||
        driverReq['poly_line'] == null ||
        driverReq['poly_line'] == '') {
      
      if (driverReq.isEmpty ||
          driverReq['is_driver_arrived'] == 1 ||
          driverReq['accepted_at'] == null) {
        
        for (var i = 1; i < addressList.length; i++) {
          pickLat = addressList[i - 1].latlng.latitude.toString();
          pickLng = addressList[i - 1].latlng.longitude.toString();
          dropLat = addressList[i].latlng.latitude.toString();
          dropLng = addressList[i].latlng.longitude.toString();

          final steps = await _fetchDirections(pickLat, pickLng, dropLat, dropLng);
          if (steps != null) {
            polyList.addAll(decodeEncodedPolyline(steps));
          }
        }
      } else {
        pickLat = center.latitude.toString();
        pickLng = center.longitude.toString();
        dropLat = addressList[0].latlng.latitude.toString();
        dropLng = addressList[0].latlng.longitude.toString();

        final steps = await _fetchDirections(pickLat, pickLng, dropLat, dropLng);
        if (steps != null) {
          polyList.addAll(decodeEncodedPolyline(steps));
        }
      }
    } else {
      List poly = driverReq['poly_line'].toString().split('poly');
      for (var i = 0; i < poly.length; i++) {
        polyList.addAll(decodeEncodedPolyline(poly[i]));
      }
    }

    if (animate) {
      polyAnimated = true;
    }
    return polyList;
  }

  static Future<String?> _fetchDirections(String pickLat, String pickLng, String dropLat, String dropLng) async {
    try {
      http.Response value;
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$pickLat%2C$pickLng&destination=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey');
      
      if (Platform.isAndroid) {
        value = await http.get(uri, headers: {
          'X-Android-Package': packageName,
          'X-Android-Cert': signKey
        });
      } else {
        value = await http.get(uri, headers: {'X-IOS-Bundle-Identifier': packageName});
      }

      if (value.statusCode == 200) {
        return jsonDecode(value.body)['routes'][0]['overview_polyline']['points'];
      }
    } catch (e) {
      if (e is SocketException) internet = false;
    }
    return null;
  }

  static List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

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
      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  static Future<String?> geoCoding(double lat, double lng) async {
    try {
      http.Response val;
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey');
      
      if (Platform.isAndroid) {
        val = await http.get(uri, headers: {'X-Android-Package': packageName, 'X-Android-Cert': signKey});
      } else {
        val = await http.get(uri, headers: {'X-IOS-Bundle-Identifier': packageName});
      }

      if (val.statusCode == 200) {
        return jsonDecode(val.body)['results'][0]['formatted_address'];
      }
    } catch (e) {
      if (e is SocketException) internet = false;
    }
    return null;
  }
}
