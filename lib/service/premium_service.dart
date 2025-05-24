import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../main.dart';
import '../model/app_user.dart';
import 'user_service.dart';

class PremiumService {
  static const String _kPremiumId = 'premium_monthly';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  final UserService _userService = UserService.instance;

  // Make PremiumService a singleton
  static final PremiumService instance = PremiumService._internal();
  factory PremiumService() => instance;
  PremiumService._internal();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  Future<bool> initialize() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      _isAvailable = available;

      if (_isAvailable) {
        await _loadProducts();
        _subscription = _inAppPurchase.purchaseStream.listen(
          _handlePurchaseUpdates,
        );
      }
    } catch (e) {
      debugPrint('Error initializing premium service: $e');
      return false;
    }
    return true;
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({_kPremiumId});

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    print("purchaseDetailsList: $purchaseDetailsList");
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _verifyPurchase(purchaseDetails, userNotifier.value!);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(
    PurchaseDetails purchaseDetails,
    AppUser user,
  ) async {
    await _userService.updatePremiumStatus(
      userId: user.id,
      isPremium: true,
      subscriptionId: purchaseDetails.purchaseID,
    );
  }

  /// Verifies if a user has an active subscription and updates their premium status accordingly.
  /// Returns a SubscriptionVerificationResult containing both the verification status and whether an update was performed.
  Future<SubscriptionVerificationResult> verifySubscriptionStatus(
    String userId,
  ) async {
    if (!_isAvailable) {
      await initialize();
    }
    try {
      final user = await _userService.getUserDetails(userId);

      if (user == null || user.subscriptionId == null) {
        // No subscription found
        if (user?.isPremium == true) {
          // User was marked as premium but has no subscription - update status
          await _userService.updatePremiumStatus(
            userId: userId,
            isPremium: false,
            subscriptionId: null,
          );
          return SubscriptionVerificationResult(
            hasActiveSubscription: false,
            statusUpdated: true,
          );
        }
        return SubscriptionVerificationResult(
          hasActiveSubscription: false,
          statusUpdated: false,
        );
      }

      bool hasActiveSubscription = false;
      await for (final purchaseList in _inAppPurchase.purchaseStream) {
        for (final purchase in purchaseList) {
          if (purchase.purchaseID == user.subscriptionId &&
              purchase.status == PurchaseStatus.purchased) {
            hasActiveSubscription = true;
            break;
          }
        }
        break; // Only check the first update from the stream
      }

      if (!hasActiveSubscription && user.isPremium) {
        // Subscription expired, update status
        await _userService.updatePremiumStatus(
          userId: userId,
          isPremium: false,
          subscriptionId: null,
        );
        return SubscriptionVerificationResult(
          hasActiveSubscription: false,
          statusUpdated: true,
        );
      }

      return SubscriptionVerificationResult(
        hasActiveSubscription: hasActiveSubscription,
        statusUpdated: false,
      );
    } catch (e) {
      debugPrint('Error verifying subscription status: $e');
      return SubscriptionVerificationResult(
        hasActiveSubscription: false,
        statusUpdated: false,
        error: e.toString(),
      );
    }
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

  void dispose() {
    _subscription?.cancel();
  }
}

/// Result class for subscription verification to provide clear status information
class SubscriptionVerificationResult {
  final bool hasActiveSubscription;
  final bool statusUpdated;
  final String? error;

  SubscriptionVerificationResult({
    required this.hasActiveSubscription,
    required this.statusUpdated,
    this.error,
  });
}
