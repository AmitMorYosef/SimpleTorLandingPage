enum PurchaseErrorCodes {
  userInfo,
  purchaseBusiness,
  businessExprationDate,
  getAvailableProducts,
  isBusinessActive,
  loginToUser,
  setPurchaseProducts,
  logoutFromUser,
  entitlementData,
  purchaseWorker,
  clearUsedProduct
}

Map<PurchaseErrorCodes, int> purchaseCodeToInt = {
  PurchaseErrorCodes.userInfo: 8000,
  PurchaseErrorCodes.purchaseBusiness: 8001,
  PurchaseErrorCodes.businessExprationDate: 8002,
  PurchaseErrorCodes.getAvailableProducts: 8003,
  PurchaseErrorCodes.isBusinessActive: 8004,
  PurchaseErrorCodes.loginToUser: 8005,
  PurchaseErrorCodes.setPurchaseProducts: 8006,
  PurchaseErrorCodes.logoutFromUser: 8007,
  PurchaseErrorCodes.entitlementData: 8008,
  PurchaseErrorCodes.purchaseWorker: 8009,
  PurchaseErrorCodes.clearUsedProduct: 8010
};
