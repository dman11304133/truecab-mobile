import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'functions.dart';

class WalletService {
  static Map<String, dynamic> walletBalance = {};
  static Map<String, dynamic> paymentGateways = {};
  static List walletHistory = [];
  static Map<String, dynamic> walletPages = {};
  static Map<String, dynamic> stripeToken = {};
  static Map<String, dynamic> paystackCode = {};
  static Map<String, dynamic> cftToken = {};
  static Map<String, dynamic> cfSuccessList = {};

  static Future<String> getWalletHistory() async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/payment/wallet/history');
      if (response.statusCode == 200) {
        walletBalance = jsonDecode(response.body);
        walletHistory = walletBalance['wallet_history']['data'];
        walletPages = walletBalance['wallet_history']['meta']['pagination'];
        result = 'success';
        valueNotifierBook.incrementNotifier();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failure';
        valueNotifierBook.incrementNotifier();
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
        valueNotifierBook.incrementNotifier();
      }
    }
    return result;
  }

  static Future<String> getWalletHistoryPage(int page) async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/payment/wallet/history?page=$page');
      if (response.statusCode == 200) {
        walletBalance = jsonDecode(response.body);
        List list = walletBalance['wallet_history']['data'];
        for (var element in list) {
          walletHistory.add(element);
        }
        walletPages = walletBalance['wallet_history']['meta']['pagination'];
        result = 'success';
        valueNotifierBook.incrementNotifier();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failure';
        valueNotifierBook.incrementNotifier();
      }
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
        valueNotifierBook.incrementNotifier();
      }
    }
    return result;
  }

  static Future<String> getClientToken() async {
    String result = '';
    try {
      var response = await ApiService.get('api/v1/payment/client/token');
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
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> getStripePayment(double money) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/stripe/intent', {'amount': money});
      if (response.statusCode == 200) {
        result = 'success';
        stripeToken = jsonDecode(response.body)['data'];
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

  static Future<String> addMoneyStripe(double amount, String nonce) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/stripe/add/money', {
        'amount': amount,
        'payment_nonce': nonce,
        'payment_id': nonce,
      });
      if (response.statusCode == 200) {
        await getWalletHistory();
        // getUserDetails should be called from UserService or similar, 
        // for now we'll assume it's still globally available in functions.dart or imported
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

  static Future<String> payMoneyStripe(String nonce) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/stripe/make-payment-for-ride', {
        'request_id': userRequestData['id'],
        'payment_id': nonce,
      });
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
        internet = false;
        result = 'no internet';
      }
    }
    return result;
  }

  static Future<String> getPaystackPayment(Map<String, dynamic> body) async {
    String result = '';
    paystackCode.clear();
    try {
      var response = await ApiService.post('api/v1/payment/paystack/initialize', body);
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == false) {
          result = jsonDecode(response.body)['message'];
        } else {
          result = 'success';
          paystackCode = jsonDecode(response.body)['data'];
        }
      } else if (response.statusCode == 401) {
        result = 'logout';
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

  static Future<String> addMoneyPaystack(double amount, String nonce) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/paystack/add-money', {
        'amount': amount,
        'payment_nonce': nonce,
        'payment_id': nonce,
      });
      if (response.statusCode == 200) {
        await getWalletHistory();
        await getUserDetails();
        paystackCode.clear();
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

  static Future<String> addMoneyFlutterwave(double amount, String nonce) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/flutter-wave/add-money', {
        'amount': amount,
        'payment_nonce': nonce,
        'payment_id': nonce,
      });
      if (response.statusCode == 200) {
        await getWalletHistory();
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

  static Future<String> addMoneyRazorpay(double amount, String nonce) async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/razerpay/add-money', {
        'amount': amount,
        'payment_nonce': nonce,
        'payment_id': nonce,
      });
      if (response.statusCode == 200) {
        await getWalletHistory();
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

  static Future<String> getCfToken(double money, String currency) async {
    cftToken.clear();
    cfSuccessList.clear();
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/cashfree/generate-cftoken', {
        'order_amount': money,
        'order_currency': currency,
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == 'OK') {
          cftToken = jsonDecode(response.body);
          result = 'success';
        } else {
          debugPrint(response.body);
          result = 'failure';
        }
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

  static Future<String> cashFreePaymentSuccess() async {
    String result = '';
    try {
      var response = await ApiService.post('api/v1/payment/cashfree/add-money-to-wallet-webhooks', {
        'orderId': cfSuccessList['orderId'],
        'orderAmount': cfSuccessList['orderAmount'],
        'referenceId': cfSuccessList['referenceId'],
        'txStatus': cfSuccessList['txStatus'],
        'paymentMode': cfSuccessList['paymentMode'],
        'txMsg': cfSuccessList['txMsg'],
        'txTime': cfSuccessList['txTime'],
        'signature': cfSuccessList['signature'],
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success'] == true) {
          result = 'success';
          await getWalletHistory();
          await getUserDetails();
        } else {
          debugPrint(response.body);
          result = 'failure';
        }
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
}
