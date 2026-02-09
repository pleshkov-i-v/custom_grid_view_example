import 'dart:math';

import 'package:custom_grid_view_example/domain/entities/item_entity.dart';
import 'package:custom_grid_view_example/domain/entities/section_entity.dart';
import 'package:custom_grid_view_example/domain/repositories/i_data_repository.dart';

class DataRepository implements IDataRepository {
  DataRepository._();
  static final DataRepository _instance = DataRepository._();
  static IDataRepository get instance => _instance;

  bool _isInitialized = false;
  late final List<SectionEntity> _sections;
  void _ensureInit() {
    if (_isInitialized) return;

    final rnd = Random();
    _sections = List.unmodifiable(
      List<SectionEntity>.generate(
        100,
        growable: false,
        (i) => SectionEntity(
          id: i,
          title: 'Section $i',
          items: List.unmodifiable(
            List<ItemEntity>.generate(rnd.nextInt(999), growable: false, (j) {
              final itemIndex = i * 1000 + j;
              return ItemEntity(id: itemIndex, name: 'Item $itemIndex');
            }),
          ),
        ),
      ),
    );
    _isInitialized = true;
  }

  @override
  Future<List<ItemEntity>> getData() async {
    _ensureInit();
    return List.unmodifiable(_sections.expand((section) => section.items));
  }

  @override
  Future<List<SectionEntity>> getSectionedData() async {
    _ensureInit();
    return _sections;
  }
}
