import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'user_service.dart';

class PremiumService {
  static const String _kPremiumId = 'premium_monthly';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    _isAvailable = available;

    if (_isAvailable) {
      await _loadProducts();
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
      );
    }
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({_kPremiumId});

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _verifyPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    await _userService.updatePremiumStatus(
      userId: user.uid,
      isPremium: true,
      subscriptionId: purchaseDetails.purchaseID,
    );
  }

  Future<void> purchasePremium() async {
    if (!_isAvailable || _products.isEmpty) return;

    final ProductDetails productDetails = _products.first;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  Future<bool> isPremiumUser() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    return _userService.isPremiumUser(user.uid);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
