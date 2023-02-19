enum ManagerErrorCodes {
  makeUserToWorker,
  deleteWorker,
  createBuisness,
  deleteBuisness,
  sendGeneralNotification,
  purchaseSubAfterExpiration,
  changeSub
}

Map<ManagerErrorCodes, int> managerCodeToInt = {
  ManagerErrorCodes.makeUserToWorker: 3000,
  ManagerErrorCodes.deleteWorker: 3001,
  ManagerErrorCodes.createBuisness: 3002,
  ManagerErrorCodes.deleteBuisness: 3003,
  ManagerErrorCodes.sendGeneralNotification: 3004,
  ManagerErrorCodes.purchaseSubAfterExpiration: 3005,
  ManagerErrorCodes.changeSub: 3006
};
