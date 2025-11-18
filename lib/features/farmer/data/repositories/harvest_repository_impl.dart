
import 'package:deluxe/features/farmer/data/datasources/harvest_datasource.dart';
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/domain/repositories/harvest_repository.dart';

class HarvestRepositoryImpl implements HarvestRepository {
  final HarvestDataSource dataSource;

  HarvestRepositoryImpl(this.dataSource);

  @override
  Future<List<Harvest>> getHarvests() {
    return dataSource.getHarvests();
  }

  @override
  Future<void> addHarvest(Harvest harvest) {
    return dataSource.addHarvest(harvest);
  }

  @override
  Future<void> deleteHarvest(String harvestId) {
    return dataSource.deleteHarvest(harvestId);
  }
}
