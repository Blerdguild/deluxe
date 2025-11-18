
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';

abstract class HarvestDataSource {
  Future<List<Harvest>> getHarvests();
  Future<void> addHarvest(Harvest harvest);
  Future<void> deleteHarvest(String harvestId);
}

class HarvestLocalDataSource implements HarvestDataSource {
  final List<Harvest> _harvests = [
    Harvest(
      id: '1',
      strainName: 'OG Kush',
      weight: 10.5,
      harvestDate: DateTime(2023, 4, 15),
    ),
    Harvest(
      id: '2',
      strainName: 'Blue Dream',
      weight: 15.2,
      harvestDate: DateTime(2023, 4, 20),
    ),
    Harvest(
      id: '3',
      strainName: 'Girl Scout Cookies',
      weight: 8.7,
      harvestDate: DateTime(2023, 5, 1),
    ),
  ];

  @override
  Future<List<Harvest>> getHarvests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_harvests);
  }

  @override
  Future<void> addHarvest(Harvest harvest) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _harvests.add(harvest);
  }

  @override
  Future<void> deleteHarvest(String harvestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _harvests.removeWhere((harvest) => harvest.id == harvestId);
  }
}
