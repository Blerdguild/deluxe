import 'package:deluxe/shared/models/dispensary_model.dart';

abstract class DispensaryRepository {
  Stream<List<Dispensary>> getDispensaries();
  Future<void> createDispensary(Dispensary dispensary);
}
