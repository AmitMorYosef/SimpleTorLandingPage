enum LoginErrorCodes {
  updatefinishLogIn,
  logoutIfSignUpNotCompleted,
  userLoggedIn,
  saveUserNameLocally,
  setupLoggin,
  isUserExist,
  verifyOpt,
  sendSmsToPhone,
  logginAnonimously
}

Map<LoginErrorCodes, int> loginCodeToInt = {
  LoginErrorCodes.updatefinishLogIn: 5000,
  LoginErrorCodes.logoutIfSignUpNotCompleted: 5001,
  LoginErrorCodes.userLoggedIn: 5002,
  LoginErrorCodes.saveUserNameLocally: 5003,
  LoginErrorCodes.setupLoggin: 5004,
  LoginErrorCodes.isUserExist: 5005,
  LoginErrorCodes.verifyOpt: 5006,
  LoginErrorCodes.sendSmsToPhone: 5007,
  LoginErrorCodes.logginAnonimously: 5008,
};
