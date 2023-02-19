enum LoadingStatuses {
  success,
  unknownError,
  timeEror,
  loading,
  maintenanceMode,
  updateAvilable
}

const Map<LoadingStatuses, String> loadingMassage = {
  LoadingStatuses.success: "success",
  LoadingStatuses.unknownError: "unknownError",
  LoadingStatuses.timeEror: "timeEror",
  LoadingStatuses.loading: "loading",
  LoadingStatuses.updateAvilable: "updateAvilable"
};
