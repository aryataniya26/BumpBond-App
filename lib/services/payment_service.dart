import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'subscription_service.dart';

class PaymentService {
  static final Razorpay _razorpay = Razorpay();
  static String? _currentPlanKey;

  static void initialize() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void openCheckout({
    required String amount,
    required String planName,
    required String planKey,
    required BuildContext context,
  }) {
    _currentPlanKey = planKey;

    var options = {
      'key': 'rzp_test_RlXp62CnWFW57e',
      'amount': (int.parse(amount) * 100).toString(),
      'name': 'Bump Bond App',
      'description': '$planName Plan',
      'prefill': {
        'contact': '9999999999',
        'email': 'user@example.com'
      },
      'theme': {'color': '#FF6B8A'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");

    if (_currentPlanKey != null) {
      await SubscriptionService.setCurrentPlan(_currentPlanKey!);
    }
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed: ${response.code} - ${response.message}");
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  static void dispose() {
    _razorpay.clear();
  }
}