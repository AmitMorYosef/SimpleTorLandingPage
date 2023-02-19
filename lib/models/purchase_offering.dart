import 'package:purchases_flutter/object_wrappers.dart';

class PurchaseOffering {
  Map<String, StoreProduct> products = {};
  bool inUsed = false;
  PurchaseOffering({required this.products});

  void isAlreadyActive(List<String> productsIds) {
    bool resp = false;
    productsIds.forEach((productId) {
      if (products.containsKey(productId)) {
        resp = true;
        return;
      }
    });
    inUsed = resp;
  }

  Map<String, StoreProduct> canBeUsed(List<String> productsIds) {
    Map<String, StoreProduct> dupProducts = {...products};
    productsIds.forEach((productId) {
      if (dupProducts.containsKey(productId)) {
        dupProducts.remove(productId);
      }
    });
    return dupProducts;
  }
}
