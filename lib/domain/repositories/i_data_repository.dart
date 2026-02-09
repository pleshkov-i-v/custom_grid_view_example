import 'package:custom_grid_view_example/domain/entities/item_entity.dart';
import 'package:custom_grid_view_example/domain/entities/section_entity.dart';

abstract interface class IDataRepository {
  Future<List<SectionEntity>> getSectionedData();
  Future<List<ItemEntity>> getData();
}
