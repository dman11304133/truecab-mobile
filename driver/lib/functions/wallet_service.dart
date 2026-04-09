import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'functions.dart';

class WalletService {
  static Future<String> getWalletHistory() async {
    dynamic result;
    try {
      var response = await ApiService.get('api/v1/payment/wallet/history');
      if (response.statusCode == 200) {
        walletBalance = jsonDecode(response.body);
        walletHistory = walletBalance['wallet_history']['data'];
        walletPages = walletBalance['wallet_history']['meta']['pagination'];
        paymentGateways = walletBalance['payment_gateways'];
        result = 'success';
        valueNotifierHome.incrementNotifier();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        walletBalance.clear();
        walletHistory.clear();
        walletPages.clear();
        debugPrint(response.body);
        result = 'failure';
        valueNotifierHome.incrementNotifier();
      }
      walletHistory.removeWhere((element) => element.isEmpty);
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
        valueNotifierHome.incrementNotifier();
      }
    }
    return result;
  }

  static Future<String> getWalletHistoryPage(String page) async {
    dynamic result;
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
        valueNotifierHome.incrementNotifier();
      } else if (response.statusCode == 401) {
        result = 'logout';
      } else {
        debugPrint(response.body);
        result = 'failure';
        valueNotifierHome.incrementNotifier();
      }
      walletHistory.removeWhere((element) => element.isEmpty);
    } catch (e) {
      if (e is SocketException) {
        internet = false;
        result = 'no internet';
        valueNotifierHome.incrementNotifier();
      }
    }
    return result;
  }

  static Future<String> getStripePayment(double money) async {
    dynamic results;
    try {
      var response = await ApiService.post('api/v1/payment/stripe/intent', {'amount': money});
      if (response.statusCode == 200) {
        results = 'success';
        stripeToken = jsonDecode(response.body)['data'];
      } else if (response.statusCode == 401) {
        results = 'logout';
      } else {
        debugPrint(response.body);
        results = 'failure';
      }
    } catch (e) {
      if (e is SocketException) {
        results = 'no internet';
        internet = false;
      }
    }
    return results;
  }

  static Future<String> addMoneyStripe(amount, nonce) async {
    dynamic result;
    try {
      var response = await ApiService.post('api/v1/payment/stripe/add/money', {
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

  static Future<dynamic> getPaystackPayment(money) async {
    dynamic results;
    paystackCode.clear();
    try {
      var response = await ApiService.post('api/v1/payment/paystack/initialize', {'amount': money});
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'] == false) {
          results = jsonDecode(response.body)['message'];
        } else {
          results = 'success';
          paystackCode = jsonDecode(response.body)['data'];
        }
      } else if (response.statusCode == 401) {
        results = 'logout';
      } else {
        debugPrint(response.body);
        results = jsonDecode(response.body)['message'];
      }
    } catch (e) {
      if (e is SocketException) {
        results = 'no internet';
        internet = false;
      }
    }
    return results;
  }

  static Future<String> addMoneyFlutterwave(amount, nonce) async {
    dynamic result;
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

  static Future<String> addMoneyRazorpay(amount, nonce) async {
    dynamic result;
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

  static Future<String> getCfToken(money, currency) async {
    cftToken.clear();
    cfSuccessList.clear();
    dynamic result;
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
    dynamic result;
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
