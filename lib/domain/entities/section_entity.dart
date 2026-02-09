import 'package:custom_grid_view_example/domain/entities/item_entity.dart';

class SectionEntity {
  final int id;
  final String title;
  final List<ItemEntity> items;

  SectionEntity({required this.id, required this.title, required this.items});
}
