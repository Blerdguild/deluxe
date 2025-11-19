class Harvest {
  final String id;
  final String strainName;
  final double weight;
  final DateTime harvestDate;

  final String? imageUrl;

  Harvest({
    required this.id,
    required this.strainName,
    required this.weight,
    required this.harvestDate,
    this.imageUrl,
  });
}
