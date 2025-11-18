
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';

abstract class HarvestRepository {
  Future<List<Harvest>> getHarvests();
  Future<void> addHarvest(Harvest harvest);
  Future<void> deleteHarvest(String harvestId);
}
