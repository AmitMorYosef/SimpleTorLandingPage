class PurchaseDetails {
  Map<String, List<String>> productsDescription = {};
  Map<String, String> productsNames = {};

  PurchaseDetails.fromJson(Map<String, dynamic> json) {
    this.productsNames = {};
    json['productsNames'].forEach((key, name) => productsNames[key] = name);
    this.productsDescription = {};
    json['productsDescription'].forEach((key, descprtionList) {
      productsDescription[key] = [];
      descprtionList
          .forEach((description) => productsDescription[key]!.add(description));
    });
  }
}
