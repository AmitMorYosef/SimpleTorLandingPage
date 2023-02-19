enum LoadingErrorCodes {
  loadAppData,
  executeFuture,
  printAvailability,
}

Map<LoadingErrorCodes, int> loadingCodeToInt = {
  LoadingErrorCodes.loadAppData: 4000,
  LoadingErrorCodes.executeFuture: 4001,
  LoadingErrorCodes.printAvailability: 4002,
};
