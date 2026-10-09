import 'package:flutter/services.dart' show PlatformException;
import 'package:hazard_app/features/subscription/utils/paywall_copy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Human words for a store error. A cancelled purchase is not an error
/// and shows nothing (the sheet just closes); everything else says what
/// happened, without claiming the person was or wasn't charged when the
/// store hasn't said (master spec §6).
String? purchaseErrorMessage(final Object error) {
  if (error is PlatformException) {
    final code = PurchasesErrorHelper.getErrorCode(error);
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return null;
      case PurchasesErrorCode.networkError:
      case PurchasesErrorCode.offlineConnectionError:
        return 'No connection. Check your network and try again.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This plan is not available in the store right now.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device or account.';
      case PurchasesErrorCode.paymentPendingError:
        return kPurchasePending;
      case PurchasesErrorCode.productAlreadyPurchasedError:
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'This store account already has this plan. Tap Restore '
            'purchases.';
      default:
        return 'That purchase could not be completed (${code.name}).';
    }
  }
  return 'That purchase could not be completed.';
}
