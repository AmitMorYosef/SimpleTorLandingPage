int eligibleWorkersAmount({required String productId}) {
  if (productId == "") return 0;
  return int.tryParse(productId.split("_")[1].replaceAll("worker", "")) ?? 0;
}
