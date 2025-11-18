
class FarmerOrder {
  final String id;
  final String strainName;
  final double quantity;
  final String dispensaryName;
  final String status;
  final DateTime orderDate;

  FarmerOrder({
    required this.id,
    required this.strainName,
    required this.quantity,
    required this.dispensaryName,
    required this.status,
    required this.orderDate,
  });
}
